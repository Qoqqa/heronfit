import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart'; // Import Exercise
import 'package:heronfit/features/workout/models/set_data_model.dart'; // Import SetData
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Import providers

// Convert to ConsumerWidget
class WorkoutCompleteScreen extends ConsumerWidget {
  final Workout workout;
  final List<Exercise> detailedExercises; // Receive detailed exercises

  const WorkoutCompleteScreen({
    super.key,
    required this.workout,
    required this.detailedExercises,
  });

  // Helper function to format sets and reps, considering only completed sets
  String _formatSetsAndReps(List<SetData> sets) {
    final completedSets =
        sets.where((s) => s.completed).toList(); // Filter completed sets

    if (completedSets.isEmpty) {
      return 'No sets completed'; // Updated message
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
        break; // Exit loop if sets vary
      }
    }

    if (allSame) {
      // Format like "3 x 8 @ 50kg" or "3 x 8"
      return '$count x ${firstSet.reps} reps${firstSet.kg > 0 ? ' @ ${firstSet.kg}kg' : ''}';
    } else {
      // If completed sets vary, provide a summary like "3 sets completed"
      return '${completedSets.length} sets completed'; // Updated fallback
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy'); // Date formatter
    final formatDuration = ref.watch(formatDurationProvider);
    final String durationString = formatDuration(workout.duration);
    final String formattedDate = dateFormat.format(workout.timestamp);

    return SafeArea(
      child: Scaffold(
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
            'Workout Complete',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: HeronFitTheme.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Make content scrollable
                  child: Column(
                    children: [
                      // --- Image and Congrats Message ---
                      Container(
                        width: double.infinity,
                        height: 300.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/images/workout_complete.webp',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'You\'re One Step Closer to Your Goals!',
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'You crushed it today! Keep up the momentum, and let\'s turn those goals into reality.',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // --- Workout Summary Card ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: HeronFitTheme.bgSecondary,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: HeronFitTheme.dropShadow.withAlpha(
                                (255 * 0.5).round(),
                              ),
                              offset: const Offset(0.0, 4.0),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.name,
                                style: HeronFitTheme.textTheme.titleLarge
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration: $durationString',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                  Text(
                                    'Date: $formattedDate',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20.0),
                              Text(
                                'Exercises Performed:',
                                style: HeronFitTheme.textTheme.titleMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12.0),
                              () {
                                final performedExercises =
                                    detailedExercises
                                        .where(
                                          (ex) =>
                                              ex.sets.any((s) => s.completed),
                                        )
                                        .toList();

                                if (performedExercises.isEmpty) {
                                  return Text(
                                    'No exercises completed.',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textMuted,
                                        ),
                                  );
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: performedExercises.length,
                                    itemBuilder: (context, index) {
                                      final exercise =
                                          performedExercises[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                exercise.name,
                                                style: HeronFitTheme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          HeronFitTheme
                                                              .textPrimary,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              _formatSetsAndReps(
                                                exercise.sets
                                                    .where((s) => s.completed)
                                                    .toList(),
                                              ),
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        HeronFitTheme.textMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              }(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Action Buttons ---
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  final storageService = ref.read(workoutServiceProvider);
                  bool savedSuccessfully = false;

                  final performedExercises =
                      detailedExercises
                          .where((ex) => ex.sets.any((s) => s.completed))
                          .toList();

                  if (performedExercises.isNotEmpty) {
                    try {
                      final templateToSave = Workout(
                        id: '',
                        name: workout.name,
                        exercises: performedExercises,
                        createdAt: DateTime.now(),
                        timestamp: DateTime.now(),
                        duration: Duration.zero,
                      );
                      await storageService.saveWorkoutTemplate(templateToSave);
                      savedSuccessfully = true;
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving template: $e')),
                      );
                    }
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Template not saved (no exercises completed).',
                        ),
                      ),
                    );
                  }

                  if (savedSuccessfully) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout saved as template!'),
                      ),
                    );
                    ref.invalidate(savedWorkoutsProvider);
                  }

                  if (!context.mounted) return;
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56.0),
                  backgroundColor: HeronFitTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Save Workout & Go Home'),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56.0),
                  foregroundColor: HeronFitTheme.primary,
                  side: const BorderSide(
                    color: HeronFitTheme.primary,
                    width: 2.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
