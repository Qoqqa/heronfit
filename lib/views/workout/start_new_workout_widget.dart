import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heronfit/controllers/start_new_workout_controller.dart';
import 'package:heronfit/models/exercise_model.dart';
import 'package:heronfit/models/workout_model.dart';
import 'package:heronfit/views/workout/add_exercise_screen.dart';
import 'package:heronfit/views/workout/workout_complete_widget.dart';
import 'package:heronfit/views/workout/workout_widget.dart';
import 'package:heronfit/core/theme.dart';
import 'package:flutter/services.dart'; // Import for input formatting
import 'package:heronfit/widgets/exercise_card_widget.dart'; // Import the ExerciseCard widget

class StartNewWorkoutWidget extends StatefulWidget {
  const StartNewWorkoutWidget({Key? key, this.workoutID}) : super(key: key);

  final Workout? workoutID;
  static String routeName = 'StartNewWorkout';
  static String routePath = '/startNewWorkout';

  @override
  _StartNewWorkoutWidgetState createState() => _StartNewWorkoutWidgetState();
}

class _StartNewWorkoutWidgetState extends State<StartNewWorkoutWidget> {
  late StartNewWorkoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StartNewWorkoutController(workout: widget.workoutID);
    _controller.startTimer(); // Start the timer when the widget initializes
  }

  @override
  void dispose() {
    _controller.stopTimer(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'New Workout',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Replace static text with editable TextField for workout name
                        TextFormField(
                          initialValue: widget.workoutID?.name ?? 'New Workout',
                          style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                            color: HeronFitTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Workout Name',
                            labelStyle: HeronFitTheme.textTheme.labelSmall,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: HeronFitTheme.bgSecondary,
                          ),
                          onChanged: (value) => _controller.setWorkoutName(value),
                        ),
                        const SizedBox(height: 16.0),
                        // Replace static timer display with StreamBuilder for real-time updates
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: StreamBuilder<int>(
                            stream: _controller.durationStream,
                            initialData: _controller.duration,
                            builder: (context, snapshot) {
                              final minutes = snapshot.data! ~/ 60;
                              final seconds = snapshot.data! % 60;
                              return Text(
                                'Duration: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: HeronFitTheme.textTheme.bodyMedium,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Container(
                      width: double.infinity,
                      child: TextFormField(
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
                        onChanged: (value) => _controller.setWorkoutNotes(value),
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
                  itemCount: _controller.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final exercise = _controller.exercises[index];
                    return ExerciseCard(
                      exercise: exercise,
                      workoutId: widget.workoutID?.id,
                      onAddSet: () {
                        setState(() {
                          _controller.addSet(exercise);
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExerciseScreen(workoutId: widget.workoutID?.id),
                          ),
                        ).then((selectedExercise) {
                          if (selectedExercise != null) {
                            setState(() {
                              _controller.addExercise(selectedExercise);
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        backgroundColor: HeronFitTheme.primary,
                        textStyle: HeronFitTheme.textTheme.labelMedium?.copyWith(
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
                      onPressed: () {
                        Navigator.pushNamed(context, WorkoutWidget.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        backgroundColor: HeronFitTheme.error,
                        textStyle: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutCompleteWidget(
                          workoutId: widget.workoutID?.id ?? '',
                          startTime: DateTime.now().subtract(Duration(minutes: _controller.duration)),
                          endTime: DateTime.now(),
                          workoutName: widget.workoutID?.name ?? 'Workout',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48.0),
                    backgroundColor: HeronFitTheme.bgLight,
                    textStyle: HeronFitTheme.textTheme.labelMedium?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: HeronFitTheme.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: const Text('Finish Workout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}