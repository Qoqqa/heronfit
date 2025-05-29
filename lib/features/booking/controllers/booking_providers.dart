import 'dart:async'; // For StreamController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/services/booking_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Session; // For SupabaseClient
import 'package:heronfit/features/booking/models/active_booking_exists_exception.dart'; // Import custom exception
import 'package:heronfit/features/home/home_providers.dart'; // Import home_providers
import 'package:intl/intl.dart'; // For date formatting
import 'package:heronfit/features/booking/models/booking_model.dart';

// Assuming a supabaseClientProvider exists, e.g., in lib/core/providers/supabase_providers.dart
// For this example, let's define a simple one if it's not globally available.
// You should replace this with your actual Supabase client provider if it's different or located elsewhere.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // This is a common way to access the Supabase client.
  // Ensure Supabase is initialized before this provider is read.
  return Supabase.instance.client;
});

// Provider for BookingSupabaseService
final bookingSupabaseServiceProvider = Provider<BookingSupabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return BookingSupabaseService(supabaseClient);
});

// Provider to fetch sessions for a specific date
final fetchSessionsProvider = FutureProvider.family<List<Session>, DateTime>((
  ref,
  date,
) async {
  final bookingService = ref.watch(bookingSupabaseServiceProvider);
  return bookingService.getSessionsForDate(date);
});

// Provider to fetch the current user's active (confirmed and not ended) booking
// Using StreamProvider for real-time updates when bookings change in the database
final userActiveBookingProvider = StreamProvider<Booking?>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value(null); // Or throw an exception if user must be logged in
  }

  // Create a stream controller to emit values when bookings change
  final streamController = StreamController<void>();

  // Subscribe to changes in the bookings table
  final channel = supabase
      .channel('public:bookings')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'bookings',
        callback: (payload) {
          // Process the payload if needed
          print('Booking change detected: ${payload.toString()}');
          // Add an event to the stream controller to trigger a refresh
          streamController.add(null);
        },
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
      )
      .subscribe();

  // Return a stream from the controller
  final stream = streamController.stream;

  // Close the stream controller when the provider is disposed
  ref.onDispose(() {
    streamController.close();
    channel.unsubscribe();
  });

  // Create a merged stream that combines the initial fetch with subsequent updates
  // First, create a stream with just the initial booking
  final initialStream = Stream.fromFuture(_fetchActiveBooking(userId));

  // Then, create a stream that emits whenever the streamController emits
  final updatesStream = stream.asyncMap((_) => _fetchActiveBooking(userId));

  // Merge the two streams to get a stream that first emits the initial booking
  // and then emits whenever there's a change
  return Stream.multi((controller) {
    // Add the initial booking
    initialStream.listen(
      (booking) => controller.add(booking),
      onError: controller.addError,
    );

    // Add subsequent updates
    updatesStream.listen(
      (booking) => controller.add(booking),
      onError: controller.addError,
      onDone: controller.close,
    );
  });
});

// Helper function to fetch the active booking
Future<Booking?> _fetchActiveBooking(String userId) async {
  final supabase = Supabase.instance.client;
  final now = DateTime.now();
  final todayDateString = DateFormat('yyyy-MM-dd').format(now);

  try {
    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('status', BookingStatus.confirmed.name)
        .gte('session_date', todayDateString) // Session is today or in the future
        .order('session_date', ascending: true)
        .order('session_start_time', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final booking = Booking.fromJson(response);

    // Combine session_date and session_end_time to check if it has passed
    try {
      final sessionEndTimeParts = booking.sessionEndTime.split(':');
      final sessionEndDateTime = DateTime(
        booking.sessionDate.year,
        booking.sessionDate.month,
        booking.sessionDate.day,
        int.parse(sessionEndTimeParts[0]),
        int.parse(sessionEndTimeParts[1]),
        sessionEndTimeParts.length > 2 ? int.parse(sessionEndTimeParts[2]) : 0,
      );

      if (sessionEndDateTime.isAfter(now)) {
        return booking; // Active booking found
      }
    } catch (e) {
      // Handle parsing error for sessionEndTime, maybe log it
      print('Error parsing sessionEndTime for booking ${booking.id}: $e');
      return null; // Treat as non-active if time is invalid
    }

    return null; // Booking found but session has ended
  } catch (e) {
    print('Error fetching active booking: $e');
    // Optionally, rethrow or handle specific Supabase exceptions
    return null; // Or throw an error to be caught by the UI
  }
}

// --- Join Waitlist Notifier ---
class JoinWaitlistNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingSupabaseService _bookingService;
  final String _userId;

  JoinWaitlistNotifier(this._bookingService, this._userId)
      : super(const AsyncValue.data(null));

  Future<void> join(String sessionId, String? ticketId) async {
    state = const AsyncValue.loading();
    try {
      await _bookingService.joinWaitlist(_userId, sessionId, ticketId);
      state = const AsyncValue.data(null);
      print('[JoinWaitlistNotifier] Successfully joined waitlist for session $sessionId, ticket: $ticketId');
    } catch (e, s) {
      print('[JoinWaitlistNotifier] Error joining waitlist: $e\n$s');
      state = AsyncValue.error(e, s);
      rethrow; // Rethrow to allow UI to catch specific errors if needed
    }
  }
}

final joinWaitlistNotifierProvider = StateNotifierProvider.autoDispose<JoinWaitlistNotifier, AsyncValue<void>>((ref) {
  final bookingService = ref.watch(bookingSupabaseServiceProvider);
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  if (supabaseUser == null) {
    throw Exception('User not authenticated. Cannot join waitlist.');
  }
  return JoinWaitlistNotifier(bookingService, supabaseUser.id);
});

// --- Confirm Booking Notifier ---
class ConfirmBookingNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final BookingSupabaseService _bookingService;
  final String _userId;
  final StateNotifierProviderRef _ref;

  ConfirmBookingNotifier(this._bookingService, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> bookSession({
    required String sessionId,
    String? activatedTicketId,
    required String sessionDate,
    required String sessionStartTime,
    required String sessionEndTime,
    required String sessionCategory,
  }) async {
    state = const AsyncValue.loading();
    try {
      final bookingDetails = await _bookingService.bookSession(
        sessionId: sessionId,
        userId: _userId,
        activatedTicketId: activatedTicketId,
        sessionDate: sessionDate,
        sessionStartTime: sessionStartTime,
        sessionEndTime: sessionEndTime,
        sessionCategory: sessionCategory,
      );
      state = AsyncValue.data(bookingDetails);
      print('[ConfirmBookingNotifier] Successfully booked session: ${bookingDetails['id']}');

      _ref.invalidate(upcomingSessionProvider);

    } on ActiveBookingExistsException catch (e, s) {
      print('[ConfirmBookingNotifier] Error booking session: ActiveBookingExistsException: ${e.message}\n$s');
      state = AsyncValue.error(e.message, s);
    } catch (e, s) {
      print('[ConfirmBookingNotifier] Error booking session: $e\n$s');
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}

final confirmBookingNotifierProvider = StateNotifierProvider.autoDispose<
    ConfirmBookingNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  final bookingService = ref.watch(bookingSupabaseServiceProvider);
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  if (supabaseUser == null) {
    throw Exception('User not authenticated. Cannot confirm booking.');
  }
  return ConfirmBookingNotifier(bookingService, supabaseUser.id, ref);
});
