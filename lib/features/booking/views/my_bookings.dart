import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:heronfit/core/router/app_routes.dart';

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final userId = user.id;

  final response = await Supabase.instance.client
      .from('bookings')
      .select('*, sessions(*)')
      .eq('user_id', userId)
      .order('booking_time', ascending: false);

  final bookings = response.map((item) => Booking.fromJson(item)).toList();
  print('Fetched bookings: \\${bookings.length}');
  for (final b in bookings) {
    print('Booking: \\${b.id}, status: \\${b.status}');
  }
  return bookings;
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

                        final DateFormat dateFormat = DateFormat('MMM d, yyyy');

                        final String formattedSessionDate = dateFormat.format(
                          booking.sessionDate,
                        );

                        String formattedTimeRange = 'N/A';
                        try {
                          final startTime = TimeOfDay(
                            hour: int.parse(
                              booking.sessionStartTime.split(':')[0],
                            ),
                            minute: int.parse(
                              booking.sessionStartTime.split(':')[1],
                            ),
                          );
                          final endTime = TimeOfDay(
                            hour: int.parse(
                              booking.sessionEndTime.split(':')[0],
                            ),
                            minute: int.parse(
                              booking.sessionEndTime.split(':')[1],
                            ),
                          );
                          formattedTimeRange =
                              '${startTime.format(context)} - ${endTime.format(context)}';
                        } catch (e) {
                          // Handle parsing error, keep 'N/A' or log error
                          // print('Error parsing session time: $e');
                        }

                        final String ticketIdDisplay =
                            booking.userTicketId ?? 'N/A';
                        final String bookingTimeDisplay = DateFormat(
                          'MMM d, yyyy, h:mm a',
                        ).format(booking.bookingTime.toLocal());

                        return InkWell(
                          onTap: () {
                            // Navigate to BookingDetailsScreen, passing the booking object
                            // The router expects a Map<String, dynamic> for the 'extra' parameter
                            context.push(
                              AppRoutes.bookingDetails,
                              extra: booking.toJson(),
                            ); // Changed to context.push()
                          },
                          child: Card(
                            elevation: 2.0,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.sessionCategory,
                                    style: HeronFitTheme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.0,
                                          color: HeronFitTheme.primaryDark,
                                        ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Status: ${booking.status.name.replaceAll('_', ' ')[0].toUpperCase()}${booking.status.name.replaceAll('_', ' ').substring(1).toLowerCase()}',
                                    style: HeronFitTheme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: _getStatusColor(booking.status.name),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code,
                                        color: HeronFitTheme.textSecondary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          'Ref: ${booking.bookingReferenceId ?? "N/A"}',
                                          style: HeronFitTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                                color:
                                                    HeronFitTheme.textSecondary,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20.0),
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Receipt Number: $ticketIdDisplay',
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color:
                                                        HeronFitTheme
                                                            .textSecondary,
                                                  ),
                                            ),
                                            Text(
                                              'Date: $formattedSessionDate',
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color:
                                                        HeronFitTheme
                                                            .textSecondary,
                                                  ),
                                            ),
                                            Text(
                                              'Time: $formattedTimeRange',
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    letterSpacing: 0.0,
                                                    color:
                                                        HeronFitTheme
                                                            .textSecondary,
                                                  ),
                                            ),
                                            Text(
                                              'Booked on: $bookingTimeDisplay',
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontSize: 10,
                                                    letterSpacing: 0.0,
                                                    color:
                                                        HeronFitTheme.textMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stackTrace) => Center(
                  child: Text(
                    'Error: ${error.toString()}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return Colors.green;
    case 'cancelled_by_user':
    case 'cancelled_by_admin':
    case 'no_show':
      return Colors.red;
    default:
      return Colors.orange;
  }
}
