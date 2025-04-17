import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'home_info_row.dart'; // Import the reusable row widget

class UpcomingSessionCard extends StatelessWidget {
  // TODO: Add parameters for dynamic data (session details, onTap)
  const UpcomingSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
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
                // TODO: Navigate to My Bookings screen
                print('Upcoming Session Tapped');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Session',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.clipboardList,
                    color: colorScheme.onSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Add logic to display actual session or "No Booked Sessions!"
            HomeInfoRow(
              icon: SolarIconsOutline.calendar,
              text: 'No Booked Sessions!', // Placeholder/Default
              iconColor: colorScheme.onSecondary,
              textColor: colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
