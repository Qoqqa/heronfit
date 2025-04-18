import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/core/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';

class StartWorkoutFromTemplateScreen extends ConsumerWidget {
  final Workout workout;

  const StartWorkoutFromTemplateScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider(workout));
    final workoutNotifier = ref.read(activeWorkoutProvider(workout).notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
          ),
          onPressed: () {
            workoutNotifier.cancelWorkout();
            context.pop();
          },
        ),
        title: Text(
          workoutState.name,
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
                        labelText: 'Workout Name',
                        labelStyle: HeronFitTheme.textTheme.labelMedium,
                        hintText: 'Enter workout name',
                        hintStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.primary.withAlpha(100),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: HeronFitTheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: HeronFitTheme.bgSecondary.withAlpha(100),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged:
                          (value) => workoutNotifier.setWorkoutName(value),
                      onFieldSubmitted:
                          (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Text(
                        'Duration: ${_formatDuration(workoutState.duration)}',
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
                      exercise: exercise,
                      workoutId: workoutState.id,
                      onAddSet: () {
                        workoutNotifier.addSet(exercise);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(SolarIconsOutline.addCircle, size: 20),
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
                        final completedWorkout =
                            await workoutNotifier.finishWorkout();
                        final detailedExercises = workoutState.exercises;
                        if (!context.mounted) return;

                        if (completedWorkout != null) {
                          context.pushReplacement(
                            AppRoutes.workoutComplete,
                            extra: {
                              'workout': completedWorkout,
                              'detailedExercises': detailedExercises,
                            },
                          );
                        } else {
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
