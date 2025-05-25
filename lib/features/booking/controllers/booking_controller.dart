import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingControllerProvider = StateNotifierProvider<BookingController, AsyncValue<void>>(
  (ref) => BookingController(),
);

class BookingController extends StateNotifier<AsyncValue<void>> {
  // Use the global logger instance from core/utils/logger.dart
  
  BookingController() : super(const AsyncValue.data(null));
  
  // Get the current state
  AsyncValue<void> get currentState => state;
  
  // Set the state
  void setState(AsyncValue<void> newState) {
    if (mounted) {
      state = newState;
    }
  }

  /// Validates the ticket ID and checks if it can be used for booking
  Future<bool> validateTicket(String ticketId) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock User ID - replace with actual logged-in user ID logic later
    const currentUserId = 'user123'; // For mock purposes

    final ticketData = _getMockTicket(ticketId);

    if (ticketData == null) {
      state = AsyncValue.error('Ticket ID not found.', StackTrace.current);
      return false;
    }
    if (ticketData['userId'] != currentUserId) {
      state = AsyncValue.error('This ticket does not belong to you.', StackTrace.current);
      return false;
    }
    if (ticketData['status'] == 'used') {
      state = AsyncValue.error('This ticket has already been used.', StackTrace.current);
      return false;
    }
    if (ticketData['status'] == 'expired') {
      state = AsyncValue.error('This ticket has expired.', StackTrace.current);
      return false;
    }
    if (ticketData['status'] == 'active') {
      // Optional: Store activated ticket info if needed, e.g., in another provider
      // ref.read(activatedTicketProvider.notifier).state = ticketId;
      // You might also want to store/check the 'isFaculty' flag from ticketData here
      // if it influences the next steps or available sessions.
      state = const AsyncValue.data(null); // Success
      return true;
    }

    // Default fallback error if status is unknown or not 'active'
    state = AsyncValue.error('Invalid ticket status or unknown error.', StackTrace.current);
    return false;
  }
  
  // Helper method to get mock ticket data
  Map<String, dynamic>? _getMockTicket(String ticketId) {
    // Define mock tickets with ARNO2025 prefix and numeric IDs
    final mockTickets = {
      'ARNO20251111111': {'id': 'ARNO20251111111', 'status': 'active', 'userId': 'user123', 'isFaculty': false},
      'ARNO20252222222': {'id': 'ARNO20252222222', 'status': 'used', 'userId': 'user123', 'isFaculty': false},
      'ARNO20253333333': {'id': 'ARNO20253333333', 'status': 'expired', 'userId': 'user123', 'isFaculty': false},
      'ARNO20254444444': {'id': 'ARNO20254444444', 'status': 'active', 'userId': 'otherUser999', 'isFaculty': false}, // Belongs to another user
      'ARNO20255555555': {'id': 'ARNO20255555555', 'status': 'active', 'userId': 'user123', 'isFaculty': true}, // Faculty ticket for testing faculty-only sessions
    };
    
    return mockTickets[ticketId];
  }

  // Reset the controller state
  void reset() {
    state = const AsyncValue.data(null);
  }
}
