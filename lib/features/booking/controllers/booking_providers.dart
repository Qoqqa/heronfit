import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/services/booking_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Session; // For SupabaseClient

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
