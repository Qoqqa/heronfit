import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import 'package:heronfit/core/theme.dart';

class GoalsSection extends ConsumerWidget {
  final AsyncValue<String?> goalAsyncValue;

  const GoalsSection({required this.goalAsyncValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, // Make the title bold
              ),
            ),
            IconButton(
              icon: Icon(
                SolarIconsOutline.penNewSquare,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Edit Goals',
              onPressed: () => context.push('/progress/edit-goals'),
            ),
          ],
        ),
        const SizedBox(height: 0),
        Card(
          elevation: 2,
          shadowColor:
              HeronFitTheme
                  .cardShadow
                  .first
                  .color, // Use cardShadow from theme.dart
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                goalAsyncValue.when(
                  data: (goal) {
                    if (goal == null || goal.isEmpty) {
                      return const Text(
                        'No goal set yet. Tap the edit icon to add your goal!',
                      );
                    }
                    return Row(
                      children: [
                        Icon(
                          SolarIconsOutline.target,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Primary Goal:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(goal, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: LoadingIndicator()),
                  error:
                      (error, stack) =>
                          Center(child: Text('Error loading goal: $error')),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/progress/edit-goals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor:
                          Colors.white, // Use white for button text
                    ),
                    child: const Text('Edit Goals'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
