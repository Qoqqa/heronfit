import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/services/booking_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Session; // For SupabaseClient
import 'package:heronfit/features/booking/models/active_booking_exists_exception.dart'; // Import custom exception
import 'package:heronfit/features/home/home_providers.dart'; // Import home_providers

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
