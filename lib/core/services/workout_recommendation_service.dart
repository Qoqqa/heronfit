import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart'; // Import Exercise
import 'dart:math';

// Helper function to create dummy exercises
Exercise _dummyExercise(
  String id,
  String name, {
  String category = 'strength',
}) => Exercise(
  id: id,
  name: name,
  force: 'push', // Placeholder
  level: 'beginner', // Placeholder
  equipment: 'body only', // Placeholder
  primaryMuscle: 'chest', // Placeholder
  secondaryMuscles: [],
  instructions: [],
  category: category, // Use provided category
  imageUrl: '', // Placeholder
  // No sets needed for recommendations/templates initially
);

// Placeholder service for workout recommendations
class WorkoutRecommendationService {
  // Placeholder data - Replace with actual Supabase/API calls
  final List<Workout> _allWorkouts = [
    Workout(
      id: 'rec1',
      name: 'Full Body Strength',
      exercises: [
        _dummyExercise('ex1', 'Barbell Squat', category: 'strength'),
        _dummyExercise('ex2', 'Bench Press', category: 'strength'),
        _dummyExercise('ex3', 'Deadlift', category: 'strength'),
        _dummyExercise('ex4', 'Overhead Press', category: 'strength'),
        _dummyExercise('ex5', 'Bent Over Row', category: 'strength'),
      ],
      duration: const Duration(minutes: 60),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Workout(
      id: 'rec2',
      name: 'Upper Body Focus',
      exercises: [
        _dummyExercise('ex6', 'Pull-up', category: 'strength'),
        _dummyExercise('ex7', 'Dumbbell Bench Press', category: 'strength'),
        _dummyExercise('ex8', 'Seated Cable Row', category: 'strength'),
        _dummyExercise('ex9', 'Lateral Raise', category: 'strength'),
        _dummyExercise('ex10', 'Triceps Pushdown', category: 'strength'),
      ],
      duration: const Duration(minutes: 45),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Workout(
      id: 'rec3',
      name: 'Lower Body & Core',
      exercises: [
        _dummyExercise('ex11', 'Romanian Deadlift', category: 'strength'),
        _dummyExercise('ex12', 'Leg Press', category: 'strength'),
        _dummyExercise('ex13', 'Hamstring Curl', category: 'strength'),
        _dummyExercise('ex14', 'Calf Raise', category: 'strength'),
        _dummyExercise('ex15', 'Plank', category: 'core'), // Corrected category
      ],
      duration: const Duration(minutes: 50),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Workout(
      id: 'rec4',
      name: 'Quick HIIT',
      exercises: [
        _dummyExercise(
          'ex16',
          'Burpees',
          category: 'cardio',
        ), // Corrected category
        _dummyExercise('ex17', 'Jumping Jacks', category: 'cardio'),
        _dummyExercise('ex18', 'High Knees', category: 'cardio'),
        _dummyExercise('ex19', 'Mountain Climbers', category: 'cardio'),
      ],
      duration: const Duration(minutes: 20),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Workout(
      id: 'rec5',
      name: 'Bodyweight Basics',
      exercises: [
        _dummyExercise('ex20', 'Squat', category: 'strength'),
        _dummyExercise('ex21', 'Push-up', category: 'strength'),
        _dummyExercise('ex22', 'Walking Lunges', category: 'strength'),
        _dummyExercise('ex15', 'Plank', category: 'core'), // Re-use plank
        _dummyExercise('ex23', 'Glute Bridge', category: 'strength'),
      ],
      duration: const Duration(minutes: 30),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // Premade Plans
    Workout(
      id: 'premade_gain1',
      name: 'Muscle Builder Phase 1',
      exercises: [
        _dummyExercise('ex1', 'Barbell Squat', category: 'strength'),
        _dummyExercise('ex2', 'Bench Press', category: 'strength'),
        _dummyExercise('ex5', 'Bent Over Row', category: 'strength'),
        _dummyExercise('ex4', 'Overhead Press', category: 'strength'),
        _dummyExercise('ex24', 'Bicep Curl', category: 'strength'),
        _dummyExercise('ex25', 'Triceps Extension', category: 'strength'),
      ],
      duration: const Duration(minutes: 65),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Workout(
      id: 'premade_lose1',
      name: 'Fat Burner Circuit',
      exercises: [
        _dummyExercise(
          'ex26',
          'Kettlebell Swing',
          category: 'strength',
        ), // Often strength/cardio
        _dummyExercise(
          'ex27',
          'Box Jump',
          category: 'plyometrics',
        ), // More specific
        _dummyExercise('ex28', 'Battle Ropes', category: 'cardio'),
        _dummyExercise('ex29', 'Rowing Machine', category: 'cardio'),
        _dummyExercise('ex16', 'Burpees', category: 'cardio'),
      ],
      duration: const Duration(minutes: 40),
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
    Workout(
      id: 'premade_overall1',
      name: 'Foundation Fitness',
      exercises: [
        _dummyExercise('ex30', 'Goblet Squat', category: 'strength'),
        _dummyExercise('ex7', 'Dumbbell Bench Press', category: 'strength'),
        _dummyExercise('ex31', 'Lat Pulldown', category: 'strength'),
        _dummyExercise('ex32', 'Dumbbell Shoulder Press', category: 'strength'),
        _dummyExercise('ex15', 'Plank', category: 'core'),
        _dummyExercise('ex33', 'Farmer\'s Walk', category: 'strength'),
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
    // TODO: Replace print with proper logging
    // In a real app, this would likely update user preferences in the backend
    // Removed print statement
  }
}
