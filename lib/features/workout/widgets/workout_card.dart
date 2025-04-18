import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

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
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 1, // Subtle elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: HeronFitTheme.bgSecondary.withAlpha(100),
            width: 1,
          ),
        ),
        shadowColor:
            HeronFitTheme.cardShadow.isNotEmpty
                ? HeronFitTheme.cardShadow[0].color.withOpacity(0.5)
                : Colors.black.withAlpha(15),
        child: InkWell(
          onTap: () {
            // Navigate to start workout using this template/recommendation
            context.push(AppRoutes.workoutStartFromTemplate, extra: workout);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      SolarIconsOutline.dumbbellSmall, // Added icon
                      color: HeronFitTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: HeronFitTheme.textTheme.titleMedium
                                ?.copyWith(
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
                    ),
                  ],
                ),
                if (workout.exercises.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                    ), // Add padding above chips
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children:
                          workout.exercises
                              .take(3)
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
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  backgroundColor: HeronFitTheme.bgSecondary
                                      .withAlpha(178),
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                    ),
                  )
                else
                  const SizedBox(
                    height: 32, // Adjusted placeholder height
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
