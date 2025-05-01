import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme
import 'package:heronfit/features/workout/controllers/workout_providers.dart';

class RecentActivityCard extends ConsumerWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final workoutHistory = ref.watch(workoutHistoryProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: HeronFitTheme.cardShadow, // Use theme shadow
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                context.push(AppRoutes.profileHistory); // Navigate to the Workout History screen using GoRouter with back navigation support
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.history,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            workoutHistory.when(
              data: (workouts) {
                if (workouts.isNotEmpty) {
                  final lastWorkout = workouts.first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeInfoRow(
                        icon: SolarIconsOutline.calendarDate,
                        text:
                            'Last Workout: ${lastWorkout.name}, ${lastWorkout.duration.inMinutes} mins',
                      ),
                      const SizedBox(height: 8),
                      HomeInfoRow(
                        icon: SolarIconsOutline.refresh,
                        text: 'Workouts This Week: ${workouts.length}',
                      ),
                      const SizedBox(height: 8),
                      HomeInfoRow(
                        icon: SolarIconsOutline.clockCircle,
                        text:
                            'Total Time This Week: ${workouts.fold<int>(0, (sum, workout) => sum + workout.duration.inMinutes)} mins',
                      ),
                    ],
                  );
                } else {
                  return const HomeInfoRow(
                    icon: SolarIconsOutline.calendarDate,
                    text: 'No Workouts Yet!',
                  );
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => const HomeInfoRow(
                icon: SolarIconsOutline.calendarDate,
                text: 'Error fetching workouts!',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
