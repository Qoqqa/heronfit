import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart'; // Ensure this path is correct
import 'workout_card.dart'; // Import the workout card

/// A section displaying a vertical list of workouts.
class WorkoutVerticalListSection extends StatelessWidget {
  final String title;
  final AsyncValue<List<Workout>> workoutsAsync;
  final bool showSeeAllButton;
  final VoidCallback? onSeeAllTap;

  const WorkoutVerticalListSection({
    super.key,
    required this.title,
    required this.workoutsAsync,
    required this.showSeeAllButton,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                // Use titleLarge for the section header
                style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showSeeAllButton)
                TextButton(
                  onPressed: onSeeAllTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    'See All',
                    style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        Padding(
          // Add horizontal padding for the list items to align with section padding
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: workoutsAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error:
                (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Failed to load: $error',
                      style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                        color: HeronFitTheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            data: (workouts) {
              if (workouts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No ${title.toLowerCase()} available.',
                      style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                        color: HeronFitTheme.textMuted,
                      ),
                    ),
                  ),
                );
              }
              // Use ListView.builder with shrinkWrap and NeverScrollableScrollPhysics
              // because this list is inside another scrollable (the main ListView).
              return ListView.builder(
                shrinkWrap: true, // Important for nested ListView
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  // Add padding around each card for spacing
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: WorkoutCard(workout: workouts[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
