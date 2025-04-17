import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';

import '../../../core/theme.dart';
import '../models/workout_model.dart';

class WorkoutWidget extends ConsumerWidget {
  const WorkoutWidget({super.key});

  static String routePath = AppRoutes.workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedWorkoutsAsync = ref.watch(savedWorkoutsProvider);
    final recommendedWorkoutsAsync = ref.watch(recommendedWorkoutsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                      context.push(AppRoutes.workoutStartNew, extra: null);
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
                  recommendedWorkoutsAsync.when(
                    loading:
                        () => Center(
                          child: CircularProgressIndicator(
                            color: HeronFitTheme.primary,
                          ),
                        ),
                    error:
                        (error, stackTrace) => Center(
                          child: Text(
                            'Failed to load recommendations: $error',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.error,
                            ),
                          ),
                        ),
                    data: (recommendedWorkouts) {
                      if (recommendedWorkouts.isEmpty) {
                        return Center(
                          child: Text(
                            'No recommendations available.',
                            style: HeronFitTheme.textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recommendedWorkouts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildWorkoutCard(
                              context,
                              recommendedWorkouts[index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
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
                  savedWorkoutsAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) => Center(
                          child: Text(
                            'Failed to load templates: $error',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.error,
                            ),
                          ),
                        ),
                    data: (savedWorkouts) {
                      if (savedWorkouts.isEmpty) {
                        return Center(
                          child: Text(
                            'No saved templates yet.',
                            style: HeronFitTheme.textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            savedWorkouts.length > 3 ? 3 : savedWorkouts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildWorkoutCard(
                              context,
                              savedWorkouts[index],
                            ),
                          );
                        },
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

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.workoutStartNew, extra: workout);
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
