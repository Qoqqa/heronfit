import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Import providers
import 'package:heronfit/core/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

// Convert to ConsumerWidget
class StartWorkoutFromTemplate extends ConsumerWidget {
  final Workout workout;

  // Use super parameters
  const StartWorkoutFromTemplate({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the active workout state, passing the initial template
    final workoutState = ref.watch(activeWorkoutProvider(workout));
    // Get the notifier
    final workoutNotifier = ref.read(activeWorkoutProvider(workout).notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: HeronFitTheme.primary),
          onPressed: () {
            workoutNotifier.cancelWorkout(); // Use notifier
            context.pop();
          },
        ),
        title: Text(
          workoutState.name, // Use state for title
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: HeronFitTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Duration: ${_formatDuration(workoutState.duration)}',
                    style: HeronFitTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workoutState.exercises.length, // Use state
                  itemBuilder: (context, index) {
                    final exercise = workoutState.exercises[index]; // Use state
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ExerciseCard(
                        exercise: exercise,
                        workoutId: workoutState.id, // Use state ID
                        onAddSet: () {
                          workoutNotifier.addSet(exercise); // Use notifier
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedExercise = await context.push<Exercise>(
                    AppRoutes.workoutAddExercise,
                  );
                  if (selectedExercise != null) {
                    workoutNotifier.addExercise(
                      selectedExercise,
                    ); // Use notifier
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40.0),
                  backgroundColor: HeronFitTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Add Exercise',
                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                    color: HeronFitTheme.bgLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await workoutNotifier.finishWorkout(); // Use notifier
                  if (!context.mounted) return;
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.workout); // Fallback
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  backgroundColor: HeronFitTheme.primary,
                  textStyle: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Finish Workout'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  workoutNotifier.cancelWorkout(); // Use notifier
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40.0),
                  backgroundColor: HeronFitTheme.error,
                  textStyle: HeronFitTheme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Cancel Workout',
                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                    color: HeronFitTheme.bgLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
