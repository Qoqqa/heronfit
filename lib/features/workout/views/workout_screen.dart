import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final savedWorkoutsAsync = ref.watch(savedWorkoutsProvider);
    final recommendedWorkoutsAsync = ref.watch(recommendedWorkoutsProvider);

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
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
