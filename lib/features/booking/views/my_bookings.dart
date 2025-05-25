import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final myBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final userId = user.id; // Use user.id (UUID)

  // Fetch from 'bookings' table and join with 'sessions' table
  // Select all columns from bookings and all columns from the joined sessions
  final response = await Supabase.instance.client
      .from('bookings')
      .select('*, sessions(*)') // Join with sessions table
      .eq('user_id', userId)    // Filter by the current user's ID
      .order('booking_time', ascending: false); // Order by booking time, newest first

  // The 'response' here is already a List<Map<String, dynamic>> if successful
  // and not empty, or an empty list if no records found.
  // Supabase client handles the case where response might be null internally for .select()
  // and returns an empty list if the query executes but finds no data.
  // An error/exception is thrown for actual query failures.
  
  // print('MyBookings Response: $response'); // For debugging

  return response; // Directly return the response
});

class MyBookingsWidget extends ConsumerWidget {
  const MyBookingsWidget({super.key});

  static String routePath = '/myBookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsyncValue = ref.watch(myBookingsProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: HeronFitTheme.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'My Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: bookingsAsyncValue.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return const Center(
                  child: Text(
                    'No bookings found.',
                    style: TextStyle(
                      fontSize: 16,
                      color: HeronFitTheme.textMuted,
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        // Access session details from the nested 'sessions' map
                        final sessionData = booking['sessions'] as Map<String, dynamic>?;

                        if (sessionData == null) {
                          // Handle case where session data might be missing (e.g., session deleted)
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              title: Text('Booking ID: ${booking['id']}'),
                              subtitle: const Text('Session details unavailable. The session may have been removed.'),
                              leading: const Icon(Icons.error_outline, color: Colors.red),
                            ),
                          );
                        }

                        // Parse session start and end times
                        TimeOfDay? startTime, endTime;
                        DateTime? sessionDate;

                        if (sessionData['start_time'] != null) {
                          final timeParts = (sessionData['start_time'] as String).split(':');
                          startTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                        }
                        if (sessionData['end_time'] != null) {
                          final timeParts = (sessionData['end_time'] as String).split(':');
                          endTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                        }

                        // Determine the session date: use override_date if available, otherwise infer from booking_time or day_of_week
                        // For simplicity in display, we'll use the booking_time's date component if override_date is not present.
                        // A more robust solution would involve reconstructing the actual session occurrence date based on recurring rules.
                        if (sessionData['override_date'] != null) {
                          sessionDate = DateTime.parse(sessionData['override_date'] as String);
                        } else if (booking['booking_time'] != null) {
                          sessionDate = DateTime.parse(booking['booking_time'] as String);
                        }

                        String formattedTimeRange = 'N/A';
                        if (startTime != null && endTime != null) {
                          final now = DateTime.now();
                          final startDt = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                          final endDt = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
                          formattedTimeRange = '${DateFormat('h:mm a').format(startDt)} - ${DateFormat('h:mm a').format(endDt)}';
                        }

                        String formattedSessionDate = sessionDate != null 
                            ? DateFormat('MMMM d, yyyy').format(sessionDate) 
                            : 'Date N/A';

                        // Get session category (example, adjust if your model is different)
                        final String sessionCategory = sessionData['category'] as String? ?? 'General';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // Handle booking tap
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: HeronFitTheme.bgSecondary,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 40,
                                    color: HeronFitTheme.textMuted.withOpacity(0.1),
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: HeronFitTheme.primary,
                                              size: 32,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  // Use session category and name if available
                                                  // For now, using a generic title or session category
                                                  sessionCategory, // Example: 'Morning Yoga'
                                                  style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: HeronFitTheme.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Ticket ID: ${booking['ticket_id']}',
                                                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color: HeronFitTheme.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  'Date: $formattedSessionDate',
                                                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color: HeronFitTheme.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  'Time: $formattedTimeRange',
                                                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color: HeronFitTheme.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  'Booked on: ${DateFormat('MMM d, yyyy, h:mm a').format(DateTime.parse(booking['booking_time']))}',
                                                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                                                    fontSize: 10,
                                                    letterSpacing: 0.0,
                                                    color: HeronFitTheme.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/home'); // Navigate back to home
                    },
                    icon: const Icon(Icons.home, size: 15),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeronFitTheme.primaryDark,
                      foregroundColor: HeronFitTheme.bgLight,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                        color: HeronFitTheme.bgLight,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Error: ${error.toString()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}