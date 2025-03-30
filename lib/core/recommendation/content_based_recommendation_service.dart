import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workout_model.dart';
import 'base_recommendation_service.dart';
import '../services/exercise_database_service.dart';
import 'random_recommendation_service.dart';

class ContentBasedRecommendationService extends BaseRecommendationService {
  final ExerciseDatabaseService _exerciseService = ExerciseDatabaseService();
  final RandomRecommendationService _fallbackService = RandomRecommendationService();
  final Random _random = Random();
  
  // Predefined workout names by category for fallback
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
    if (userId == null) {
      return _fallbackService.getRecommendations(null, count: count);
    }
    
    try {
      // 1. Get user's workout history
      final userWorkouts = await _exerciseService.getUserWorkoutHistory(userId);
      
      if (userWorkouts.isEmpty) {
        // No history, fall back to random recommendations
        return _fallbackService.getRecommendations(userId, count: count);
      }
      
      // 2. Analyze user's preferred exercises and categories
      final Map<String, int> exerciseFrequency = {};
      final Map<String, int> categoryFrequency = {};
      
      for (var workout in userWorkouts) {
        final exercises = (workout['exercises'] as List).cast<String>();
        final category = workout['category'] as String? ?? _guessCategoryFromExercises(exercises);
        
        for (var exercise in exercises) {
          exerciseFrequency[exercise] = (exerciseFrequency[exercise] ?? 0) + 1;
        }
        
        categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
      }
      
      // 3. Get the top preferred categories
      final preferredCategories = categoryFrequency.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
          
      final topCategories = preferredCategories
          .take(min(3, preferredCategories.length))
          .map((e) => e.key)
          .toList();
      
      // If no clear categories, add some random ones
      if (topCategories.isEmpty) {
        topCategories.addAll(['Upper Body', 'Lower Body', 'Core']
          ..shuffle()
          ..take(min(count, 3)));
      }
      
      // 4. Get the top preferred exercises
      final preferredExercises = exerciseFrequency.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
          
      final topExercises = preferredExercises
          .take(min(10, preferredExercises.length))
          .map((e) => e.key)
          .toList();
      
      // 5. Create recommendations based on preferred categories and exercises
      final recommendations = <Workout>[];
      
      for (var category in topCategories) {
        // Get random exercises from this category, preferring user's favorites
        final exercises = await _getExercisesBasedOnPreferences(
          category,
          topExercises,
          5, // 5 exercises per workout
        );
        
        final nameOptions = _workoutNames[category] ?? ['Personalized Workout'];
        final workoutName = nameOptions[_random.nextInt(nameOptions.length)];
        
        final workout = Workout(
          id: const Uuid().v4(),
          name: '$workoutName',
          exercises: exercises,
          duration: Duration(minutes: 30 + _random.nextInt(31)),
          timestamp: DateTime.now(),
        );
        
        recommendations.add(workout);
      }
      
      // If we need more recommendations, add some random ones
      if (recommendations.length < count) {
        final randomRecs = await _fallbackService.getRecommendations(
          userId, 
          count: count - recommendations.length
        );
        recommendations.addAll(randomRecs);
      }
      
      return recommendations;
    } catch (e) {
      print('Error generating content-based recommendations: $e');
      return _fallbackService.getRecommendations(userId, count: count);
    }
  }
  
  Future<List<String>> _getExercisesBasedOnPreferences(
    String category, 
    List<String> preferredExercises,
    int count,
  ) async {
    final result = <String>[];
    
    // Try to include some preferred exercises if they match the category
    // This is a simplified approach - in a real app you'd check if these exercises
    // actually belong to the category
    final randomPreferred = List<String>.from(preferredExercises)..shuffle();
    result.addAll(randomPreferred.take(min(2, randomPreferred.length)));
    
    // Add more exercises from the category to reach the desired count
    if (result.length < count) {
      final categoryExercises = 
          await _exerciseService.getRandomExercisesByCategory(
            category, 
            count - result.length
          );
      
      // Avoid duplicates
      result.addAll(
        categoryExercises.where((exercise) => !result.contains(exercise))
      );
    }
    
    return result;
  }
  
  String _guessCategoryFromExercises(List<String> exercises) {
    // This is a simplified implementation
    // In a real app, you'd have a more sophisticated categorization
    
    final lowerCaseExercises = exercises.map((e) => e.toLowerCase()).toList();
    
    if (lowerCaseExercises.any((e) => 
        e.contains('bench') || 
        e.contains('curl') || 
        e.contains('press') ||
        e.contains('push') ||
        e.contains('tricep'))) {
      return 'Upper Body';
    } 
    else if (lowerCaseExercises.any((e) => 
        e.contains('squat') || 
        e.contains('lunge') || 
        e.contains('leg') ||
        e.contains('deadlift'))) {
      return 'Lower Body';
    }
    else if (lowerCaseExercises.any((e) => 
        e.contains('crunch') || 
        e.contains('plank') || 
        e.contains('ab'))) {
      return 'Core';
    }
    else if (lowerCaseExercises.any((e) => 
        e.contains('run') || 
        e.contains('sprint') || 
        e.contains('jog'))) {
      return 'Cardio';  
    }
    
    // Default category if we can't determine one
    return 'Full Body';
  }
  
  @override
  String get algorithmName => 'Content-Based Recommendations';
}