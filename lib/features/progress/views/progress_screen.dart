import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Remove hide UserGoal clause as it's defined elsewhere
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
// Import the new widget files
import 'package:heronfit/features/progress/widgets/goals_section.dart';
import 'package:heronfit/features/progress/widgets/monthly_stats_section.dart';
import 'package:heronfit/features/progress/widgets/personal_bests_section.dart';
import 'package:heronfit/features/progress/widgets/weight_chart_section.dart';
import 'package:heronfit/features/progress/widgets/weight_log_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsyncValue = ref.watch(progressRecordsProvider);
    // Watch userGoal provider (updated name)
    final goalAsyncValue = ref.watch(userGoalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate providers to trigger a refresh
          ref.invalidate(progressRecordsProvider);
          // Invalidate userGoal provider (updated name)
          ref.invalidate(userGoalProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Use the new widget sections
            GoalsSection(
              goalAsyncValue: goalAsyncValue,
            ), // Corrected parameter name
            const SizedBox(height: 24),
            WeightChartSection(progressAsyncValue: progressAsyncValue),
            const SizedBox(height: 24),
            // Add Placeholder Sections
            const MonthlyStatsSection(),
            const SizedBox(height: 24),
            const PersonalBestsSection(),
            const SizedBox(height: 24),
            // Weight log can be placed after charts or stats based on preference
            WeightLogSection(progressAsyncValue: progressAsyncValue),
            const SizedBox(height: 80), // Add padding at the bottom
          ],
        ),
      ),
    );
  }
}
