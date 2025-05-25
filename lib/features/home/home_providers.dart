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

/// Provider to fetch the next available gym session slot for the current day.
///
/// Returns a [Map<String, dynamic>] representing the session data (including
/// date, start/end times, category, capacity, booked_slots), or null if no
/// sessions are available for the rest of today.
final nextAvailableGymSessionProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final supabaseClient = Supabase.instance.client;
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final todayDateString = todayDate.toIso8601String().substring(0, 10); // YYYY-MM-DD
  // Ensure 'intl' is imported if not already: import 'package:intl/intl.dart';
  // For DayFormat, it should be at the top of the file or in a shared utility
  // For now, assuming DateFormat is available or will be added.
  // final String currentDayOfWeek = DateFormat('EEEE').format(now); // e.g., Monday, Tuesday
  // Supabase stores day_of_week like 'Monday', 'Tuesday'. Ensure this matches.
  // Let's get day_of_week string correctly for Supabase. Flutter's DateFormat('EEEE') is locale-dependent.
  // A more robust way for direct Supabase query if day_of_week is standard English:
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final String currentDayOfWeek = days[now.weekday - 1];

  // Helper to parse time string (HH:mm:ss) into DateTime for a given date
  DateTime parseTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  List<Map<String, dynamic>> allPotentialSessions = [];

  try {
    // 1. Fetch active recurring sessions for today
    print('[NextAvailableGymSessionProvider] Fetching recurring sessions for $currentDayOfWeek');
    final recurringResponse = await supabaseClient
        .from('sessions')
        .select('id, day_of_week, start_time_of_day, end_time_of_day, category, capacity, booked_slots')
        .eq('day_of_week', currentDayOfWeek)
        .filter('override_date', 'is', null) // Corrected: Ensure it's a recurring session
        .eq('is_active', true);

    for (var sessionData in recurringResponse) {
      final sessionEndTime = parseTime(sessionData['end_time_of_day'] as String, todayDate);
      if (sessionEndTime.isAfter(now)) { // Only consider sessions that haven't ended
        allPotentialSessions.add({
          ...sessionData,
          'session_date_actual': todayDate, // Actual date for this instance
          'start_datetime_actual': parseTime(sessionData['start_time_of_day'] as String, todayDate),
        });
      }
    }
    print('[NextAvailableGymSessionProvider] Found ${allPotentialSessions.length} potential recurring sessions for today.');

    // 2. Fetch active override sessions for today
    print('[NextAvailableGymSessionProvider] Fetching override sessions for $todayDateString');
    final overrideResponse = await supabaseClient
        .from('sessions')
        .select('id, day_of_week, start_time_of_day, end_time_of_day, category, capacity, booked_slots, override_date')
        .eq('override_date', todayDateString)
        .eq('is_active', true);

    int overrideCount = 0;
    for (var sessionData in overrideResponse) {
      final sessionEndTime = parseTime(sessionData['end_time_of_day'] as String, todayDate);
      if (sessionEndTime.isAfter(now)) { // Only consider sessions that haven't ended
        // Remove any recurring session that this override might replace (same start time on same day)
        // This is a simplification; true override logic might be more complex (e.g. if an override changes capacity of a recurring slot)
        // For now, we assume an override is a distinct session or fully replaces a recurring one at the same time.
        final overrideStartTime = parseTime(sessionData['start_time_of_day'] as String, todayDate);
        allPotentialSessions.removeWhere((recurring) => 
            recurring['day_of_week'] == sessionData['day_of_week'] && 
            recurring['start_datetime_actual'] == overrideStartTime &&
            recurring['override_date'] == null // ensure it's a recurring one we are removing
        );
        allPotentialSessions.add({
          ...sessionData,
          'session_date_actual': DateTime.parse(sessionData['override_date'] as String),
          'start_datetime_actual': overrideStartTime,
        });
        overrideCount++;
      }
    }
    print('[NextAvailableGymSessionProvider] Found $overrideCount potential override sessions for today.');

    if (allPotentialSessions.isEmpty) {
      print('[NextAvailableGymSessionProvider] No available sessions found for the rest of today.');
      return null;
    }

    // 3. Sort all potential sessions by their actual start time
    allPotentialSessions.sort((a, b) => 
        (a['start_datetime_actual'] as DateTime).compareTo(b['start_datetime_actual'] as DateTime));

    // 4. Find the first session that hasn't started yet or is ongoing but not ended
    // The filtering for end_time_of_day.isAfter(now) already handled ended sessions.
    // Now we just need the first one in the sorted list whose start_time is also after now, or if none, the current one if it hasn't ended.
    
    for (final session in allPotentialSessions) {
        // If a session's start_datetime_actual is in the future, it's the next one.
        // Or, if it has started (start_datetime_actual.isBefore(now)) but its end_time (calculated from end_time_of_day) is still after now, it's current.
        // The initial filter (sessionEndTime.isAfter(now)) ensures we only have sessions that are not yet over.
        // So, the first one in the sorted list is our candidate.
        print('[NextAvailableGymSessionProvider] Next available session: ${session['id']} at ${session['start_time_of_day']}');
        return {
          'id': session['id'],
          'session_date_actual': session['session_date_actual'], // DateTime object
          'start_time_of_day': session['start_time_of_day'], // String 'HH:mm:ss'
          'end_time_of_day': session['end_time_of_day'],     // String 'HH:mm:ss'
          'category': session['category'],
          'capacity': session['capacity'],
          'booked_slots': session['booked_slots'],
          'day_of_week': session['day_of_week'], // Might be from recurring or override
        };
    }
    
    print('[NextAvailableGymSessionProvider] No suitable upcoming session found after sorting and final check.');
    return null; // Should not be reached if allPotentialSessions was not empty and sorting worked

  } catch (e, s) {
    print('[NextAvailableGymSessionProvider] Error fetching next available gym session: $e\n$s');
    rethrow;
  }
});
