import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';

// Placeholder for Monthly Stats Section
class MonthlyStatsSection extends ConsumerWidget {
  const MonthlyStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch or calculate monthly stats (e.g., from workout history)
    final workoutsCompleted = 15; // Placeholder
    final totalWorkoutTime = '2h 30m'; // Placeholder
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
            style: theme.textTheme.titleLarge,
          ),
        ),
        Card(
          elevation: 2,
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
                  SolarIconsOutline.dumbbellLarge, // Example Icon
                  true, // Example: show upward trend
                ),
                const Divider(height: 24),
                _buildStatRow(
                  context,
                  'Total Workout Time',
                  totalWorkoutTime,
                  SolarIconsOutline.clockCircle, // Example Icon
                  true, // Example: show upward trend
                ),
                const Divider(height: 24),
                _buildStatRow(
                  context,
                  'Avg. Workout Duration',
                  avgWorkoutDuration,
                  SolarIconsOutline.stopwatch, // Example Icon
                  false, // Example: show downward trend (if applicable)
                ),
              ],
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
    bool upwardTrend,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          // Group icon and label
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        Row(
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
                  ? SolarIconsBold.arrowUp
                  : SolarIconsBold.arrowDown, // Use SolarIcons arrows
              size: 16,
              color: upwardTrend ? Colors.green : Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
