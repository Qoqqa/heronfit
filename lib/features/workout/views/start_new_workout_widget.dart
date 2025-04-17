import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

class StartNewWorkoutWidget extends ConsumerWidget {
  final Workout? initialWorkout;
  const StartNewWorkoutWidget({super.key, this.initialWorkout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider(initialWorkout));
    final workoutNotifier = ref.read(
      activeWorkoutProvider(initialWorkout).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
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
                      style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                        color: HeronFitTheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Workout Name',
                        labelStyle: HeronFitTheme.textTheme.labelSmall
                            ?.copyWith(letterSpacing: 0.0),
                        hintText: 'Enter workout name',
                        hintStyle: HeronFitTheme.textTheme.labelSmall?.copyWith(
                          color: HeronFitTheme.textMuted,
                          letterSpacing: 0.0,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.primary,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.primaryDark,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 2.0,
                          ),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          16.0,
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
                        style: HeronFitTheme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      key: ValueKey('workout_notes_${workoutState.id}'),
                      initialValue: workoutState.notes,
                      decoration: InputDecoration(
                        labelText: 'Add a note about your workout',
                        labelStyle: HeronFitTheme.textTheme.labelSmall,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: HeronFitTheme.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: HeronFitTheme.bgSecondary,
                        prefixIcon: const Icon(
                          Icons.edit,
                          color: HeronFitTheme.textMuted,
                          size: 16.0,
                        ),
                      ),
                      style: HeronFitTheme.textTheme.bodyMedium,
                      maxLines: 3,
                      onChanged:
                          (value) => workoutNotifier.setWorkoutNotes(value),
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
                    ElevatedButton(
                      onPressed: () async {
                        final selectedExercise = await context.push<Exercise>(
                          AppRoutes.workoutAddExercise,
                        );
                        if (selectedExercise != null) {
                          workoutNotifier.addExercise(selectedExercise);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        backgroundColor: HeronFitTheme.primary,
                        textStyle: HeronFitTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                        await workoutNotifier.finishWorkout();
                        if (!context.mounted) return;
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.workout);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48.0),
                        backgroundColor: HeronFitTheme.primary,
                        textStyle: HeronFitTheme.textTheme.titleMedium
                            ?.copyWith(color: Colors.white),
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
                        workoutNotifier.cancelWorkout();
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        backgroundColor: HeronFitTheme.error,
                        textStyle: HeronFitTheme.textTheme.labelMedium
                            ?.copyWith(color: Colors.white),
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
