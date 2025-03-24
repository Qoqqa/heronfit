import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart' show createModel;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/workout_model.dart';
export '../../models/workout_model.dart';
import '../../views/workout/add_exercise_screen.dart';
import 'package:heronfit/views/workout/start_new_workout_widget.dart';
import '../../core/services/workout_storage_service.dart';
import 'package:heronfit/views/workout/start_workout_from_template.dart';

class WorkoutWidget extends StatefulWidget {
  const WorkoutWidget({super.key});

  static String routeName = 'Workout';
  static String routePath = '/workout';

  @override
  State<WorkoutWidget> createState() => _WorkoutWidgetState();
}

class _WorkoutWidgetState extends State<WorkoutWidget> {
  late WorkoutModel _model;
  late WorkoutStorageService _storageService;
  List<Workout> _savedWorkouts = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WorkoutModel());
    _storageService = WorkoutStorageService();
    _loadSavedWorkouts();
  }

  Future<void> _loadSavedWorkouts() async {
    final workouts = await _storageService.getSavedWorkouts();
    print('Loaded workouts: $workouts'); // Debug log
    setState(() {
      _savedWorkouts = workouts;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
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
            'Workout',
            style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Start Section
                Text(
                  'Quick Start',
                  style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Begin a new empty workout now or choose from our recommended programs',
                  style: HeronFitTheme.textTheme.labelMedium,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartNewWorkoutWidget(),
                      ),
                    );
                  },
                  child: Text(
                    'Start New Workout',
                    style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                      color: HeronFitTheme.bgLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40.0),
                    backgroundColor: HeronFitTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // My Programs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Programs',
                      style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_rounded,
                        color: HeronFitTheme.primary,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _createNewWorkout();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // List of Saved Workouts
                Expanded(
                  child: _savedWorkouts.isEmpty
                      ? Center(
                          child: Text(
                            'No saved workouts yet.',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _savedWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = _savedWorkouts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  workout.name,
                                  style: HeronFitTheme.textTheme.titleSmall,
                                ),
                                subtitle: Text(
                                  '${workout.exercises.length} exercises • ${workout.duration.inMinutes} minutes',
                                  style: HeronFitTheme.textTheme.bodySmall,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StartWorkoutFromTemplate(workout: workout),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createNewWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartNewWorkoutWidget(),
      ),
    ).then((_) {
      print('Returning from StartNewWorkoutWidget'); // Debug log
      _loadSavedWorkouts(); // Reload saved workouts
    });
  }
}
