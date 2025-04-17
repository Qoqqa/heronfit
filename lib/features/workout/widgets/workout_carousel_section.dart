import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
// Correct the import path for LoadingIndicator (assuming it's in lib/widgets/)
import 'package:heronfit/widgets/loading_indicator.dart';
import 'workout_card.dart';

class WorkoutCarouselSection extends StatelessWidget {
  final String title;
  final AsyncValue<List<Workout>> workoutsAsync;
  final int itemCountToShow;
  final bool showSeeAllButton;
  final VoidCallback? onSeeAllTap;

  const WorkoutCarouselSection({
    super.key,
    required this.title,
    required this.workoutsAsync,
    required this.itemCountToShow,
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
        workoutsAsync.when(
          loading:
              () => const SizedBox(
                height: 180, // Fixed height for loading state
                child: Center(child: LoadingIndicator()),
              ),
          error:
              (error, stackTrace) => SizedBox(
                height: 180, // Fixed height for error state
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Failed to load: $error',
                      style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        color: HeronFitTheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          data: (workouts) {
            if (workouts.isEmpty) {
              return SizedBox(
                height: 180, // Fixed height for empty state
                child: Center(
                  child: Text(
                    'No ${title.toLowerCase()} available.',
                    style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                      color: HeronFitTheme.textMuted,
                    ),
                  ),
                ),
              );
            }
            // Determine the actual number of items to display in the carousel
            final int displayCount =
                workouts.length < itemCountToShow
                    ? workouts.length
                    : itemCountToShow;

            return SizedBox(
              height: 180, // Fixed height for the carousel
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Padding for carousel items
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ), // Space between cards
                    child: WorkoutCard(workout: workouts[index]),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
