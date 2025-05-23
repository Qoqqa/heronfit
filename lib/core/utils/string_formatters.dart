import 'package:flutter/material.dart';

/// Formats a snake_case goal value into a user-friendly display format
String formatGoalForDisplay(String goal) {
  switch (goal) {
    case 'lose_weight':
      return 'Weight Loss';
    case 'build_muscle':
      return 'Build Muscle';
    case 'general_fitness':
      return 'Overall Fitness';
    default:
      // If we get an unknown value, convert snake_case to Title Case
      return goal
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
  }
}
