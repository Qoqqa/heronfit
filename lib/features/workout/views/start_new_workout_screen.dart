import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';

class StartNewWorkoutScreen extends ConsumerWidget {
  final Workout? initialWorkout;
  const StartNewWorkoutScreen({super.key, this.initialWorkout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider(initialWorkout));
    final workoutNotifier = ref.read(
      activeWorkoutProvider(initialWorkout).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
            size: 30.0,
          ),
          onPressed: () {
            workoutNotifier.cancelWorkout();
            context.pop();
          },
        ),
        title: Text(
          workoutState.name.isEmpty ? 'New Workout' : workoutState.name,
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: HeronFitTheme.primary,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          primary: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: ValueKey('workout_name_${workoutState.id}'),
                      initialValue: workoutState.name,
                      textCapitalization: TextCapitalization.sentences,
                      obscureText: false,
                      style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        // labelText: 'Workout Name',
                        // labelStyle: HeronFitTheme.textTheme.labelMedium?.copyWith(
                        //   color:
                        //       HeronFitTheme
                        //           .textMuted, // Use muted color for label when not focused
                        // ),
                        hintText: 'Enter workout name (e.g., Leg Day)',
                        hintStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted.withAlpha(
                            179,
                          ), // Use withAlpha (0.7 * 255)
                        ),
                        // Use UnderlineInputBorder
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.textMuted.withAlpha(
                              128,
                            ), // Use withAlpha (0.5 * 255)
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                HeronFitTheme
                                    .primary, // Primary color underline when focused
                            width: 2.0, // Thicker underline when focused
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical:
                              12.0, // Adjust vertical padding for underline
                          horizontal:
                              0.0, // Minimal horizontal padding for underline
                        ),
                      ),
                      onChanged:
                          (value) => workoutNotifier.setWorkoutName(value),
                      onFieldSubmitted:
                          (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Text(
                        _formatDuration(workoutState.duration),
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: workoutState.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final exercise = workoutState.exercises[index];
                    return ExerciseCard(
                      key: ValueKey(exercise.id),
                      exercise: exercise,
                      workoutId: workoutState.id,
                      onAddSet: () {
                        workoutNotifier.addSet(exercise);
                      },
                      onUpdateSetData: (setIndex, {kg, reps, completed}) {
                        workoutNotifier.updateSetData(
                          exercise,
                          setIndex,
                          kg: kg,
                          reps: reps,
                          completed: completed,
                        );
                      },
                      onRemoveSet: (setIndex) {
                        workoutNotifier.removeSet(exercise, setIndex);
                      },
                      onShowDetails: () {
                        context.push(
                          AppRoutes.exerciseDetails,
                          extra: exercise,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      label: const Text('Add Exercise'),
                      onPressed: () async {
                        final selectedExercise = await context.push<Exercise>(
                          AppRoutes.workoutAddExercise,
                        );
                        if (selectedExercise != null) {
                          workoutNotifier.addExercise(selectedExercise);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        foregroundColor: HeronFitTheme.primary,
                        side: BorderSide(
                          color: HeronFitTheme.primary.withAlpha(180),
                        ),
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Call finishWorkout and get the completed workout object
                        final completedWorkout =
                            await workoutNotifier.finishWorkout();

                        // Get the detailed exercises *with updated set data* from the state
                        // We need the state *after* finishWorkout potentially modifies it or just before saving
                        // Reading the state again ensures we have the latest set data including 'completed' status
                        final finalWorkoutState = ref.read(
                          activeWorkoutProvider(initialWorkout),
                        );
                        final detailedExercises = finalWorkoutState.exercises;

                        if (!context.mounted) return;

                        // Check if the workout was finished successfully
                        if (completedWorkout != null) {
                          // Navigate to the workout complete screen, passing both workout and detailed exercises
                          context.pushReplacement(
                            AppRoutes.workoutComplete,
                            extra: {
                              'workout': completedWorkout,
                              // Pass the exercises list which contains the detailed set data
                              'detailedExercises': detailedExercises,
                            },
                          );
                        } else {
                          // Handle error case (e.g., show a SnackBar)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error finishing workout. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44.0),
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Finish Workout'),
                    ),
                    const SizedBox(height: 4.0),
                    ElevatedButton(
                      onPressed: () {
                        workoutNotifier.cancelWorkout();
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44.0),
                        backgroundColor: HeronFitTheme.error,
                        foregroundColor: Colors.white,
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Cancel Workout'),
                    ),
                  ],
                ),
              ],
            ),
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
