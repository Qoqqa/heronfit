import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({super.key, required this.workout});

  // Helper to format duration
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      return '${duration.inSeconds} sec';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280, // Fixed width for horizontal cards
      child: Card(
        clipBehavior: Clip.antiAlias, // Clip content to rounded corners
        color: Colors.white,
        elevation: 0, // Use shadow from theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: HeronFitTheme.bgSecondary.withAlpha(128),
            width: 1,
          ), // Subtle border
        ),
        shadowColor:
            HeronFitTheme.cardShadow.isNotEmpty
                ? HeronFitTheme.cardShadow[0].color
                : Colors.black.withAlpha(30), // Fallback color
        child: InkWell(
          onTap: () {
            // Navigate to start workout using this template/recommendation
            context.push(AppRoutes.workoutStartNew, extra: workout);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Space out content vertically
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${workout.exercises.length} exercises · ${_formatDuration(workout.duration)}',
                      style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                        color: HeronFitTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (workout.exercises.isNotEmpty)
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children:
                        workout.exercises
                            .take(3) // Show fewer chips for space
                            .map(
                              (exerciseName) => Chip(
                                label: Text(exerciseName),
                                labelStyle: HeronFitTheme.textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color: HeronFitTheme.textPrimary
                                          .withAlpha(204),
                                    ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, // Slightly more padding
                                  vertical: 2,
                                ),
                                backgroundColor: HeronFitTheme.bgSecondary
                                    .withAlpha(178),
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  )
                else
                  const SizedBox(
                    height: 28,
                  ), // Placeholder height if no exercises
              ],
            ),
          ),
        ),
      ),
    );
  }
}
