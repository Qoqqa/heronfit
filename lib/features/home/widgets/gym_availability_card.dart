import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme

class GymAvailabilityCard extends StatelessWidget {
  // TODO: Add parameters for dynamic data (date, time, capacity, onTap)
  const GymAvailabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12), // Slightly larger radius
        boxShadow: HeronFitTheme.cardShadow, // Use theme shadow
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Adjusted padding
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
                // TODO: Navigate to Book A Session screen
                print('Gym Availability Tapped');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gym Availability',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold, // Make title bold
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
            const HomeInfoRow(
              icon: SolarIconsOutline.calendar,
              text: 'Monday, October 25', // TODO: Replace with actual data
            ),
            const SizedBox(height: 8),
            const HomeInfoRow(
              icon: SolarIconsOutline.clockCircle,
              text: '10:00 AM - 11:00 AM', // TODO: Replace with actual data
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
                    children: const [
                      TextSpan(
                        text: '10', // TODO: Replace with actual data
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ), // Highlight number
                      ),
                      TextSpan(
                        text: '/15 capacity', // TODO: Replace with actual data
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
