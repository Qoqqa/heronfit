import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/utils/model_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../models/workout_model.dart';
export '../models/workout_model.dart';
import 'add_exercise_screen.dart';
import 'package:heronfit/features/workout/views/start_new_workout_widget.dart';
import '../../../core/services/workout_storage_service.dart';
import '../../../core/services/workout_recommendation_service.dart';
import 'package:heronfit/features/workout/views/start_workout_from_template.dart';
import '../../../widgets/recommendation_algorithm_selector.dart';

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
  late WorkoutRecommendationService _recommendationService;
  List<Workout> _savedWorkouts = [];
  List<Workout> _recommendedWorkouts = [];
  bool _isLoadingRecommendations = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createWorkoutModel(context, widget);
    _storageService = WorkoutStorageService();
    _recommendationService = WorkoutRecommendationService();
    _loadSavedWorkouts();
    _loadRecommendedWorkouts();
  }

  Future<void> _loadSavedWorkouts() async {
    final workouts = await _storageService.getSavedWorkouts();
    print('Loaded workouts: $workouts'); // Debug log
    setState(() {
      _savedWorkouts = workouts;
    });
  }

  Future<void> _loadRecommendedWorkouts() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final recommendations = await _recommendationService
          .getRecommendedWorkouts(4);
      setState(() {
        _recommendedWorkouts = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
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
            child: SingleChildScrollView(
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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40.0),
                      backgroundColor: HeronFitTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Start New Workout',
                      style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                        color: HeronFitTheme.bgLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  RecommendationAlgorithmSelector(
                    recommendationService: _recommendationService,
                    onAlgorithmChanged: _loadRecommendedWorkouts,
                  ),
                  const SizedBox(height: 24.0),

                  // Recommended Programs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended Programs',
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: HeronFitTheme.primary),
                        onPressed: _loadRecommendedWorkouts,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Personalized workouts based on your preferences and goals',
                    style: HeronFitTheme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16.0),

                  // Recommended Workouts
                  _isLoadingRecommendations
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: CircularProgressIndicator(
                            color: HeronFitTheme.primary,
                          ),
                        ),
                      )
                      : _recommendedWorkouts.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'No recommendations available. Try refreshing!',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textMuted,
                            ),
                          ),
                        ),
                      )
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recommendedWorkouts.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          final workout = _recommendedWorkouts[index];
                          return _buildWorkoutCard(workout);
                        },
                      ),

                  const SizedBox(height: 24.0),

                  // My Programs Section (existing code)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Programs',
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Your saved workout templates',
                    style: HeronFitTheme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16.0),

                  _savedWorkouts.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'No saved workouts yet. Complete a workout to save it as a template!',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _savedWorkouts.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          final workout = _savedWorkouts[index];
                          return _buildWorkoutCard(workout);
                        },
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StartWorkoutFromTemplate(workout: workout),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                  color: HeronFitTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${workout.exercises.length} exercises · ${_formatDuration(workout.duration)}',
                style: HeronFitTheme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    workout.exercises.take(3).map((exercise) {
                      return Chip(
                        label: Text(
                          exercise,
                          style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                            fontSize: 10.0,
                          ),
                        ),
                        backgroundColor: HeronFitTheme.bgSecondary,
                        padding: const EdgeInsets.all(0),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList() +
                    (workout.exercises.length > 3
                        ? [
                          Chip(
                            label: Text(
                              '+${workout.exercises.length - 3} more',
                              style: HeronFitTheme.textTheme.labelSmall
                                  ?.copyWith(fontSize: 10.0),
                            ),
                            backgroundColor: HeronFitTheme.bgSecondary,
                            padding: const EdgeInsets.all(0),
                            visualDensity: VisualDensity.compact,
                          ),
                        ]
                        : []),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return '$minutes min';
  }
}
