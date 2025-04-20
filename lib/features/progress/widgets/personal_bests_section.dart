import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart'; // Import theme
import 'package:solar_icons/solar_icons.dart';

// Placeholder for Personal Bests Section
class PersonalBestsSection extends ConsumerWidget {
  const PersonalBestsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch or calculate personal bests (e.g., from workout history, exercise PRs)
    final longestWorkout = '1h 30m'; // Placeholder
    final mostWorkoutsWeek = '5'; // Placeholder
    final heaviestLift = 'Bench Press: 100 kg'; // Placeholder

    return Column(
      mainAxisSize: MainAxisSize.min, // Make column take minimum space
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
          ), // Add padding below title
          child: Text(
            'Personal Bests', // Title for the section
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
                  _buildBestRow(
                    context,
                    'Longest Workout',
                    longestWorkout,
                    SolarIconsOutline.clockCircle, // Use SolarIcons
                  ),
                  const Divider(height: 24),
                  _buildBestRow(
                    context,
                    'Most Workouts in a Week',
                    mostWorkoutsWeek,
                    SolarIconsOutline.calendarMinimalistic, // Use SolarIcons
                  ),
                  const Divider(height: 24),
                  _buildBestRow(
                    context,
                    'Heaviest Lift (Example)',
                    heaviestLift,
                    SolarIconsOutline.dumbbellLarge, // Use SolarIcons
                  ),
                  // Add more personal bests as needed
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize:
                MainAxisSize
                    .min, // Prevent inner Row from expanding unnecessarily
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
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.end, // Align value to the end
        ),
      ],
    );
  }
}
