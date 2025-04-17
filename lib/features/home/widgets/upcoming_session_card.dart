import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme

class UpcomingSessionCard extends StatelessWidget {
  // TODO: Add parameters for dynamic data (session details, onTap)
  const UpcomingSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
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
                // TODO: Navigate to My Bookings screen
                print('Upcoming Session Tapped');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Session',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white, // Use Colors.white directly
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    SolarIconsOutline.clipboardList,
                    color: Colors.white, // Use Colors.white directly
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Add logic to display actual session or "No Booked Sessions!"
            const HomeInfoRow(
              icon: SolarIconsOutline.calendar,
              text: 'No Booked Sessions!', // Placeholder/Default
              iconColor: Colors.white, // Use Colors.white directly
              textColor: Colors.white, // Use Colors.white directly
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
