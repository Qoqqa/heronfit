// d:\Development\heronfit\lib\features\booking\services\booking_supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Session; // Hide Supabase's Session
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/models/user_ticket_model.dart';
import 'package:heronfit/features/booking/models/booking_status.dart'; // Added import
import 'package:heronfit/features/booking/models/active_booking_exists_exception.dart'; // Import custom exception
import 'package:intl/intl.dart'; // Added import for DateFormat

class BookingSupabaseService {
  final SupabaseClient _supabaseClient;

  BookingSupabaseService(this._supabaseClient);

  Future<UserTicket> validateAndPrepareTicketForBooking(
    String ticketCode,
    String userId,
  ) async {
    print(
      '[BookingSupabaseService] Validating ticket. Code: $ticketCode, UserID: $userId',
    );
    try {
      // 1. Fetch the ticket by ticketCode
      print('[BookingSupabaseService] Fetching ticket from Supabase...');
      final response =
          await _supabaseClient
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
        print(
          '[BookingSupabaseService] ERROR: Ticket user ID (${ticket.userId}) does not match provided user ID ($userId).',
        );
        throw Exception(
          "This Ticket ID isn't linked to your account. Please ensure you're logged in with the correct account or contact support.",
        );
      }
      print('[BookingSupabaseService] Ticket ownership validated.');

      // 3. Validate ticket status (must be 'available')
      print(
        '[BookingSupabaseService] Validating ticket status. Current status: ${ticket.status}',
      );
      if (ticket.status != TicketStatus.available) {
        String errorMessage;
        switch (ticket.status) {
          case TicketStatus.used:
            errorMessage =
                "This Ticket ID has already been used for a session. Please purchase a new pass to book.";
            break;
          case TicketStatus.expired:
            errorMessage =
                "This Ticket ID has expired. Please purchase a new pass.";
            break;
          case TicketStatus.pending_booking:
            errorMessage =
                "This ticket is currently being processed. Please try again shortly or check 'My Bookings'.";
            break;
          default: // For any other status that isn't 'available'
            errorMessage =
                "Invalid Ticket ID. Please check your entry and try again.";
            break;
        }
        print(
          '[BookingSupabaseService] ERROR: Ticket status is not available. Status: ${ticket.status}',
        );
        throw Exception(errorMessage);
      }
      print('[BookingSupabaseService] Ticket status validated as available.');

      // 4. Validate ticket expiry date
      print(
        '[BookingSupabaseService] Validating ticket expiry date. Expiry: ${ticket.expiryDate}',
      );
      if (ticket.expiryDate != null &&
          ticket.expiryDate!.isBefore(DateTime.now())) {
        print(
          '[BookingSupabaseService] ERROR: Ticket has expired. Expiry date: ${ticket.expiryDate}',
        );
        // Optionally update status to 'expired' in DB if it's not already
        // This is a good practice to keep data consistent.
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.expired.name})
            .eq('id', ticket.id);
        ticket.status = TicketStatus.expired; // Update local object
        throw Exception(
          "This Ticket ID has expired. Please purchase a new pass.",
        );
      }
      print('[BookingSupabaseService] Ticket expiry date validated.');

      // 5. Update ticket status to 'pending_booking'
      print(
        '[BookingSupabaseService] Updating ticket status to pending_booking for ticket ID: ${ticket.id}',
      );
      await _supabaseClient
          .from('user_tickets')
          .update({'status': TicketStatus.pending_booking.name})
          .eq('id', ticket.id);
      ticket.status =
          TicketStatus.pending_booking; // Update local object status
      print(
        '[BookingSupabaseService] Ticket status updated to pending_booking successfully.',
      );

      return ticket;
    } on PostgrestException catch (e, s) {
      print(
        '[BookingSupabaseService] PostgrestException: ${e.message}, code: ${e.code}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      if (e.code == 'PGRST116') {
        // PGRST116: The result contains 0 rows
        throw Exception(
          "Invalid Ticket ID. Please check your entry and try again.",
        );
      }
      // For other Postgrest errors that are not specifically handled above
      throw Exception("An unexpected error occurred. Please try again later.");
    } catch (e, s) {
      print('[BookingSupabaseService] Generic Exception: ${e.toString()}');
      print('[BookingSupabaseService] Stack Trace: $s');
      // If the exception is one of our specific, intentionally thrown messages, rethrow it.
      // For Exception type, the message is obtained via toString().
      if (e is Exception &&
          (e.toString() ==
                  "Exception: This Ticket ID isn't linked to your account. Please ensure you're logged in with the correct account or contact support." ||
              e.toString() ==
                  "Exception: This Ticket ID has already been used for a session. Please purchase a new pass to book." ||
              e.toString() ==
                  "Exception: This Ticket ID has expired. Please purchase a new pass." ||
              e.toString() ==
                  "Exception: This ticket is currently being processed. Please try again shortly or check 'My Bookings'." ||
              e.toString() ==
                  "Exception: Invalid Ticket ID. Please check your entry and try again.")) {
        rethrow;
      }
      // For any other unforeseen errors (e.g., UserTicket.fromJson failure, other programming errors)
      throw Exception("An unexpected error occurred. Please try again later.");
    }
  }

  Future<void> revertTicketToActive(
    String ticketId,
    TicketStatus originalStatus,
  ) async {
    print(
      '[BookingSupabaseService] Reverting ticket ID $ticketId to status ${originalStatus.name}',
    );
    try {
      await _supabaseClient
          .from('user_tickets')
          .update({'status': originalStatus.name})
          .eq('id', ticketId)
          .eq('status', TicketStatus.pending_booking.name);
      print('[BookingSupabaseService] Ticket $ticketId reverted successfully.');
    } catch (e, s) {
      print(
        '[BookingSupabaseService] Error reverting ticket status for $ticketId: $e',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
    }
  }

  // Updated method to fetch sessions for a given date using the new schema
  Future<List<Session>> getSessionsForDate(DateTime date) async {
    final String targetDayOfWeek = DateFormat(
      'EEEE',
    ).format(date); // e.g., "Monday"
    final String targetDateIso = DateFormat(
      'yyyy-MM-dd',
    ).format(date); // e.g., "2025-05-29"

    print(
      '[BookingSupabaseService] Fetching sessions for date: $targetDateIso (Day: $targetDayOfWeek)',
    );

    try {
      // 1. Fetch all session_occurrences for the date
      final occurrencesResponse = await _supabaseClient
          .from('session_occurrences')
          .select(
            'id, session_id, date, booked_slots, override_capacity, status',
          )
          .eq('date', targetDateIso);
      print(
        '[BookingSupabaseService] session_occurrences response: $occurrencesResponse',
      );
      // Remove unnecessary null and type checks for occurrencesResponse
      if ((occurrencesResponse as List).isEmpty) {
        print(
          '[BookingSupabaseService] No session_occurrences found for $targetDateIso',
        );
        return [];
      }
      // 2. Fetch all session templates for the session_ids in occurrences
      final sessionIds =
          (occurrencesResponse as List)
              .map((occ) => occ['session_id'] as String)
              .toList();
      if (sessionIds.isEmpty) {
        print(
          '[BookingSupabaseService] No session_ids found in occurrences for $targetDateIso',
        );
        return [];
      }
      final sessionTemplatesResponse = await _supabaseClient
          .from('sessions')
          .select(
            'id, day_of_week, start_time_of_day, end_time_of_day, category, capacity, is_active, notes',
          )
          .inFilter('id', sessionIds);
      print(
        '[BookingSupabaseService] session templates response: $sessionTemplatesResponse',
      );
      final Map<String, dynamic> sessionTemplateMap = {
        for (var s in (sessionTemplatesResponse as List)) s['id'] as String: s,
      };
      // 3. Merge occurrence and template data
      final List<Session> mergedSessions = [];
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      for (final occ in occurrencesResponse) {
        final sessionId = occ['session_id'] as String;
        final template = sessionTemplateMap[sessionId];
        if (template == null) {
          print(
            '[BookingSupabaseService] WARNING: No session template found for session_id $sessionId',
          );
          continue;
        }
        final int bookedSlots = occ['booked_slots'] as int? ?? 0;
        final int capacity =
            occ['override_capacity'] as int? ??
            template['capacity'] as int? ??
            0;
        final String status = occ['status'] as String? ?? 'scheduled';
        // Only show scheduled sessions
        if (status != 'scheduled') {
          print(
            '[BookingSupabaseService] Skipping session $sessionId because status is $status',
          );
          continue;
        }
        // Filter out sessions that have already ended for today
        if (isToday) {
          final endTimeStr = template['end_time_of_day'] as String?;
          if (endTimeStr != null) {
            final endParts = endTimeStr.split(':');
            final endHour = int.parse(endParts[0]);
            final endMinute = int.parse(endParts[1]);
            final sessionEnd = DateTime(
              now.year,
              now.month,
              now.day,
              endHour,
              endMinute,
            );
            if (sessionEnd.isBefore(now)) {
              print(
                '[BookingSupabaseService] Skipping session $sessionId because it has already ended (end_time_of_day: $endTimeStr)',
              );
              continue;
            }
          }
        }
        final session = Session.fromJson({
          ...template,
          'id': sessionId,
          'capacity': capacity,
          'booked_slots': bookedSlots,
        });
        mergedSessions.add(session);
      }
      // 4. Sort by start time
      mergedSessions.sort(
        (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(
          b.startTime.hour * 60 + b.startTime.minute,
        ),
      );
      print(
        '[BookingSupabaseService] Returning ${mergedSessions.length} sessions for $targetDateIso',
      );
      return mergedSessions;
    } catch (e, stackTrace) {
      print('[BookingSupabaseService] Exception while fetching sessions: $e');
      print('[BookingSupabaseService] Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required String sessionId,
    required String userId,
    String? activatedTicketId,
    required String sessionDate, // Expected format: 'yyyy-MM-dd'
    required String sessionStartTime, // Expected format: 'HH:mm:ss' or 'HH:mm'
    required String sessionEndTime, // Expected format: 'HH:mm:ss' or 'HH:mm'
    required String sessionCategory,
  }) async {
    print(
      '[BookingSupabaseService] Attempting to book session. UserID: $userId, SessionID: $sessionId, Date: $sessionDate, Start: $sessionStartTime, End: $sessionEndTime, Category: $sessionCategory, TicketID: $activatedTicketId',
    );

    // 1. Check for existing active bookings
    try {
      print(
        '[BookingSupabaseService] Checking for existing active bookings for user $userId...',
      );
      final now = DateTime.now();
      print('[BookingSupabaseService] Current time (now): $now');

      final existingBookingsResponse = await _supabaseClient
          .from('bookings')
          .select('id, session_date, session_end_time, status')
          .eq('user_id', userId)
          // Only consider bookings with status 'confirmed' (not cancelled, not completed, etc.)
          .eq('status', BookingStatus.confirmed.name);

      print(
        '[BookingSupabaseService] Found potential existing bookings: $existingBookingsResponse',
      );

      if (existingBookingsResponse.isNotEmpty) {
        for (var bookingData in existingBookingsResponse) {
          final String bookingDateStr = bookingData['session_date'] as String;
          String bookingEndTimeStr = bookingData['session_end_time'] as String;
          final String bookingId = bookingData['id'].toString();

          print(
            '[BookingSupabaseService] Evaluating existing booking ID: $bookingId, Date: $bookingDateStr, Original EndTime: ${bookingData['session_end_time']}',
          );

          if (bookingEndTimeStr.split(':').length == 2) {
            bookingEndTimeStr = '$bookingEndTimeStr:00';
            print(
              '[BookingSupabaseService] Booking ID: $bookingId, Formatted EndTime: $bookingEndTimeStr',
            );
          }

          try {
            final bookingEndDateTime = DateFormat(
              "yyyy-MM-dd HH:mm:ss",
            ).parse("$bookingDateStr $bookingEndTimeStr");
            print(
              '[BookingSupabaseService] Booking ID: $bookingId, Parsed EndDateTime: $bookingEndDateTime',
            );
            final bool isActive = bookingEndDateTime.isAfter(now);
            print(
              '[BookingSupabaseService] Booking ID: $bookingId, IsActive (ends after now?): $isActive',
            );

            if (isActive) {
              print(
                '[BookingSupabaseService] ERROR: User $userId already has an active booking (ID: $bookingId) that ends at $bookingEndDateTime.',
              );
              throw ActiveBookingExistsException();
            }
          } catch (e) {
            print(
              '[BookingSupabaseService] WARN: Could not parse date/time for existing booking $bookingId: $bookingDateStr $bookingEndTimeStr. Error: $e. Skipping this check for this booking.',
            );
          }
        }
      }
      print(
        '[BookingSupabaseService] No conflicting active bookings found for user $userId.',
      );
    } on ActiveBookingExistsException {
      rethrow;
    } catch (e, s) {
      print(
        '[BookingSupabaseService] Error during active booking check: ${e.toString()}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception('Failed to verify existing bookings: ${e.toString()}');
    }

    // 2. Proceed with booking if no active booking found
    print('[BookingSupabaseService] Proceeding with booking logic...');
    try {
      // 1. Check if a session_occurrence exists for this session/date
      final occurrenceResponse =
          await _supabaseClient
              .from('session_occurrences')
              .select('id, booked_slots, override_capacity')
              .eq('session_id', sessionId)
              .eq('date', sessionDate)
              .maybeSingle();
      print(
        '[BookingSupabaseService] session_occurrence lookup: $occurrenceResponse',
      );

      String occurrenceId;
      int bookedSlots;
      int capacity;
      if (occurrenceResponse != null) {
        // Occurrence exists, check capacity
        occurrenceId = occurrenceResponse['id'] as String;
        bookedSlots = occurrenceResponse['booked_slots'] as int? ?? 0;
        capacity = occurrenceResponse['override_capacity'] as int? ?? 0;
        if (capacity == 0) {
          // Fallback: fetch from session template
          final sessionData =
              await _supabaseClient
                  .from('sessions')
                  .select('capacity')
                  .eq('id', sessionId)
                  .maybeSingle();
          capacity = sessionData?['capacity'] as int? ?? 0;
        }
        if (bookedSlots >= capacity) {
          print(
            '[BookingSupabaseService] Booking failed: Session occurrence is full.',
          );
          throw Exception('Session is full. Cannot book.');
        }
        // Increment booked_slots
        await _supabaseClient
            .from('session_occurrences')
            .update({'booked_slots': bookedSlots + 1})
            .eq('id', occurrenceId);
        print(
          '[BookingSupabaseService] Incremented booked_slots for occurrence $occurrenceId.',
        );
      } else {
        // Occurrence does not exist, create it
        final sessionData =
            await _supabaseClient
                .from('sessions')
                .select('capacity')
                .eq('id', sessionId)
                .maybeSingle();
        capacity = sessionData?['capacity'] as int? ?? 0;
        occurrenceId =
            (await _supabaseClient
                    .from('session_occurrences')
                    .insert({
                      'session_id': sessionId,
                      'date': sessionDate,
                      'booked_slots': 1,
                      'status': 'scheduled',
                    })
                    .select('id')
                    .single())['id']
                as String;
        print(
          '[BookingSupabaseService] Created new session_occurrence $occurrenceId.',
        );
      }

      // 2. Create a booking record in the bookings table
      print('[BookingSupabaseService] Creating booking record...');
      final bookingResponse =
          await _supabaseClient
              .from('bookings')
              .insert({
                'user_id': userId,
                'session_id': sessionId,
                'user_ticket_id': activatedTicketId,
                'booking_time': DateTime.now().toIso8601String(),
                'status': BookingStatus.confirmed.name,
                'session_date': sessionDate,
                'session_start_time': sessionStartTime,
                'session_end_time': sessionEndTime,
                'session_category': sessionCategory,
                'session_occurrence_id': occurrenceId,
              })
              .select()
              .single();
      print(
        '[BookingSupabaseService] Booking record created: ${bookingResponse['id']}',
      );

      // 3. Update the user_tickets table if a ticket was used
      if (activatedTicketId != null) {
        print(
          '[BookingSupabaseService] Updating ticket $activatedTicketId status to used and setting activation_date...',
        );
        await _supabaseClient
            .from('user_tickets')
            .update({
              'status': TicketStatus.used.name,
              'activation_date': DateTime.now().toIso8601String(), // Add activation_date
            })
            .eq('id', activatedTicketId)
            .eq('status', TicketStatus.pending_booking.name);
        print(
          '[BookingSupabaseService] Ticket $activatedTicketId status updated to used and activation_date set.',
        );
      } else {
        print(
          '[BookingSupabaseService] No ticket ID provided, skipping ticket update.',
        );
      }

      return bookingResponse;
    } on PostgrestException catch (e, s) {
      print(
        '[BookingSupabaseService] PostgrestException during booking: ${e.message}, code: ${e.code}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      if (e.code == '23505') {
        throw Exception(
          'Booking failed: This booking might already exist or conflict with another.',
        );
      } else if (e.message.toLowerCase().contains('session is full')) {
        throw Exception('Booking failed: The session just became full.');
      }
      throw Exception('Booking failed due to a database error: ${e.message}');
    } catch (e, s) {
      print(
        '[BookingSupabaseService] Generic Exception during booking: ${e.toString()}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception(
        'An unexpected error occurred while booking the session.',
      );
    }
  }

  Future<void> joinWaitlist(
    String userId,
    String sessionId,
    String? ticketId,
  ) async {
    print(
      '[BookingSupabaseService] Attempting to join waitlist. UserID: $userId, SessionID: $sessionId, TicketID: $ticketId',
    );
    try {
      // 1. Add entry to waitlist_entries table
      print('[BookingSupabaseService] Inserting into waitlist_entries...');
      await _supabaseClient.from('waitlist_entries').insert({
        'user_id': userId,
        'session_id': sessionId,
        'ticket_id': ticketId, // This will be null if no ticket was involved
        // 'created_at' is expected to have a default value of now() in the database
      });
      print(
        '[BookingSupabaseService] Successfully inserted into waitlist_entries.',
      );

      // 2. If a ticketId was provided, revert its status to 'available'
      if (ticketId != null) {
        print(
          '[BookingSupabaseService] Reverting ticket $ticketId status to available...',
        );
        await _supabaseClient
            .from('user_tickets')
            .update({'status': TicketStatus.available.name})
            .eq('id', ticketId)
            .eq(
              'status',
              TicketStatus.pending_booking.name,
            ); // Only revert if it was pending

        // Optional: Check if the update affected any row, for more robust logging or error handling
        // For example, if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) { ... }
        // Supabase update typically returns null on success with default PostgrestFilterBuilder settings,
        // or an empty list if .select() was chained and no rows matched.
        // For simplicity, we'll assume success if no exception is thrown.
        print(
          '[BookingSupabaseService] Ticket $ticketId status reverted to available (if it was pending).',
        );
      }
    } on PostgrestException catch (e, s) {
      print(
        '[BookingSupabaseService] PostgrestException while joining waitlist: ${e.message}, code: ${e.code}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      // Provide a more user-friendly error or rethrow a custom exception
      throw Exception('Failed to join waitlist: ${e.message}');
    } catch (e, s) {
      print(
        '[BookingSupabaseService] Generic Exception while joining waitlist: ${e.toString()}',
      );
      print('[BookingSupabaseService] Stack Trace: $s');
      throw Exception(
        'An unexpected error occurred while trying to join the waitlist.',
      );
    }
  }
}
