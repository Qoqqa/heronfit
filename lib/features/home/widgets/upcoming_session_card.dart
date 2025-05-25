import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:heronfit/core/router/app_routes.dart';
// import 'package:heronfit/features/booking/views/booking_screen.dart'; 
import '../home_providers.dart'; 
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:go_router/go_router.dart'; 
import 'home_info_row.dart'; 
import '../../../core/theme.dart'; 
import 'package:heronfit/features/booking/controllers/booking_providers.dart';

class UpcomingSessionCard extends ConsumerWidget { 
  const UpcomingSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final upcomingSessionAsync = ref.watch(upcomingSessionProvider); 

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: HeronFitTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: upcomingSessionAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error: ${error.toString()}', 
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (session) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    // Check for active booking before navigating
                    final activeBooking = await ref.read(userActiveBookingProvider.future);
                    if (activeBooking != null) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Active Booking Found'),
                              content: const Text(
                                'You already have an upcoming session. Please cancel it or wait for it to complete before booking a new one.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('View My Bookings'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    context.go(AppRoutes.bookings); // Navigate to user's bookings list
                                  },
                                ),
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      context.go(AppRoutes.booking); // Proceed to booking if no active booking
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Session',
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        SolarIconsOutline.clipboardList,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (session != null) ...[
                  HomeInfoRow(
                    icon: SolarIconsOutline.calendar,
                    text: DateFormat('EEEE, MMMM d').format(
                      DateTime.parse(session['session_date'] as String), 
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  HomeInfoRow(
                    icon: SolarIconsOutline.clockCircle,
                    text: _formatSessionTime(session['session_start_time'] as String, session['session_end_time'] as String, session['session_date'] as String),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ] else ...[
                  const HomeInfoRow(
                    icon: SolarIconsOutline.calendar,
                    text: 'No Booked Sessions!',
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatSessionTime(String startTimeStr, String endTimeStr, String dateStr) {
  try {
    // Parse the date string to get year, month, day
    final DateTime sessionDate = DateTime.parse(dateStr);

    // Split time strings and parse them
    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');

    final DateTime startTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      int.parse(startTimeParts[0]), // hour
      int.parse(startTimeParts[1]), // minute
      int.parse(startTimeParts[2]), // second
    );

    final DateTime endTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      int.parse(endTimeParts[0]), // hour
      int.parse(endTimeParts[1]), // minute
      int.parse(endTimeParts[2]), // second
    );

    final DateFormat formatter = DateFormat.jm(); // e.g., 5:08 PM
    return '${formatter.format(startTime)} - ${formatter.format(endTime)}';
  } catch (e) {
    print('Error formatting session time: $e');
    // Fallback to raw strings if parsing/formatting fails
    return '$startTimeStr - $endTimeStr';
  }
}
