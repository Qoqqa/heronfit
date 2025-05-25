// d:\Development\heronfit\lib\features\booking\services\booking_supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' hide Session; // Hide Supabase's Session
import 'package:heronfit/core/utils/app_strings.dart'; // Ensure this path is correct
import '../models/user_ticket_model.dart';
import '../models/session_model.dart'; // Added import for Session model
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
        throw Exception(AppStrings.ticketNotAssociatedError);
      }
      print('[BookingSupabaseService] Ticket ownership validated.');

      // 3. Validate ticket status (must be 'available')
      print('[BookingSupabaseService] Validating ticket status. Current status: ${ticket.status}');
      if (ticket.status != TicketStatus.available) {
        String errorMessage = AppStrings.ticketNotActiveError;
        switch (ticket.status) {
          case TicketStatus.used:
            errorMessage = AppStrings.ticketAlreadyUsedError;
            break;
          case TicketStatus.expired:
            errorMessage = AppStrings.ticketExpiredError;
            break;
          case TicketStatus.pending_booking:
            errorMessage = AppStrings.ticketPendingBookingError;
            break;
          default:
            break;
        }
        print('[BookingSupabaseService] ERROR: Ticket status is not available. Status: ${ticket.status}');
        throw Exception(errorMessage);
      }
      print('[BookingSupabaseService] Ticket status validated as available.');

      // 4. Validate ticket expiry date (if applicable)
      print('[BookingSupabaseService] Validating ticket expiry date. Expiry: ${ticket.expiryDate}');
      if (ticket.expiryDate != null && ticket.expiryDate!.isBefore(DateTime.now())) {
        print('[BookingSupabaseService] ERROR: Ticket has expired. Expiry date: ${ticket.expiryDate}');
        // Optionally update status to 'expired' in DB if it's not already
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.expired.name})
            .eq('id', ticket.id);
        ticket.status = TicketStatus.expired; // Update local object
        throw Exception(AppStrings.ticketExpiredError);
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
      print('[BookingSupabaseService] PostgrestException: ${e.message}, Code: ${e.code}, Details: ${e.details}, Hint: ${e.hint}');
      print('[BookingSupabaseService] Stack Trace: $s');
      if (e.code == 'PGRST116') { 
        throw Exception(AppStrings.ticketNotFoundError);
      }
      throw Exception('${AppStrings.ticketValidationFailedError} Details: ${e.message}');
    } catch (e, s) {
      print('[BookingSupabaseService] Generic Exception: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception(e.toString().startsWith('Exception: ') ? e.toString().substring('Exception: '.length) : AppStrings.unknownError);
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
}
