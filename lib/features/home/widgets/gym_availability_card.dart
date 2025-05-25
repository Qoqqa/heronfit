import 'package:flutter/material.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import 'home_info_row.dart';
import '../../../core/theme.dart';
import 'package:go_router/go_router.dart';

/// A simple data class to represent a gym session
class Session {
  final String time;
  final DateTime date;

  Session({required this.time, required this.date});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      time: json['time'] as String? ?? '',
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

// Initialize an empty list of sessions
final List<Session> allSessions = [];

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

  String _getNextAvailableSession() {
    final now = DateTime.now();
    final dateFormat = DateFormat('h:mm a');

    for (final session in sessions) {
      try {
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
      } catch (e) {
        debugPrint('Error parsing session time: $e');
        return session;
      }
    }

    return sessions.isNotEmpty ? sessions.first : 'No sessions available';
  }

  // Get the number of bookings for a specific session
  int getSessionCount(String sessionTime) {
    if (allSessions.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allSessions.where((session) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      return session.time == sessionTime && sessionDate.isAtSameMomentAs(today);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(today);
    final nextSession = _getNextAvailableSession();
    final sessionCount = getSessionCount(nextSession);

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
              text: nextSession,
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


}