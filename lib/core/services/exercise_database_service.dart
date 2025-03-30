import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseDatabaseService {
  /// Get random exercises by category
  Future<List<String>> getRandomExercisesByCategory(String category, int count) async {
    try {
      // Get exercises based on category
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
  
  /// Get user's workout history
  Future<List<Map<String, dynamic>>> getUserWorkoutHistory(String userId, {int limit = 10}) async {
    try {
      return await Supabase.instance.client
          .from('workouts')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);
    } catch (e) {
      print('Error getting user workout history: $e');
      return [];
    }
  }
  
  /// Get workouts from similar users
  Future<List<Map<String, dynamic>>> getSimilarUsersWorkouts(List<String> userIds, {int limit = 20}) async {
    try {
      return await Supabase.instance.client
          .from('workouts')
          .select()
          .inFilter('user_id', userIds)  // Changed from in_() to inFilter()
          .order('timestamp', ascending: false)
          .limit(limit);
    } catch (e) {
      print('Error getting similar users workouts: $e');
      return [];
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
}