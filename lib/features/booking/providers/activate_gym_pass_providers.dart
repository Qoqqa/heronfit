// d:\Development\heronfit\lib\features\booking\providers\activate_gym_pass_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_ticket_model.dart';
import '../services/booking_supabase_service.dart';

// Provider for BookingSupabaseService
final bookingSupabaseServiceProvider = Provider<BookingSupabaseService>((ref) {
  final supabaseClient = Supabase.instance.client;
  return BookingSupabaseService(supabaseClient);
});

// State Notifier for activating gym pass and managing its state
class ActivateGymPassNotifier extends StateNotifier<AsyncValue<UserTicket?>> {
  final BookingSupabaseService _bookingService;
  final String _userId; // Assuming userId is available, e.g., from an auth provider
  UserTicket? _activatedTicket; // To keep track of the ticket being processed

  ActivateGymPassNotifier(this._bookingService, this._userId) : super(const AsyncValue.data(null));

  Future<void> activateAndFindSessions(String ticketCode) async {
    state = const AsyncValue.loading();
    print('[ActivateGymPassNotifier] Attempting to activate ticket: $ticketCode for user: $_userId');
    try {
      // For demo, assuming a fixed userId. In a real app, get this from auth state.
      // final userId = ref.watch(authProvider).currentUser?.id;
      // if (userId == null) throw Exception('User not authenticated.');

      final ticket = await _bookingService.validateAndPrepareTicketForBooking(ticketCode, _userId);
      _activatedTicket = ticket; // Store the ticket that is now pending_booking
      print('[ActivateGymPassNotifier] Ticket validation successful: ${ticket.toJson()}');
      state = AsyncValue.data(ticket);
    } catch (e, s) {
      print('[ActivateGymPassNotifier] ERROR during ticket activation: ${e.toString()}');
      print('[ActivateGymPassNotifier] Stack Trace: $s');
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> revertTicketToActive() async {
    if (_activatedTicket != null) {
      print('[ActivateGymPassNotifier] Attempting to revert ticket: ${_activatedTicket!.ticketCode}');
      try {
        // Assuming the original status before 'pending_booking' was 'available'.
        // For a more robust solution, the original status could be stored before changing to pending_booking.
        await _bookingService.revertTicketToActive(_activatedTicket!.id, TicketStatus.available);
        print('[ActivateGymPassNotifier] Ticket ${_activatedTicket!.ticketCode} reverted to available.');
        _activatedTicket = null; // Clear the stored ticket
        state = const AsyncValue.data(null); // Reset state or to an appropriate non-error state
      } catch (e, s) {
        print('[ActivateGymPassNotifier] ERROR reverting ticket: ${e.toString()}');
        print('[ActivateGymPassNotifier] Stack Trace: $s');
        // state = AsyncValue.error('Failed to revert ticket: $e', StackTrace.current);
      }
    }
  }

  // Override onDispose to ensure ticket status is reverted if provider is disposed
  // while a ticket is in 'pending_booking' state.
  @override
  void dispose() {
    print('[ActivateGymPassNotifier] Disposing. Checking for pending ticket...');
    if (_activatedTicket != null && _activatedTicket!.status == TicketStatus.pending_booking) {
      print('[ActivateGymPassNotifier] dispose: Reverting ticket ${_activatedTicket!.ticketCode}');
      revertTicketToActive(); // Attempt to revert status
    }
    super.dispose();
  }

  // Add this method for confirming receipt number for an existing booking
  Future<void> confirmReceiptForExistingBooking({
    required String ticketCode,
    required String bookingId,
    required String sessionId,
    required String sessionDate,
    required String sessionStartTime,
    required String sessionEndTime,
    required String sessionCategory,
  }) async {
    state = const AsyncValue.loading();
    print('[ActivateGymPassNotifier] Confirming receipt for existing booking: $bookingId, ticket: $ticketCode');
    try {
      // Validate the ticket (this will also set it to pending_booking)
      final ticket = await _bookingService.validateAndPrepareTicketForBooking(ticketCode, _userId);
      _activatedTicket = ticket;
      print('[ActivateGymPassNotifier] Ticket validated for existing booking: \\${ticket.toJson()}\\');
      // Call bookSession with bookingId to update the booking
      await _bookingService.bookSession(
        sessionId: sessionId,
        userId: _userId,
        activatedTicketId: ticket.id,
        sessionDate: sessionDate,
        sessionStartTime: sessionStartTime,
        sessionEndTime: sessionEndTime,
        sessionCategory: sessionCategory,
        bookingId: bookingId,
      );
      state = AsyncValue.data(ticket);
    } catch (e, s) {
      print('[ActivateGymPassNotifier] ERROR during confirmReceiptForExistingBooking: \\${e.toString()}\\');
      print('[ActivateGymPassNotifier] Stack Trace: $s');
      state = AsyncValue.error(e, s);
    }
  }
}

// Provider for ActivateGymPassNotifier
final activateGymPassStateProvider = StateNotifierProvider.autoDispose<ActivateGymPassNotifier, AsyncValue<UserTicket?>>((ref) {
  final bookingService = ref.watch(bookingSupabaseServiceProvider);
  
  // Get the currently authenticated Supabase user
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  
  if (supabaseUser == null) {
    print('[ActivateGymPassStateProvider] Error: No authenticated user found.');
    // If no user is logged in, the notifier cannot function correctly with user-specific data.
    // Return an error state or throw an exception. For now, let's make the notifier handle this internally or throw.
    // This situation should ideally be prevented by UI flow (e.g., user must be logged in to reach this screen).
    // Alternatively, the notifier could take a nullable userId and handle it, 
    // but for ticket validation, a userId is essential.
    throw Exception('User not authenticated. Cannot initialize ticket activation.');
  }
  final String currentUserId = supabaseUser.id;
  print('[ActivateGymPassStateProvider] Initializing Notifier for user: $currentUserId');
  
  final notifier = ActivateGymPassNotifier(bookingService, currentUserId);
  
  // Optional: Handle disposal if needed, though autoDispose might cover it.
  // ref.onDispose(() {
  //   // Logic from previous snippet if necessary for reverting ticket status
  // });

  return notifier;
});
