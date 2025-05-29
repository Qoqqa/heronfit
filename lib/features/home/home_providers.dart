import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/features/booking/models/booking_status.dart'; // Import BookingStatus

/// Provider to fetch the next upcoming booked session for the current user.
///
/// Returns a [Map<String, dynamic>] representing the combined booking and session data,
/// or null if no upcoming booked session is found or if the user is not authenticated.
final upcomingSessionProvider = FutureProvider.autoDispose<
  Map<String, dynamic>?
>((ref) async {
  final supabaseClient = Supabase.instance.client;
  final user = supabaseClient.auth.currentUser;

  if (user == null) {
    return null;
  }

  try {
    print(
      '[UpcomingSessionProvider] Fetching next confirmed booking for user: ${user.id}',
    );
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day).toIso8601String();

    // 1. Fetch the earliest confirmed booking for the user
    final bookingResponse =
        await supabaseClient
            .from('bookings')
            .select(
              'session_id, session_date, session_start_time, session_end_time',
            )
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
    print(
      '[UpcomingSessionProvider] Fetching session details for session_id: $sessionId',
    );
    final sessionDetailsResponse =
        await supabaseClient
            .from('sessions')
            .select(
              'category, start_time_of_day, end_time_of_day, day_of_week',
            ) // Add other fields if needed by the card
            .eq('id', sessionId)
            .single(); // Assuming session_id is unique and exists

    print(
      '[UpcomingSessionProvider] Found session details: $sessionDetailsResponse',
    );

    // 3. Combine booking and session details
    // The card expects 'date', 'time', 'category'.
    // 'date' comes from bookingResponse['session_date']
    // 'time' needs to be formatted from bookingResponse['session_start_time'] and bookingResponse['session_end_time']
    // 'category' comes from sessionDetailsResponse['category']

    // Note: The original UpcomingSessionCard used sessionDetailsResponse['time'] directly.
    // We need to ensure the 'time' field is constructed correctly based on what the card expects.
    // For now, let's pass the raw times and let the card format them, or adjust the card later.

    return {
      'session_date':
          bookingResponse['session_date'], // This will be used as 'date' in the card
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

/// Provider to fetch the next available gym session slot for the current day.
///
/// Returns a [Map<String, dynamic>] representing the session data (including
/// date, start/end times, category, capacity, booked_slots), or null if no
/// sessions are available for the rest of today.
final nextAvailableGymSessionProvider = FutureProvider.autoDispose<
  Map<String, dynamic>?
>((ref) async {
  final supabaseClient = Supabase.instance.client;
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final todayDateString = todayDate.toIso8601String().substring(
    0,
    10,
  ); // YYYY-MM-DD
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final String currentDayOfWeek = days[now.weekday - 1];

  try {
    // 1. Fetch all session_occurrences for today (not ended)
    final occurrences = await supabaseClient
        .from('session_occurrences')
        .select(
          'id, session_id, date, booked_slots, override_capacity, status, start_time_of_day, end_time_of_day, category, session_name',
        )
        .eq('date', todayDateString)
        .eq('status', 'scheduled');

    if (occurrences == null || occurrences.isEmpty) {
      print(
        '[NextAvailableGymSessionProvider] No session_occurrences for today.',
      );
      return null;
    }

    // 2. Fetch session templates for these occurrences (for extra info if needed)
    final sessionIds =
        occurrences.map((o) => o['session_id'] as String).toSet().toList();
    final sessionTemplates = await supabaseClient
        .from('sessions')
        .select(
          'id, category, capacity, start_time_of_day, end_time_of_day, notes',
        )
        .inFilter('id', sessionIds);
    final sessionTemplateMap = {for (var s in sessionTemplates) s['id']: s};

    // 3. Filter out sessions that have already ended
    DateTime parseTime(String timeStr, DateTime date) {
      final parts = timeStr.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    final List<Map<String, dynamic>> available = [];
    for (final occ in occurrences) {
      final endTime = parseTime(occ['end_time_of_day'] as String, todayDate);
      if (endTime.isAfter(now)) {
        final template = sessionTemplateMap[occ['session_id']];
        available.add({
          'id': occ['id'],
          'session_id': occ['session_id'],
          'session_date_actual': todayDate,
          'start_time_of_day': occ['start_time_of_day'],
          'end_time_of_day': occ['end_time_of_day'],
          'category': occ['category'] ?? template?['category'],
          'capacity': occ['override_capacity'] ?? template?['capacity'],
          'booked_slots': occ['booked_slots'],
          'session_name': occ['session_name'] ?? template?['notes'],
        });
      }
    }
    if (available.isEmpty) {
      print(
        '[NextAvailableGymSessionProvider] No available sessions found for the rest of today.',
      );
      return null;
    }
    // 4. Sort by start time and return the next available
    available.sort(
      (a, b) => parseTime(
        a['start_time_of_day'],
        todayDate,
      ).compareTo(parseTime(b['start_time_of_day'], todayDate)),
    );
    final session = available.first;
    print(
      '[NextAvailableGymSessionProvider] Next available session: ${session['id']} at ${session['start_time_of_day']}',
    );
    return session;
  } catch (e, s) {
    print(
      '[NextAvailableGymSessionProvider] Error fetching next available gym session: $e\n$s',
    );
    rethrow;
  }
});
