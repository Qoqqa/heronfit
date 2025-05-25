import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/features/booking/models/booking_status.dart'; // Import BookingStatus

/// Provider to fetch the next upcoming booked session for the current user.
///
/// Returns a [Map<String, dynamic>] representing the combined booking and session data,
/// or null if no upcoming booked session is found or if the user is not authenticated.
final upcomingSessionProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final supabaseClient = Supabase.instance.client;
  final user = supabaseClient.auth.currentUser;

  if (user == null) {
    return null;
  }

  try {
    print('[UpcomingSessionProvider] Fetching next confirmed booking for user: ${user.id}');
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day).toIso8601String();

    // 1. Fetch the earliest confirmed booking for the user
    final bookingResponse = await supabaseClient
        .from('bookings')
        .select('session_id, session_date, session_start_time, session_end_time')
        .eq('user_id', user.id)
        .eq('status', BookingStatus.confirmed.name)
        .gte('session_date', todayDate) // Sessions from today onwards
        // Additional check for end time might be needed if sessions can span midnight or if we want to exclude past sessions on the same day
        .order('session_date', ascending: true)
        .order('session_start_time', ascending: true)
        .limit(1)
        .maybeSingle();

    if (bookingResponse == null) {
      print('[UpcomingSessionProvider] No upcoming confirmed bookings found.');
      return null;
    }

    print('[UpcomingSessionProvider] Found booking: $bookingResponse');
    final String sessionId = bookingResponse['session_id'];

    // 2. Fetch session details using session_id from the booking
    print('[UpcomingSessionProvider] Fetching session details for session_id: $sessionId');
    final sessionDetailsResponse = await supabaseClient
        .from('sessions')
        .select('category, start_time_of_day, end_time_of_day, day_of_week') // Add other fields if needed by the card
        .eq('id', sessionId)
        .single(); // Assuming session_id is unique and exists

    print('[UpcomingSessionProvider] Found session details: $sessionDetailsResponse');

    // 3. Combine booking and session details
    // The card expects 'date', 'time', 'category'.
    // 'date' comes from bookingResponse['session_date']
    // 'time' needs to be formatted from bookingResponse['session_start_time'] and bookingResponse['session_end_time']
    // 'category' comes from sessionDetailsResponse['category']

    // Note: The original UpcomingSessionCard used sessionDetailsResponse['time'] directly.
    // We need to ensure the 'time' field is constructed correctly based on what the card expects.
    // For now, let's pass the raw times and let the card format them, or adjust the card later.

    return {
      'session_date': bookingResponse['session_date'], // This will be used as 'date' in the card
      'session_start_time': bookingResponse['session_start_time'],
      'session_end_time': bookingResponse['session_end_time'],
      'category': sessionDetailsResponse['category'],
      // Add other necessary fields from sessionDetailsResponse if the card uses them
      // e.g., 'day_of_week': sessionDetailsResponse['day_of_week'],
    };

  } catch (e, s) {
    print('[UpcomingSessionProvider] Error fetching upcoming session: $e\n$s');
    // It's important to rethrow or handle the error appropriately so the UI can show an error state.
    // If single() fails because no session is found for a valid booking's session_id, that's a data integrity issue.
    rethrow;
  }
});
