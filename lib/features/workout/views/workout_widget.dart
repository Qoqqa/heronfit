import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

import '../../../core/theme.dart';
import '../models/workout_model.dart';
export '../models/workout_model.dart';
import '../../../core/services/workout_storage_service.dart';
import '../../../core/services/workout_recommendation_service.dart';

class WorkoutWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic>? workoutData;
  const WorkoutWidget({super.key, this.workoutData});

  static String routePath = AppRoutes.workout;

  @override
  ConsumerState<WorkoutWidget> createState() => _WorkoutWidgetState();
}

class _WorkoutWidgetState extends ConsumerState<WorkoutWidget> {
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
    _model = WorkoutModel(widget);
    _storageService = WorkoutStorageService();
    _recommendationService = WorkoutRecommendationService();
    _loadSavedWorkouts();
    _loadRecommendedWorkouts();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWorkouts() async {
    final workouts = await _storageService.getSavedWorkouts();
    debugPrint('Loaded workouts: $workouts');
    if (mounted) {
      setState(() {
        _savedWorkouts = workouts;
      });
    }
  }

  Future<void> _loadRecommendedWorkouts() async {
    if (mounted) {
      setState(() {
        _isLoadingRecommendations = true;
      });
    }

    try {
      final recommendations = await _recommendationService
          .getRecommendedWorkouts(4);
      if (mounted) {
        setState(() {
          _recommendedWorkouts = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommendations: $e')),
        );
      }
    }
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
                    style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Begin a new workout instantly.',
                    style: HeronFitTheme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.workoutStartNew);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48.0),
                      backgroundColor: HeronFitTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: HeronFitTheme.textTheme.titleMedium,
                    ),
                    child: const Text('Start an Empty Workout'),
                  ),
                  const SizedBox(height: 24.0),

                  // Recommended Workouts Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended For You',
                        style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  _isLoadingRecommendations
                      ? Center(
                        child: CircularProgressIndicator(
                          color: HeronFitTheme.primary,
                        ),
                      )
                      : _recommendedWorkouts.isEmpty
                      ? Center(
                        child: Text(
                          'No recommendations available.',
                          style: HeronFitTheme.textTheme.bodyMedium,
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recommendedWorkouts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildWorkoutCard(
                              _recommendedWorkouts[index],
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 24.0),

                  // My Templates Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Templates',
                        style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to a screen showing all templates
                        },
                        child: Text(
                          'See All',
                          style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                            color: HeronFitTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  _savedWorkouts.isEmpty
                      ? Center(
                        child: Text(
                          'No saved templates yet.',
                          style: HeronFitTheme.textTheme.bodyMedium,
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            _savedWorkouts.length > 3
                                ? 3
                                : _savedWorkouts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildWorkoutCard(_savedWorkouts[index]),
                          );
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
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.workoutStartFromTemplate, extra: workout);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: HeronFitTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${workout.exercises.length} exercises · ${_formatDuration(workout.duration)}',
                style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                  color: HeronFitTheme.textMuted,
                ),
              ),
              if (workout.exercises.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children:
                      workout.exercises
                          .take(5)
                          .map(
                            (exercise) => Chip(
                              label: Text(exercise),
                              labelStyle: HeronFitTheme.textTheme.labelSmall
                                  ?.copyWith(fontSize: 10),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              backgroundColor: HeronFitTheme.bgSecondary
                                  .withAlpha((255 * 0.5).round()),
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      return '${duration.inSeconds} sec';
    }
    return '$minutes min';
  }
}
