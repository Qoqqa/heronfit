import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workout_model.dart';
import 'base_recommendation_service.dart';
import '../services/exercise_database_service.dart';

class RandomRecommendationService extends BaseRecommendationService {
  final Random _random = Random();
  final ExerciseDatabaseService _exerciseService = ExerciseDatabaseService();
  
  // Predefined workout categories
  final List<String> _workoutCategories = [
    'Upper Body', 'Lower Body', 'Full Body', 
    'Core', 'Cardio', 'HIIT', 'Strength', 'Mobility'
  ];
  
  // Predefined workout names by category
  final Map<String, List<String>> _workoutNames = {
    'Upper Body': ['Chest & Triceps', 'Back & Biceps', 'Shoulder Builder', 'Arm Blaster'],
    'Lower Body': ['Leg Day', 'Glute Focus', 'Quad Crusher', 'Calf Builder'],
    'Full Body': ['Total Body Burner', 'Full Body Strength', 'Compound Movements', 'Functional Fitness'],
    'Core': ['Ab Shredder', 'Core Stability', 'Six-Pack Sculptor', 'Pilates Inspired'],
    'Cardio': ['HIIT Cardio', 'Steady State', 'Cardio Blast', 'Fat Burner'],
    'HIIT': ['Tabata Challenge', '30/30 Intervals', 'AMRAP Circuit', 'EMOM Workout'],
    'Strength': ['Power Lifts', 'Strength Builder', 'Progressive Overload', 'Max Effort'],
    'Mobility': ['Dynamic Stretching', 'Joint Mobility', 'Recovery Session', 'Flexibility Focus']
  };
  
  @override
  Future<List<Workout>> getRecommendations(String? userId, {int count = 4}) async {
    final recommendations = <Workout>[];
    final categories = List<String>.from(_workoutCategories)..shuffle();
    
    for (int i = 0; i < min(count, _workoutCategories.length); i++) {
      final category = categories[i];
      final names = _workoutNames[category] ?? ['Workout'];
      final workoutName = '${names[_random.nextInt(names.length)]}';
      
      // Get 4-6 exercises for this workout
      final exerciseCount = _random.nextInt(3) + 4; // 4 to 6 exercises
      final exercises = await _exerciseService.getRandomExercisesByCategory(
        category, 
        exerciseCount
      );
      
      // Create a workout with a random duration between 30-60 minutes
      final workout = Workout(
        id: const Uuid().v4(),
        name: workoutName,
        exercises: exercises,
        duration: Duration(minutes: 30 + _random.nextInt(31)),
        timestamp: DateTime.now(),
      );
      
      recommendations.add(workout);
    }
    
    return recommendations;
  }
  
  @override
  String get algorithmName => 'Random Recommendations';
}