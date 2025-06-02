import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';
import 'package:heronfit/features/booking/models/booking_status.dart';

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
    // 1. Mark any expired pending bookings as no_show
    final pendingBookings = await supabaseClient
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('status', BookingStatus.pending.name)
        .gte('session_date', todayDateOnly.toIso8601String());
    for (final bookingData in pendingBookings) {
      try {
        final booking = Booking.fromJson(bookingData);
        final sessionEndTimeParts = booking.sessionEndTime.split(':');
        final sessionEndDateTime = DateTime(
          booking.sessionDate.year,
          booking.sessionDate.month,
          booking.sessionDate.day,
          int.parse(sessionEndTimeParts[0]),
          int.parse(sessionEndTimeParts[1]),
          sessionEndTimeParts.length > 2 ? int.parse(sessionEndTimeParts[2]) : 0,
        );
        if (sessionEndDateTime.isBefore(today)) {
          await supabaseClient
              .from('bookings')
              .update({'status': BookingStatus.no_show.name})
              .eq('id', booking.id);
        }
      } catch (_) {}
    }

    // 2. Only consider confirmed bookings as active
    final response = await supabaseClient
        .from('bookings')
        .select('*, sessions(*)')
        .eq('user_id', userId)
        .eq('status', BookingStatus.confirmed.name)
        .gte('session_date', todayDateOnly.toIso8601String())
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
