import 'package:flutter/material.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme
import 'package:heronfit/features/booking/views/booking_screen.dart'; // Import for session count function
import 'package:go_router/go_router.dart'; // Import GoRouter

class GymAvailabilityCard extends StatelessWidget {
  final List<String> sessions = const [
    '8:00 AM - 9:00 AM',
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
  ];

  const GymAvailabilityCard({super.key});

  String getUpcomingSession() {
    final now = DateTime.now();
    final dateFormat = DateFormat('h:mm a');

    for (final session in sessions) {
      final startTime = dateFormat.parse(session.split(' - ')[0]);
      final adjustedStartTime = DateTime(
        now.year,
        now.month,
        now.day,
        startTime.hour,
        startTime.minute,
      );

      if (now.isBefore(adjustedStartTime)) {
        return session;
      }
    }

    return sessions.first; // Default to the first session if none are upcoming
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(today);
    final upcomingSession = getUpcomingSession();
    final sessionCount = filterSessionsByTime(
      allSessions,
      upcomingSession,
      DateTime.now(),
    );

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
              onTap: () {
                context.go(AppRoutes.booking); // Navigate to the BookingScreen using GoRouter
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
            HomeInfoRow(
              icon: SolarIconsOutline.clockCircle,
              text: upcomingSession,
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
                        text: '$sessionCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '/15 capacity',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int? filterSessionsByTime(
    List<SessionsRow>? sessions,
    String? sessionTime,
    DateTime? selectedDate,
  ) {
    if (sessions == null || sessionTime == null || selectedDate == null) {
      return 0; // Return 0 if any parameter is null
    }

    final normalizedSessionTime = sessionTime.trim().toLowerCase();

    final filteredSessions = sessions.where((session) {
      final normalizedTime = session.time?.trim().toLowerCase() ?? '';
      final matchesTime = normalizedTime == normalizedSessionTime;
      final matchesDate = session.date?.toIso8601String().split('T').first ==
          selectedDate.toIso8601String().split('T').first;
      debugPrint('Session: ${session.time}, Date: ${session.date}');
      debugPrint('Matches Time: $matchesTime, Matches Date: $matchesDate');
      return matchesTime && matchesDate;
    }).toList();

    return filteredSessions.length;
  }
}