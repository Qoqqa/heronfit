import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

/// Checks if the current user has an active (confirmed) booking for today or a future date.
/// Returns the [Booking] object if an active booking exists, otherwise null.
final activeBookingCheckProvider = FutureProvider<Booking?>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final userId = supabaseClient.auth.currentUser?.id;

  if (userId == null) {
    // Not logged in, so no active booking
    return null;
  }

  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);

  try {
    final response = await supabaseClient
        .from('bookings')
        .select('*, sessions(*)') // Assuming you want session details too
        .eq('user_id', userId)
        .eq('status', BookingStatus.confirmed.name) 
        .gte('session_date', todayDateOnly.toIso8601String()) // Check from today onwards
        .order('session_date', ascending: true)
        .order('session_start_time', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response != null && response.isNotEmpty) {
      return Booking.fromJson(response);
    }
    return null;
  } catch (e) {
    // Handle or log error as appropriate
    print('Error checking for active booking: $e');
    return null; // Or throw an exception if you want to handle it differently upstream
  }
});
