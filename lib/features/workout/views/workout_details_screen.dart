import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/services/workout_supabase_service.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:solar_icons/solar_icons.dart';

class WorkoutDetailsScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  String _formatSetsAndReps(List<SetData> sets) {
    final completedSets = sets.where((s) => s.completed).toList();

    if (completedSets.isEmpty) {
      return 'No sets completed';
    }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final formatDuration = ref.watch(formatDurationProvider);
    final formatDate = ref.watch(formatDateProvider);

    final workoutService = ref.read(workoutServiceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: HeronFitTheme.primary,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          workout.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  SolarIconsOutline.clockCircle,
                  size: 20.0,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Duration: ${formatDuration(workout.duration)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(
                  SolarIconsOutline.calendarDate,
                  size: 20.0,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Date: ${formatDate(workout.timestamp)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Text(
              'Exercises:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: HeronFitTheme.cardShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            if (exercise.sets.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sets:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        exercise.sets
                                            .map(
                                              (set) => Text(
                                                'Set ${exercise.sets.indexOf(set) + 1}: ${set.reps} reps${set.kg > 0 ? ' @ ${set.kg}kg' : ''} ${set.completed ? '(Completed)' : '(Not Completed)'}',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'No sets recorded',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    debugPrint('Save as Template button clicked');
                    try {
                      await workoutService.saveWorkoutTemplate(workout);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workout saved as template!'),
                        ),
                      );
                      ref.invalidate(savedWorkoutsProvider);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving template: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Save as Template',
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    textStyle: Theme.of(context).textTheme.titleSmall,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: HeronFitTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12.0),
                OutlinedButton(
                  onPressed: () {
                    debugPrint('Start Workout button clicked');
                    if (!context.mounted) return;
                    context.push(
                      AppRoutes.workoutStartFromTemplate,
                      extra: workout,
                    );
                  },
                  child: const Text(
                    'Start Workout',
                    textAlign: TextAlign.center,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    textStyle: Theme.of(context).textTheme.titleSmall,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    side: BorderSide(color: HeronFitTheme.primary),
                    foregroundColor: HeronFitTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
