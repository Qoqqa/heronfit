import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart'; // Import theme
import 'package:solar_icons/solar_icons.dart';

// Placeholder for Monthly Stats Section
class MonthlyStatsSection extends ConsumerWidget {
  const MonthlyStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch or calculate monthly stats (e.g., from workout history)
    final workoutsCompleted = 15; // Placeholder
    final totalWorkoutTime = '12h 30m'; // Placeholder - Corrected from image
    final avgWorkoutDuration = '50 min'; // Placeholder

    return Column(
      mainAxisSize: MainAxisSize.min, // Make column take minimum space
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
          ), // Add padding below title
          child: Text(
            'This Month', // Title for the section
            style: theme.textTheme.titleLarge, // Use titleLarge
          ),
        ),
        Container(
          // Wrap Card with Container to apply custom shadow
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: HeronFitTheme.cardShadow, // Apply custom shadow
          ),
          child: Card(
            elevation: 0, // Set elevation to 0
            color: Colors.transparent, // Make card transparent
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    'Workouts Completed',
                    workoutsCompleted.toString(),
                    SolarIconsOutline.dumbbellLarge, // Use SolarIcons
                    true, // Example: show upward trend
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    'Total Workout Time',
                    totalWorkoutTime,
                    SolarIconsOutline.clockCircle, // Use SolarIcons
                    true, // Example: show upward trend
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    'Avg. Workout Duration',
                    avgWorkoutDuration,
                    SolarIconsOutline.stopwatch, // Use SolarIcons
                    true, // Example: show upward trend (as per image)
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool
    upwardTrend, // Trend indicator based on comparison (true=up, false=down)
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium, // Use bodyMedium
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              upwardTrend
                  ? SolarIconsBold
                      .arrowUp // Use SolarIcons arrows
                  : SolarIconsBold.arrowDown,
              size: 16,
              color:
                  upwardTrend
                      ? HeronFitTheme.success
                      : HeronFitTheme.error, // Use theme colors
            ),
          ],
        ),
      ],
    );
  }
}
