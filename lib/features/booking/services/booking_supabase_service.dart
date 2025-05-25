// d:\Development\heronfit\lib\features\booking\services\booking_supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' hide Session; // Hide Supabase's Session
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/models/user_ticket_model.dart';
import 'package:heronfit/features/booking/models/booking_status.dart'; // Added import
import 'package:heronfit/features/booking/models/active_booking_exists_exception.dart'; // Import custom exception
import 'package:intl/intl.dart';      // Added import for DateFormat

class BookingSupabaseService {
  final SupabaseClient _supabaseClient;

  BookingSupabaseService(this._supabaseClient);

  Future<UserTicket> validateAndPrepareTicketForBooking(String ticketCode, String userId) async {
    print('[BookingSupabaseService] Validating ticket. Code: $ticketCode, UserID: $userId');
    try {
      // 1. Fetch the ticket by ticketCode
      print('[BookingSupabaseService] Fetching ticket from Supabase...');
      final response = await _supabaseClient
          .from('user_tickets')
          .select()
          .eq('ticket_code', ticketCode)
          .single();
      print('[BookingSupabaseService] Supabase response: $response');

      final UserTicket ticket = UserTicket.fromJson(response);
      print('[BookingSupabaseService] Parsed ticket: ${ticket.toJson()}');

      // 2. Validate ticket ownership
      print('[BookingSupabaseService] Validating ticket ownership...');
      if (ticket.userId != userId) {
        print('[BookingSupabaseService] ERROR: Ticket user ID (${ticket.userId}) does not match provided user ID ($userId).');
        throw Exception("This Ticket ID isn't linked to your account. Please ensure you're logged in with the correct account or contact support.");
      }
      print('[BookingSupabaseService] Ticket ownership validated.');

      // 3. Validate ticket status (must be 'available')
      print('[BookingSupabaseService] Validating ticket status. Current status: ${ticket.status}');
      if (ticket.status != TicketStatus.available) {
        String errorMessage;
        switch (ticket.status) {
          case TicketStatus.used:
            errorMessage = "This Ticket ID has already been used for a session. Please purchase a new pass to book.";
            break;
          case TicketStatus.expired:
            errorMessage = "This Ticket ID has expired. Please purchase a new pass.";
            break;
          case TicketStatus.pending_booking:
            errorMessage = "This ticket is currently being processed. Please try again shortly or check 'My Bookings'.";
            break;
          default: // For any other status that isn't 'available'
            errorMessage = "Invalid Ticket ID. Please check your entry and try again.";
            break;
        }
        print('[BookingSupabaseService] ERROR: Ticket status is not available. Status: ${ticket.status}');
        throw Exception(errorMessage);
      }
      print('[BookingSupabaseService] Ticket status validated as available.');

      // 4. Validate ticket expiry date
      print('[BookingSupabaseService] Validating ticket expiry date. Expiry: ${ticket.expiryDate}');
      if (ticket.expiryDate != null && ticket.expiryDate!.isBefore(DateTime.now())) {
        print('[BookingSupabaseService] ERROR: Ticket has expired. Expiry date: ${ticket.expiryDate}');
        // Optionally update status to 'expired' in DB if it's not already
        // This is a good practice to keep data consistent.
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.expired.name})
            .eq('id', ticket.id);
        ticket.status = TicketStatus.expired; // Update local object
        throw Exception("This Ticket ID has expired. Please purchase a new pass.");
      }
      print('[BookingSupabaseService] Ticket expiry date validated.');

      // 5. Update ticket status to 'pending_booking'
      print('[BookingSupabaseService] Updating ticket status to pending_booking for ticket ID: ${ticket.id}');
      await _supabaseClient
          .from('user_tickets')
          .update({'status': TicketStatus.pending_booking.name})
          .eq('id', ticket.id);
      ticket.status = TicketStatus.pending_booking; // Update local object status
      print('[BookingSupabaseService] Ticket status updated to pending_booking successfully.');

