import 'package:flutter/material.dart';
import 'package:heronfit/controllers/workout_complete_controller.dart';
import 'package:heronfit/models/workout_complete_model.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/core/services/workout_storage_service.dart';
import 'package:heronfit/models/workout_model.dart';

class WorkoutCompleteWidget extends StatefulWidget {
  final String workoutId;
  final DateTime startTime;
  final DateTime endTime;
  final String workoutName;
  final List<String> exercises;

  const WorkoutCompleteWidget({
    Key? key,
    required this.workoutId,
    required this.startTime,
    required this.endTime,
    required this.workoutName,
    required this.exercises,
  }) : super(key: key);

  static String routeName = 'WorkoutComplete';
  static String routePath = '/workoutComplete';

  @override
  WorkoutCompleteWidgetState createState() => WorkoutCompleteWidgetState();
}

class WorkoutCompleteWidgetState extends State<WorkoutCompleteWidget> {
  late WorkoutCompleteController _controller;

  @override
  void initState() {
    super.initState();
    final model = WorkoutCompleteModel(
      workoutId: widget.workoutId,
      startTime: widget.startTime,
      endTime: widget.endTime,
      workoutName: widget.workoutName,
      exercises: widget.exercises, // Pass the exercises here
    );
    _controller = WorkoutCompleteController(model);
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
          'Workout Complete',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 200.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/workout_complete.png',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'You\'re One Step Closer to Your Goals!',
                          style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                            color: HeronFitTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'You crushed it today! Keep up the momentum, and let\'s turn those goals into reality.',
                          textAlign: TextAlign.center,
                          style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                            color: HeronFitTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HeronFitTheme.bgSecondary,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 40.0,
                            color: HeronFitTheme.dropShadow,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _controller.workoutName,
                              style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                color: HeronFitTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Duration: ${_controller.workoutDuration.inMinutes} minutes',
                              style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                                color: HeronFitTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Date: ${_controller.startTime.toLocal().toString().split(' ')[0]}',
                              style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                                color: HeronFitTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Exercises:',
                              style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                color: HeronFitTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ...widget.exercises.map((exercise) => Text(
                                  '- $exercise',
                                  style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                                    color: HeronFitTheme.textPrimary,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        final workout = Workout(
                          id: widget.workoutId,
                          name: widget.workoutName,
                          exercises: widget.exercises,
                          duration: widget.endTime.difference(widget.startTime),
                        );

                        final storageService = WorkoutStorageService();
                        await storageService.saveWorkout(workout);

                        Navigator.pushNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48.0),
                        backgroundColor: HeronFitTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Save Workout',
                        style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: HeronFitTheme.bgLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}