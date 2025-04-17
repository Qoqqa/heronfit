import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme

class RecentActivityCard extends StatelessWidget {
  // TODO: Add parameters for dynamic data (last workout, weekly stats, onTap)
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: HeronFitTheme.cardShadow, // Use theme shadow
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
                // TODO: Navigate to Workout History screen
                print('Recent Activity Tapped');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.history,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const HomeInfoRow(
              icon: SolarIconsOutline.calendarDate,
              text:
                  'Last Workout: Yesterday, 45 mins', // TODO: Replace with actual data
            ),
            const SizedBox(height: 8),
            const HomeInfoRow(
              icon: SolarIconsOutline.refresh, // Or maybe dumbbell?
              text: 'Workouts This Week: 3', // TODO: Replace with actual data
            ),
            const SizedBox(height: 8),
            const HomeInfoRow(
              icon: SolarIconsOutline.clockCircle, // Changed from timer
              text:
                  'Total Time This Week: 2.5 hours', // TODO: Replace with actual data
            ),
          ],
        ),
      ),
    );
  }
}