      return ticket;

    } on PostgrestException catch (e, s) {
      print('[BookingSupabaseService] PostgrestException: ${e.message}, code: ${e.code}');
      print('[BookingSupabaseService] Stack Trace: $s');
      if (e.code == 'PGRST116') { // PGRST116: The result contains 0 rows
        throw Exception("Invalid Ticket ID. Please check your entry and try again.");
      }
      // For other Postgrest errors that are not specifically handled above
      throw Exception("An unexpected error occurred. Please try again later.");
    } catch (e, s) {
      print('[BookingSupabaseService] Generic Exception: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      // If the exception is one of our specific, intentionally thrown messages, rethrow it.
      // For Exception type, the message is obtained via toString().
      if (e is Exception && (
          e.toString() == "Exception: This Ticket ID isn't linked to your account. Please ensure you're logged in with the correct account or contact support." ||
          e.toString() == "Exception: This Ticket ID has already been used for a session. Please purchase a new pass to book." ||
          e.toString() == "Exception: This Ticket ID has expired. Please purchase a new pass." ||
          e.toString() == "Exception: This ticket is currently being processed. Please try again shortly or check 'My Bookings'." ||
          e.toString() == "Exception: Invalid Ticket ID. Please check your entry and try again."
      )) {
        rethrow;
      }
      // For any other unforeseen errors (e.g., UserTicket.fromJson failure, other programming errors)
      throw Exception("An unexpected error occurred. Please try again later.");
    }
  }

  Future<void> revertTicketToActive(String ticketId, TicketStatus originalStatus) async {
    print('[BookingSupabaseService] Reverting ticket ID $ticketId to status ${originalStatus.name}');
    try {
      await _supabaseClient
          .from('user_tickets')
          .update({'status': originalStatus.name})
          .eq('id', ticketId)
          .eq('status', TicketStatus.pending_booking.name); 
      print('[BookingSupabaseService] Ticket $ticketId reverted successfully.');
    } catch (e, s) {
      print('[BookingSupabaseService] Error reverting ticket status for $ticketId: $e');
      print('[BookingSupabaseService] Stack Trace: $s');
    }
  }

  // Updated method to fetch sessions for a given date using the new schema
  Future<List<Session>> getSessionsForDate(DateTime date) async {
    final String targetDayOfWeek = DateFormat('EEEE').format(date); // e.g., "Monday"
    final String targetDateIso = DateFormat('yyyy-MM-dd').format(date); // e.g., "2025-05-29"

    print('[BookingSupabaseService] Fetching sessions for date: $targetDateIso (Day: $targetDayOfWeek)');

    const String selectColumns = 
      'id, day_of_week, start_time_of_day, end_time_of_day, category, capacity, booked_slots, is_active, override_date, notes';

    try {
      // 1. Fetch active recurring sessions for the target day_of_week
      final recurringResponse = await _supabaseClient
          .from('sessions')
          .select(selectColumns)
          .eq('day_of_week', targetDayOfWeek)
          .filter('override_date', 'is', null) // Correct way to filter for IS NULL
          .eq('is_active', true)
          .order('start_time_of_day', ascending: true);

      print('[BookingSupabaseService] Recurring sessions response: $recurringResponse');
      final List<Session> recurringSessions = (recurringResponse as List)
          .map((data) => Session.fromJson(data as Map<String, dynamic>))
          .toList();
      print('[BookingSupabaseService] Parsed ${recurringSessions.length} recurring sessions.');

      // 2. Fetch active override sessions for the target_date
      final overrideResponse = await _supabaseClient
          .from('sessions')
          .select(selectColumns)
          .eq('override_date', targetDateIso)
          .eq('is_active', true)
          .order('start_time_of_day', ascending: true);

      print('[BookingSupabaseService] Override sessions response: $overrideResponse');
      final List<Session> overrideSessions = (overrideResponse as List)
          .map((data) => Session.fromJson(data as Map<String, dynamic>))
          .toList();
      print('[BookingSupabaseService] Parsed ${overrideSessions.length} override sessions.');

      // 3. Combine and de-duplicate/prioritize (simple combination for now)
      // A more sophisticated merge would replace recurring with overrides for the same time slot.
      // For now, we'll combine and sort. The UI might show both if not handled carefully.
      
      // Create a map of recurring sessions by their start time for easy lookup
      final Map<String, Session> sessionMap = {
        for (var session in recurringSessions) session.startTime.toString(): session
      };

      // Add or replace with override sessions
      for (var override in overrideSessions) {
        sessionMap[override.startTime.toString()] = override; // Override will replace recurring if same start time
      }

      final List<Session> combinedSessions = sessionMap.values.toList();
      
      // Sort the final list by start time
      combinedSessions.sort((a, b) => 
          (a.startTime.hour * 60 + a.startTime.minute)
              .compareTo(b.startTime.hour * 60 + b.startTime.minute));

      print('[BookingSupabaseService] Combined and sorted ${combinedSessions.length} sessions.');
      return combinedSessions;

    } catch (e, stackTrace) {
      print('[BookingSupabaseService] Exception while fetching sessions: $e');
      print('[BookingSupabaseService] Stack Trace: $stackTrace');
      // Consider rethrowing a custom exception or returning an empty list with error state
      // For now, rethrow to allow UI to handle via FutureProvider's error state.
      rethrow; 
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required String sessionId,
    required String userId,
    String? activatedTicketId,
    required String sessionDate,       // Expected format: 'yyyy-MM-dd'
    required String sessionStartTime,  // Expected format: 'HH:mm:ss' or 'HH:mm'
    required String sessionEndTime,    // Expected format: 'HH:mm:ss' or 'HH:mm'
    required String sessionCategory,
  }) async {
    print('[BookingSupabaseService] Attempting to book session. UserID: $userId, SessionID: $sessionId, Date: $sessionDate, Start: $sessionStartTime, End: $sessionEndTime, Category: $sessionCategory, TicketID: $activatedTicketId');

    // 1. Check for existing active bookings
    try {
      print('[BookingSupabaseService] Checking for existing active bookings for user $userId...');
      final now = DateTime.now();
      final existingBookingsResponse = await _supabaseClient
          .from('bookings')
          .select('id, session_date, session_end_time, status') // Select necessary fields
          .eq('user_id', userId)
          .eq('status', BookingStatus.confirmed.name);

      print('[BookingSupabaseService] Found potential existing bookings: $existingBookingsResponse');

      if (existingBookingsResponse.isNotEmpty) {
        for (var bookingData in existingBookingsResponse) {
          final String bookingDateStr = bookingData['session_date'] as String;
          final String bookingEndTimeStr = bookingData['session_end_time'] as String;
          
          // Combine date and time strings and parse. Ensure robust parsing.
          // Assuming session_date is 'YYYY-MM-DD' and session_end_time is 'HH:mm:ss' or 'HH:mm'
          try {
            final bookingEndDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse("$bookingDateStr $bookingEndTimeStr");
            if (bookingEndDateTime.isAfter(now)) {
              print('[BookingSupabaseService] ERROR: User $userId already has an active booking (ID: ${bookingData['id']}) that ends at $bookingEndDateTime.');
              throw ActiveBookingExistsException();
            }
          } catch (e) {
            print('[BookingSupabaseService] WARN: Could not parse date/time for existing booking ${bookingData['id']}: $bookingDateStr $bookingEndTimeStr. Error: $e. Skipping this check for this booking.');
            // Decide if this should be a critical error or if we proceed cautiously.
            // For now, we'll log and skip, meaning a malformed existing booking might not block a new one.
          }
        }
      }
      print('[BookingSupabaseService] No conflicting active bookings found for user $userId.');
    } on ActiveBookingExistsException {
      rethrow; // Rethrow the specific exception to be caught by the notifier
    } catch (e, s) {
      print('[BookingSupabaseService] Error during active booking check: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      // Optionally, rethrow as a generic booking exception or handle as a critical failure
      throw Exception('Failed to verify existing bookings: ${e.toString()}');
    }

    // 2. Proceed with booking if no active booking found
    print('[BookingSupabaseService] Proceeding with booking logic...');
    try {
      // Start a transaction
      // Note: True database transactions across multiple operations like this are best handled by a database function (RPC).
      // For client-side, we're performing sequential operations. If one fails, subsequent ones won't run,
      // but there isn't an automatic rollback of prior successful operations in this client-side sequence.

      // 1. Increment booked_slots in the sessions table
      print('[BookingSupabaseService] Incrementing booked_slots for session $sessionId...');
      final Session sessionData = await _supabaseClient
          .from('sessions')
          .select('booked_slots, capacity')
          .eq('id', sessionId)
          .single() // Expects a single row
          .then((response) => Session.fromMap(response)); // Assuming Session.fromMap exists

      if (sessionData.bookedSlots >= sessionData.capacity) {
        print('[BookingSupabaseService] Booking failed: Session $sessionId is full.');
        throw Exception('Session is full. Cannot book.');
      }

      await _supabaseClient
          .from('sessions')
          .update({'booked_slots': sessionData.bookedSlots + 1})
          .eq('id', sessionId);
      print('[BookingSupabaseService] booked_slots incremented for session $sessionId.');

      // 2. Create a booking record in the bookings table
      print('[BookingSupabaseService] Creating booking record...');
      final bookingResponse = await _supabaseClient.from('bookings').insert({
        'user_id': userId,
        'session_id': sessionId,
        'user_ticket_id': activatedTicketId, // Changed from 'ticket_id'
        'booking_time': DateTime.now().toIso8601String(),
        'status': BookingStatus.confirmed.name, // Assuming BookingStatus enum
        'session_date': sessionDate,
        'session_start_time': sessionStartTime,
        'session_end_time': sessionEndTime,
        'session_category': sessionCategory,
      }).select().single(); // .select().single() to get the created record back
      print('[BookingSupabaseService] Booking record created: ${bookingResponse['id']}');

      // 3. Update the user_tickets table if a ticket was used
      if (activatedTicketId != null) {
        print('[BookingSupabaseService] Updating ticket $activatedTicketId status to used...');
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.used.name, 'used_at': DateTime.now().toIso8601String()})
            .eq('id', activatedTicketId)
            .eq('status', TicketStatus.pending_booking.name); // Ensure it was pending
        
        // Optional: Check if the update affected any row, for more robust logging or error handling
        // For example, if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) { ... }
        // Supabase update typically returns null on success with default PostgrestFilterBuilder settings, 
        // or an empty list if .select() was chained and no rows matched.
        // For simplicity, we'll assume success if no exception is thrown.
        print('[BookingSupabaseService] Ticket $activatedTicketId status updated to used.');
      } else {
        print('[BookingSupabaseService] No ticket ID provided, skipping ticket update.');
      }
    
      return bookingResponse; // Return the created booking details
    } on PostgrestException catch (e, s) {
      print('[BookingSupabaseService] PostgrestException during booking: ${e.message}, code: ${e.code}');
      print('[BookingSupabaseService] Stack Trace: $s');
      // Attempt to provide a more specific error message based on common PostgREST errors
      if (e.code == '23505') { // Unique violation (e.g., trying to book twice with same ticket if RLS/constraints are set up)
        throw Exception('Booking failed: This booking might already exist or conflict with another.');
      } else if (e.message.toLowerCase().contains('session is full')) { // Custom check if previous check failed
        throw Exception('Booking failed: The session just became full.');
      }
      throw Exception('Booking failed due to a database error: ${e.message}');
    } catch (e, s) {
      print('[BookingSupabaseService] Generic Exception during booking: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception('An unexpected error occurred while booking the session.');
    }
  }

  Future<void> joinWaitlist(String userId, String sessionId, String? ticketId) async {
    print('[BookingSupabaseService] Attempting to join waitlist. UserID: $userId, SessionID: $sessionId, TicketID: $ticketId');
    try {
      // 1. Add entry to waitlist_entries table
      print('[BookingSupabaseService] Inserting into waitlist_entries...');
      await _supabaseClient.from('waitlist_entries').insert({
        'user_id': userId,
        'session_id': sessionId,
        'ticket_id': ticketId, // This will be null if no ticket was involved
        // 'created_at' is expected to have a default value of now() in the database
      });
      print('[BookingSupabaseService] Successfully inserted into waitlist_entries.');

      // 2. If a ticketId was provided, revert its status to 'available'
      if (ticketId != null) {
        print('[BookingSupabaseService] Reverting ticket $ticketId status to available...');
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.available.name})
            .eq('id', ticketId)
            .eq('status', TicketStatus.pending_booking.name); // Only revert if it was pending
        
        // Optional: Check if the update affected any row, for more robust logging or error handling
        // For example, if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) { ... }
        // Supabase update typically returns null on success with default PostgrestFilterBuilder settings, 
        // or an empty list if .select() was chained and no rows matched.
        // For simplicity, we'll assume success if no exception is thrown.
        print('[BookingSupabaseService] Ticket $ticketId status reverted to available (if it was pending).');
      }
    } on PostgrestException catch (e, s) {
      print('[BookingSupabaseService] PostgrestException while joining waitlist: ${e.message}, code: ${e.code}');
      print('[BookingSupabaseService] Stack Trace: $s');
      // Provide a more user-friendly error or rethrow a custom exception
      throw Exception('Failed to join waitlist: ${e.message}');
    } catch (e, s) {
      print('[BookingSupabaseService] Generic Exception while joining waitlist: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception('An unexpected error occurred while trying to join the waitlist.');
    }
  }
}
