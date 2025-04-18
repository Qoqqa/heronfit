import 'package:heronfit/features/workout/models/workout_model.dart';
import 'dart:math';

// Placeholder service for workout recommendations
class WorkoutRecommendationService {
  // Placeholder data - Replace with actual Supabase/API calls
  final List<Workout> _allWorkouts = [
    Workout(
      id: 'rec1',
      name: 'Full Body Strength',
      exercises: [
        'Barbell Squat',
        'Bench Press',
        'Deadlift',
        'Overhead Press',
        'Bent Over Row',
      ],
      duration: const Duration(minutes: 60),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Workout(
      id: 'rec2',
      name: 'Upper Body Focus',
      exercises: [
        'Pull-up',
        'Dumbbell Bench Press',
        'Seated Cable Row',
        'Lateral Raise',
        'Triceps Pushdown',
      ],
      duration: const Duration(minutes: 45),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Workout(
      id: 'rec3',
      name: 'Lower Body & Core',
      exercises: [
        'Romanian Deadlift',
        'Leg Press',
        'Hamstring Curl',
        'Calf Raise',
        'Plank',
      ],
      duration: const Duration(minutes: 50),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Workout(
      id: 'rec4',
      name: 'Quick HIIT',
      exercises: [
        'Burpees',
        'Jumping Jacks',
        'High Knees',
        'Mountain Climbers',
      ],
      duration: const Duration(minutes: 20),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Workout(
      id: 'rec5',
      name: 'Bodyweight Basics',
      exercises: [
        'Squat',
        'Push-up',
        'Walking Lunges',
        'Plank',
        'Glute Bridge',
      ],
      duration: const Duration(minutes: 30),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // Premade Plans
    Workout(
      id: 'premade_gain1',
      name: 'Muscle Builder Phase 1',
      exercises: [
        'Barbell Squat',
        'Bench Press',
        'Bent Over Row',
        'Overhead Press',
        'Bicep Curl',
        'Triceps Extension',
      ],
      duration: const Duration(minutes: 65),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Workout(
      id: 'premade_lose1',
      name: 'Fat Burner Circuit',
      exercises: [
        'Kettlebell Swing',
        'Box Jump',
        'Battle Ropes',
        'Rowing Machine',
        'Burpees',
      ],
      duration: const Duration(minutes: 40),
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
    Workout(
      id: 'premade_overall1',
      name: 'Foundation Fitness',
      exercises: [
        'Goblet Squat',
        'Dumbbell Bench Press',
        'Lat Pulldown',
        'Dumbbell Shoulder Press',
        'Plank',
        'Farmer\'s Walk', // Corrected this line
      ],
      duration: const Duration(minutes: 55),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  // Simulates fetching recommended workouts (returns a subset)
  Future<List<Workout>> getRecommendedWorkouts(int limit) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    final random = Random();
    final recommended =
        _allWorkouts.where((w) => w.id.startsWith('rec')).toList()
          ..shuffle(random);
    return recommended.take(limit).toList();
  }

  // Simulates fetching all "For You" workouts
  Future<List<Workout>> getAllRecommendedWorkouts() async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate network delay
    return _allWorkouts.where((w) => w.id.startsWith('rec')).toList();
  }

  // Simulates fetching premade workouts based on category/goal
  Future<List<Workout>> getPremadeWorkouts(String category) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // Simulate network delay
    String prefix;
    switch (category) {
      case 'Gain Muscle':
        prefix = 'premade_gain';
        break;
      case 'Lose Weight':
        prefix = 'premade_lose';
        break;
      case 'Overall Fitness':
        prefix = 'premade_overall';
        break;
      default:
        return []; // Return empty if category doesn't match
    }
    return _allWorkouts.where((w) => w.id.startsWith(prefix)).toList();
  }

  // Simulates fetching available recommendation algorithms
  Future<List<String>> getAvailableAlgorithms() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
    // Placeholder algorithms
    return ['Content-Based', 'Collaborative Filtering', 'Hybrid', 'Popularity'];
  }

  // Simulates setting the preferred algorithm (placeholder)
  Future<void> setAlgorithm(String algorithm) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate delay
    print('Algorithm set to: $algorithm (Placeholder)');
    // In a real app, this would likely update user preferences in the backend
  }
}
