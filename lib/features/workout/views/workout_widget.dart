import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/widgets/quick_start_section.dart';
import 'package:heronfit/features/workout/widgets/workout_carousel_section.dart';
import 'package:heronfit/features/workout/widgets/workout_vertical_list_section.dart';
import 'package:heronfit/core/router/app_routes.dart';

import '../../../core/theme.dart';

class WorkoutWidget extends ConsumerWidget {
  const WorkoutWidget({super.key});

  static String routePath = AppRoutes.workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedWorkoutsAsync = ref.watch(savedWorkoutsProvider);
    final recommendedWorkoutsAsync = ref.watch(recommendedWorkoutsProvider);

    return Scaffold(
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            const QuickStartSection(),
            const SizedBox(height: 24.0),
            WorkoutCarouselSection(
              title: 'My Templates',
              workoutsAsync: savedWorkoutsAsync,
              itemCountToShow: 3,
              showSeeAllButton: true,
              onSeeAllTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to All Templates')),
                );
              },
            ),
            const SizedBox(height: 24.0),
            WorkoutVerticalListSection(
              title: 'Recommended For You',
              workoutsAsync: recommendedWorkoutsAsync,
              showSeeAllButton: false,
              onSeeAllTap: null,
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
