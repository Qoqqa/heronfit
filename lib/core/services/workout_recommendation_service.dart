import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/workout_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRecommendationService {
  final Random _random = Random();
  
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

  // Get random exercises from Supabase database
  Future<List<String>> _getRandomExercises(String category, int count) async {
    try {
      // Get exercises based on category (using the category field from exercise database)
      final data = await Supabase.instance.client
          .from('exercises')
          .select('name')
          .eq('category', _mapCategoryToExerciseCategory(category))
          .limit(50);
      
      // If we have enough exercises, randomly select 'count' exercises
      if (data.length >= count) {
        data.shuffle();
        return data.sublist(0, count).map((e) => e['name'] as String).toList();
      } 
      // Otherwise, get random exercises regardless of category
      else {
        final allData = await Supabase.instance.client
            .from('exercises')
            .select('name')
            .limit(50);
        
        allData.shuffle();
        return allData.sublist(0, min(count, allData.length)).map((e) => e['name'] as String).toList();
      }
    } catch (e) {
      print('Error getting exercises: $e');
      // Fallback to some predefined exercises if we can't fetch from database
      return _getFallbackExercises(category, count);
    }
  }
  
  // Map our workout categories to exercise database categories
  String _mapCategoryToExerciseCategory(String workoutCategory) {
    switch (workoutCategory) {
      case 'Upper Body': return 'upper arms';
      case 'Lower Body': return 'upper legs';
      case 'Core': return 'waist';
      case 'Cardio': return 'cardio';
      default: return ''; // Will trigger fallback to random exercises
    }
  }
  
  // Fallback exercises in case the database query fails
  List<String> _getFallbackExercises(String category, int count) {
    final exercises = <String>[];
    
    if (category == 'Upper Body') {
      exercises.addAll(['Push-ups', 'Pull-ups', 'Bench Press', 'Shoulder Press', 
                       'Bicep Curls', 'Tricep Extensions', 'Lateral Raises', 'Rows']);
    } else if (category == 'Lower Body') {
      exercises.addAll(['Squats', 'Lunges', 'Deadlifts', 'Leg Press', 
                       'Calf Raises', 'Hamstring Curls', 'Leg Extensions', 'Hip Thrusts']);
    } else if (category == 'Core') {
      exercises.addAll(['Sit-ups', 'Crunches', 'Planks', 'Russian Twists', 
                       'Leg Raises', 'Mountain Climbers', 'Flutter Kicks', 'Bicycle Crunches']);
    } else {
      exercises.addAll(['Push-ups', 'Squats', 'Sit-ups', 'Lunges', 
                       'Jumping Jacks', 'Plank', 'Burpees', 'Mountain Climbers']);
    }
    
    // Ensure we return the requested number of exercises (or all if fewer available)
    exercises.shuffle();
    return exercises.take(count).toList();
  }
  
  // Generate random recommendations
  Future<List<Workout>> getRecommendedWorkouts(int count) async {
    final recommendations = <Workout>[];
    final categories = List<String>.from(_workoutCategories)..shuffle();
    
    for (int i = 0; i < min(count, _workoutCategories.length); i++) {
      final category = categories[i];
      final names = _workoutNames[category] ?? ['Workout'];
      final workoutName = '${names[_random.nextInt(names.length)]}';
      
      // Get 4-6 exercises for this workout
      final exerciseCount = _random.nextInt(3) + 4; // 4 to 6 exercises
      final exercises = await _getRandomExercises(category, exerciseCount);
      
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
}