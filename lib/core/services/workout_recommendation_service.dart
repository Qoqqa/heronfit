import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'workout_supabase_service.dart'; // Import Supabase service
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Ref

// Provider for WorkoutSupabaseService (if not already globally available)
// Ensure this provider exists and is accessible
final workoutSupabaseServiceProvider = Provider<WorkoutSupabaseService>((ref) {
  return WorkoutSupabaseService();
});

class WorkoutRecommendationService {
  final Ref _ref; // Add Ref to access other providers
  final String _recommendationApiBaseUrl =
      'https://heronfit-recommendation-service.onrender.com';

  WorkoutRecommendationService(this._ref); // Constructor to accept Ref

  // Fetches recommended workout templates from the API
  Future<List<Workout>> fetchRecommendationsFromApi(String userId) async {
    final url = Uri.parse(
      '$_recommendationApiBaseUrl/recommendations/workout/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final recommendationsData = decodedBody['recommendations'] as List?;

        if (recommendationsData == null) {
          debugPrint('No recommendations array found in API response.');
          return [];
        }

        final List<Future<Workout>> futureWorkouts = [];

        for (var recData in recommendationsData) {
          if (recData is Map<String, dynamic>) {
            final exerciseIds =
                (recData['exercises'] as List?)
                    ?.map((id) => id.toString())
                    .toList() ??
                [];
            final templateName =
                recData['template_name'] as String? ?? 'Recommended Workout';
            // final focus = recData['focus'] as String? ?? ''; // Can be used if needed

            if (exerciseIds.isNotEmpty) {
              // Use a Future to fetch exercises and build the Workout object
              futureWorkouts.add(
                _buildWorkoutFromIds(templateName, exerciseIds),
              );
            }
          }
        }

        // Wait for all exercise fetching and workout building to complete
        final List<Workout> workouts = await Future.wait(futureWorkouts);
        return workouts;
      } else {
        debugPrint(
          'Failed to load recommendations: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      throw Exception('Error fetching recommendations: $e');
    }
  }

  // Helper to fetch exercises and build a Workout object
  Future<Workout> _buildWorkoutFromIds(
    String name,
    List<String> exerciseIds,
  ) async {
    try {
      final supabaseService = _ref.read(workoutSupabaseServiceProvider);
      final List<Exercise> exercises = await supabaseService.getExercisesByIds(
        exerciseIds,
      );

      // Estimate duration (e.g., 5 mins per exercise, adjust as needed)
      final estimatedDuration = Duration(minutes: exercises.length * 5);

      return Workout(
        // Generate a unique ID for the workout instance if needed, or use template name
        id:
            'rec_${name.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        exercises: exercises,
        duration: estimatedDuration,
        timestamp: DateTime.now(), // Or null if not applicable here
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error building workout $name: $e');
      // Return an empty/error workout or rethrow
      return Workout(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Error Loading Workout',
        exercises: [],
        duration: Duration.zero,
        timestamp: DateTime.now(),
      );
    }
  }

  // --- Updated Public Methods ---

  // Simulates fetching recommended workouts (returns a subset from API)
  Future<List<Workout>> getRecommendedWorkouts(int limit) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('User not logged in, cannot fetch recommendations.');
      return []; // Return empty list if user is not logged in
    }
    final recommendations = await fetchRecommendationsFromApi(userId);
    return recommendations.take(limit).toList();
  }

  // Simulates fetching all "For You" workouts from API
  Future<List<Workout>> getAllRecommendedWorkouts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('User not logged in, cannot fetch recommendations.');
      return []; // Return empty list if user is not logged in
    }
    return fetchRecommendationsFromApi(userId);
  }

  // --- Kept Placeholder Methods (Can be removed or adapted later) ---

  // Placeholder for premade workouts (not fetched from API in this example)
  Future<List<Workout>> getPremadeWorkouts(String category) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // Simulate network delay
    // This part still uses the old dummy data logic
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
    // Note: _allWorkouts and _dummyExercise are no longer defined here.
    // This method needs to be refactored or removed if not using dummy data.
    debugPrint(
      'getPremadeWorkouts needs refactoring to remove dummy data dependency.',
    );
    return []; // Return empty for now
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
    debugPrint('Setting algorithm preference (placeholder): $algorithm');
  }
}
