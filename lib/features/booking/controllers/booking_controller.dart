import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/services/supabase_service.dart';
import 'package:heronfit/core/utils/logger.dart';
import 'package:postgrest/postgrest.dart';

final bookingControllerProvider =
    NotifierProvider<BookingController, AsyncValue<void>>(BookingController.new);

class BookingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    // Initial state
    return const AsyncValue.data(null);
  }

  /// Validates the ticket ID and checks if it can be used for booking
  Future<bool> validateTicket(String ticketId) async {
    try {
      state = const AsyncValue.loading();

      // Get the current user ID
      final currentUser = SupabaseService().client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if ticket exists and is valid
      try {
        final ticketResponse = await SupabaseService().client
            .from('tickets')
            .select('*')
            .eq('id', ticketId)
            .single();

        // If we get here, the ticket exists
        // Check if ticket is associated with the current user
        if (ticketResponse['user_id'] != currentUser.id) {
          throw Exception(
              'This Ticket ID isn\'t linked to your account. Please ensure you\'re logged in with the correct account or contact support.');
        }

        // Check if ticket is active
        if (ticketResponse['status'] != 'active') {
          if (ticketResponse['status'] == 'used') {
            throw Exception('This Ticket ID has already been used for a session. Please purchase a new pass to book.');
          } else if (ticketResponse['status'] == 'expired') {
            throw Exception('This Ticket ID has expired. Please purchase a new pass.');
          } else {
            throw Exception('This Ticket ID is not valid for booking.');
          }
        }

        // Mark ticket as pending booking
        await SupabaseService().client
            .from('tickets')
            .update({'status': 'pending_booking'})
            .eq('id', ticketId);
            
        return true;
      } on PostgrestException catch (e) {
        // If we get here, the ticket doesn't exist or there was an error
        if (e.code == 'PGRST116') {
          // PGRST116 is the code for no rows returned
          throw Exception('Invalid Ticket ID. Please check your entry and try again.');
        }
        // Re-throw any other errors
        rethrow;
      }
    } catch (e) {
      logger.e('Error validating ticket', error: e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Reset the controller state
  void reset() {
    state = const AsyncValue.data(null);
  }
}
