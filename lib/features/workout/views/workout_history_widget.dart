import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import '../../../core/theme.dart';
import '../../../core/services/workout_storage_service.dart';

class WorkoutHistoryWidget extends StatefulWidget {
  const WorkoutHistoryWidget({super.key});

  static String routeName = 'WorkoutHistory';
  static String routePath = '/workoutHistory';

  @override
  State<WorkoutHistoryWidget> createState() => _WorkoutHistoryWidgetState();
}

class _WorkoutHistoryWidgetState extends State<WorkoutHistoryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final WorkoutStorageService _storageService = WorkoutStorageService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    final workouts = await _storageService.getSavedWorkouts();

    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
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
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Workout History',
            style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
              color: HeronFitTheme.primary,
              fontSize: 20,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: HeronFitTheme.primary,
                  ),
                )
                : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: HeronFitTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history yet',
              style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                color: HeronFitTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a workout to see it here',
              style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                color: HeronFitTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            Text(
              'Recent Workouts',
              style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: HeronFitTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildWorkoutList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    int totalWorkouts = _workouts.length;
    int totalDuration = 0;
    int totalExercises = 0;

    for (var workout in _workouts) {
      totalDuration += workout.duration.inSeconds;
      totalExercises += workout.exercises.length;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HeronFitTheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: HeronFitTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Workouts', totalWorkouts.toString()),
              _buildStatItem(
                'Time',
                _formatDuration(Duration(seconds: totalDuration)),
              ),
              _buildStatItem('Exercises', totalExercises.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: HeronFitTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _workouts.length,
      itemBuilder: (context, index) {
        final workout = _workouts[index];
        final dateStr =
            workout.timestamp != null
                ? DateFormat('MMM d, yyyy').format(workout.timestamp)
                : 'Unknown date';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        workout.name,
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: HeronFitTheme.primary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                          color: HeronFitTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${workout.exercises.length} exercises • ${_formatDuration(workout.duration)}',
                    style: HeronFitTheme.textTheme.bodyMedium,
                  ),
                  if (workout.exercises.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          workout.exercises
                              .map(
                                (exercise) => Chip(
                                  label: Text(exercise),
                                  backgroundColor: HeronFitTheme.bgLight,
                                  side: BorderSide(
                                    color: HeronFitTheme.primary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                  labelStyle: TextStyle(fontSize: 12),
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
      },
    );
  }
}
