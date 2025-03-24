import 'package:flutter/material.dart';
import 'package:heronfit/models/workout_model.dart';
import 'package:heronfit/models/exercise_model.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:heronfit/controllers/start_new_workout_controller.dart';
import 'package:heronfit/views/workout/add_exercise_screen.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/models/set_data_model.dart';

class StartWorkoutFromTemplate extends StatefulWidget {
  final Workout workout;

  const StartWorkoutFromTemplate({Key? key, required this.workout})
    : super(key: key);

  @override
  _StartWorkoutFromTemplateState createState() =>
      _StartWorkoutFromTemplateState();
}

class _StartWorkoutFromTemplateState extends State<StartWorkoutFromTemplate> {
  late StartNewWorkoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StartNewWorkoutController(workout: widget.workout);

    // Preload exercises and initialize their sets separately
    _controller.exercises =
        widget.workout.exercises
            .map(
              (exerciseName) => Exercise(
                id: '', // Provide a default or unique ID if necessary
                name: exerciseName,
                force: '', // Provide default values for other required fields
                level: '',
                mechanic: null,
                equipment: '',
                primaryMuscle: '',
                secondaryMuscles: [],
                instructions: [],
                category: '',
                imageUrl: '',
              ),
            )
            .toList();

    // Initialize the sets for each exercise
    for (var exercise in _controller.exercises) {
      exercise.sets = []; // Initialize with an empty list of SetData
    }

    _controller.startTimer(); // Start the timer for the workout
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
        automaticallyImplyLeading: false, // Disable default back button
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: HeronFitTheme.primary, // Use the primary color
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          widget.workout.name,
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
              Expanded(
                child: ListView.builder(
                  itemCount: _controller.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _controller.exercises[index];
                    return Column(
                      children: [
                        ExerciseCard(
                          exercise: exercise,
                          workoutId: widget.workout.id,
                          onAddSet: () {
                            setState(() {
                              _controller.addSet(exercise);
                            });
                          },
                        ),
                        const SizedBox(height: 16.0), // Add space between cards
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedExercise = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              AddExerciseScreen(workoutId: widget.workout.id),
                    ),
                  );
                  if (selectedExercise != null) {
                    setState(() {
                      _controller.addExercise(selectedExercise);
                    });
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
                onPressed: () {
                  // Navigator.pushNamed(context, WorkoutWidget.routeName);
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/workoutComplete',
                    arguments: {
                      'workoutId': widget.workout.id,
                      'startTime': DateTime.now().subtract(
                        Duration(seconds: _controller.duration),
                      ),
                      'endTime': DateTime.now(),
                      'workoutName': widget.workout.name,
                      'exercises':
                          _controller.exercises.map((e) => e.name).toList(),
                    },
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
    );
  }
}
