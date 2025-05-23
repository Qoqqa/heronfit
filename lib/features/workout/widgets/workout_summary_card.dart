import 'package:flutter/material.dart';
// REMOVED: import 'package:flutter_riverpod/flutter_riverpod.dart'; // Unused
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart';
// REMOVED: import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Unused

class WorkoutSummaryCard extends StatelessWidget {
  final Workout workout;
  final List<Exercise> detailedExercises;
  final String Function(Duration) formatDuration;
  final String formattedDate;

  const WorkoutSummaryCard({
    super.key,
    required this.workout,
    required this.detailedExercises,
    required this.formatDuration,
    required this.formattedDate,
  });

  // Helper function to format sets and reps, considering only completed sets
  String _formatSetsAndReps(List<SetData> sets) {
    final completedSets = sets.where((s) => s.completed).toList();

    if (completedSets.isEmpty) {
      return 'No sets completed';
    }

    // Try to group similar completed sets
    final firstSet = completedSets.first;
    int count = 0;
    bool allSame = true;
    for (final set in completedSets) {
      if (set.kg == firstSet.kg && set.reps == firstSet.reps) {
        count++;
      } else {
        allSame = false;
        break;
      }
    }

    if (allSame) {
      return '$count x ${firstSet.reps} reps${firstSet.kg > 0 ? ' @ ${firstSet.kg}kg' : ''}';
    } else {
      return '${completedSets.length} sets completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refactored card design based on desired style and smaller size
    // Using Container with BoxDecoration for specific shadow control
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(12.0), // Smaller border radius
        boxShadow: [
          // Using the theme's dropShadow color to create the BoxShadow
          BoxShadow(
            blurRadius: 10.0, // Match original blur
            color: HeronFitTheme.dropShadow.withAlpha(
              (255 * 0.5).round(),
            ), // Use theme dropShadow with opacity
            offset: const Offset(0.0, 4.0), // Match original offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ), // Adjusted padding for smaller size
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                    color: HeronFitTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              '${formatDuration(workout.duration)} • ${workout.exercises.length} exercises',
              style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                color: HeronFitTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            // Corrected structure for conditional children
            if (detailedExercises.isNotEmpty &&
                detailedExercises.any((ex) => ex.sets.any((s) => s.completed)))
              Column(
                // Use column to list exercises if space allows
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details:', // Added a label for details
                    style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HeronFitTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        detailedExercises
                            .where((ex) => ex.sets.any((s) => s.completed))
                            .length, // Only count performed
                    itemBuilder: (context, index) {
                      final exercise =
                          detailedExercises
                              .where((ex) => ex.sets.any((s) => s.completed))
                              .toList()[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                        ), // Very small vertical padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style:
                                    HeronFitTheme
                                        .textTheme
                                        .bodySmall, // Smaller text for details
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatSetsAndReps(
                                exercise.sets
                                    .where((s) => s.completed)
                                    .toList(),
                              ),
                              style: HeronFitTheme.textTheme.bodySmall
                                  ?.copyWith(color: HeronFitTheme.textMuted),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            else if (detailedExercises.isNotEmpty &&
                !detailedExercises.any((ex) => ex.sets.any((s) => s.completed)))
              Text(
                'No exercises completed in this session.', // Message if no sets completed
                style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                  color: HeronFitTheme.textMuted,
                ),
              )
            else
              const SizedBox.shrink(), // If no exercises at all
          ],
        ),
      ),
    );
  }
}
