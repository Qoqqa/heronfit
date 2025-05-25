import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import 'home_info_row.dart';
import '../../../core/theme.dart';
import 'package:go_router/go_router.dart';
import '../home_providers.dart';

class GymAvailabilityCard extends ConsumerWidget {
  const GymAvailabilityCard({super.key});

  String _formatSessionTimeDisplay(String startTimeStr, String endTimeStr, DateTime date) {
    try {
      final startTimeParts = startTimeStr.split(':');
      final endTimeParts = endTimeStr.split(':');

      final DateTime startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      final DateTime endTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      final DateFormat formatter = DateFormat.jm();
      return '${formatter.format(startTime)} - ${formatter.format(endTime)}';
    } catch (e) {
      print('Error formatting session time for GymAvailabilityCard: $e');
      return '$startTimeStr - $endTimeStr';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(today);

    final nextSessionAsync = ref.watch(nextAvailableGymSessionProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: HeronFitTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                // Check for active upcoming session first
                final upcomingSessionData = await ref.read(upcomingSessionProvider.future);
                bool hasActiveBooking = false;

                if (upcomingSessionData != null) {
                  final dynamic sessionDateActualDynamic = upcomingSessionData['session_date_actual'];
                  final dynamic endTimeStrDynamic = upcomingSessionData['session_end_time'];

                  if (sessionDateActualDynamic is DateTime && endTimeStrDynamic is String) {
                    final DateTime sessionDate = sessionDateActualDynamic;
                    final String endTimeStr = endTimeStrDynamic;
                    final now = DateTime.now();

                    // Parse end time
                    try {
                      final endTimeParts = endTimeStr.split(':');
                      final DateTime sessionEndDateTime = DateTime(
                        sessionDate.year,
                        sessionDate.month,
                        sessionDate.day,
                        int.parse(endTimeParts[0]),
                        int.parse(endTimeParts[1]),
                        // Assuming seconds are not always present, default to 0
                        endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
                      );

                      if (sessionEndDateTime.isAfter(now)) {
                        hasActiveBooking = true;
                      }
                    } catch (e) {
                      print('Error parsing session end time for active booking check: $e');
                      // Potentially treat as no active booking or handle error differently
                    }
                  } else {
                    print('Debug: session_date_actual is not DateTime or session_end_time is not String.');
                    print('Debug: session_date_actual type: ${sessionDateActualDynamic?.runtimeType}, value: $sessionDateActualDynamic');
                    print('Debug: session_end_time type: ${endTimeStrDynamic?.runtimeType}, value: $endTimeStrDynamic');
                  }
                }

                if (hasActiveBooking) {
                  if (context.mounted) { // Check if widget is still in the tree
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
                                Navigator.of(dialogContext).pop(); // Close dialog
                                context.go(AppRoutes.bookings); // Navigate to my bookings
                              },
                            ),
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Close dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  context.go(AppRoutes.booking);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gym Availability',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.calendarSearch,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HomeInfoRow(
              icon: SolarIconsOutline.calendar,
              text: formattedDate,
            ),
            const SizedBox(height: 8),
            nextSessionAsync.when(
              data: (sessionData) {
                if (sessionData == null) {
                  return const HomeInfoRow(
                    icon: SolarIconsOutline.clockCircle,
                    text: 'No sessions available today',
                  );
                }
                final DateTime sessionDateActual = sessionData['session_date_actual'] as DateTime;
                final String sessionTimeDisplay = _formatSessionTimeDisplay(
                  sessionData['start_time_of_day'] as String,
                  sessionData['end_time_of_day'] as String,
                  sessionDateActual,
                );
                final int bookedSlots = sessionData['booked_slots'] as int? ?? 0;
                final int capacity = sessionData['capacity'] as int? ?? 15;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeInfoRow(
                      icon: SolarIconsOutline.clockCircle,
                      text: sessionTimeDisplay,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            SolarIconsOutline.usersGroupRounded,
                            color: colorScheme.onBackground,
                            size: 24,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onBackground,
                            ),
                            children: [
                              TextSpan(
                                text: '$bookedSlots',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '/$capacity capacity',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, stackTrace) => HomeInfoRow(
                icon: SolarIconsOutline.dangerTriangle,
                text: 'Error loading availability',
                iconColor: colorScheme.error,
                textColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}