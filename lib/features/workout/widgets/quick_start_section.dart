import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';

class QuickStartSection extends StatelessWidget {
  const QuickStartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Start',
            style: HeronFitTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Begin a new workout instantly.',
            style: HeronFitTheme.textTheme.labelLarge?.copyWith(
              color: HeronFitTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Navigate to start a new, empty workout
              context.push(AppRoutes.workoutStartNew, extra: null);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40.0), // Larger button
              backgroundColor: HeronFitTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Consistent radius
              ),
              textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
            child: const Text('Start an Empty Workout'),
          ),
        ],
      ),
    );
  }
}
