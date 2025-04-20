import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/models/progress_record.dart'; // Import UserGoal model
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class GoalsSection extends ConsumerWidget {
  final AsyncValue<UserGoal?> goalsAsyncValue;

  const GoalsSection({required this.goalsAsyncValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Goals', style: theme.textTheme.titleLarge),
                IconButton(
                  // Use SolarIcons.penNewSquare
                  icon: Icon(
                    SolarIconsOutline.penNewSquare,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Edit Goals',
                  onPressed: () => context.push('/progress/edit-goals'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            goalsAsyncValue.when(
              data: (goal) {
                if (goal == null ||
                    goal.goalType == null ||
                    goal.goalType!.isEmpty) {
                  return const Text(
                    'No goals set yet. Tap the edit icon to add your goals!',
                  );
                }
                final goalType = goal.goalType ?? 'N/A';
                final targetWeight = goal.targetWeight?.toString() ?? 'N/A';
                final targetDate =
                    goal.targetDate != null
                        ? DateFormat('MMMM d, yyyy').format(goal.targetDate!)
                        : 'N/A';

                // Consider adding icons like in the FlutterFlow example
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalRow(
                      context,
                      SolarIconsOutline.tagHorizontal,
                      'Goal Type:',
                      goalType,
                    ),
                    _buildGoalRow(
                      context,
                      SolarIconsOutline.scale,
                      'Target Weight:',
                      '$targetWeight kg',
                    ),
                    _buildGoalRow(
                      context,
                      SolarIconsOutline.calendar,
                      'Target Date:',
                      targetDate,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading goals: $error')),
            ),
            // Add Edit Goals Button like FlutterFlow example
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/progress/edit-goals'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                child: const Text('Edit Goals'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // Replace Expanded with Flexible to avoid unbounded width error
          Flexible(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
