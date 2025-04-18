import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/widgets/quick_start_section.dart';
import 'package:heronfit/features/workout/widgets/workout_carousel_section.dart';
import 'package:heronfit/features/workout/widgets/workout_vertical_list_section.dart';
import 'package:heronfit/core/router/app_routes.dart';

import '../../../core/theme.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  static String routePath = AppRoutes.workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSavedWorkoutsAsync = ref.watch(recentSavedWorkoutsProvider(3));
    final recommendedWorkoutsAsync = ref.watch(recommendedWorkoutsProvider);

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            const QuickStartSection(), // Header style is inside this widget
            const SizedBox(height: 24.0),
            WorkoutCarouselSection(
              title: 'My Templates', // Header style is inside this widget
              workoutsAsync: recentSavedWorkoutsAsync,
              itemCountToShow: 3,
              showSeeAllButton: true,
              onSeeAllTap: () {
                context.push(AppRoutes.workoutMyTemplates);
              },
            ),
            const SizedBox(height: 24.0),
            WorkoutVerticalListSection(
              title:
                  'Recommended For You', // Header style is inside this widget
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
