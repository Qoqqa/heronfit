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
  // It's better to provide the Supabase client to WorkoutSupabaseService if it needs it
  // For example: return WorkoutSupabaseService(ref.watch(supabaseClientProvider));
  // Assuming WorkoutSupabaseService() constructor is parameterless for now or handles its own client.
  return WorkoutSupabaseService();
});

class WorkoutRecommendationService {
  final Ref _ref; // Add Ref to access other providers
  // Allow base URL to be configured, e.g., via provider or environment variable
  // For now, keeping it as it was but this should ideally be configurable.
  final String _recommendationApiBaseUrl;

  WorkoutRecommendationService(this._ref, {String? baseUrl})
    : _recommendationApiBaseUrl =
          baseUrl ??
          // Always use the production URL
          'https://heronfit-recommendation-service.onrender.com'; // Prod URL

  // Internal helper to fetch and process categorized recommendations
  Future<List<Workout>> _fetchAndProcessCategorizedRecommendations(
    String userId,
    String categoryKey,
  ) async {
    final url = Uri.parse(
      '$_recommendationApiBaseUrl/recommendations/workout/$userId',
    );

    debugPrint('Fetching recommendations from: $url'); // Log start of API call
    final startTime = DateTime.now();

    try {
      final response = await http.get(url);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        'Recommendation API call finished in: ${duration.inMilliseconds}ms',
      ); // Log end of API call and duration

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        // Use the categoryKey to get the correct list of templates
        final recommendationsData = decodedBody[categoryKey] as List?;

        if (recommendationsData == null) {
          debugPrint(
            'No recommendations array found for key "$categoryKey" in API response.',
          );
          return [];
        }

        final List<Future<Workout>> futureWorkouts = [];

        for (var recData in recommendationsData) {
          if (recData is Map<String, dynamic>) {
            final exerciseIds =
                (recData['exercises'] as List?)
                    ?.map((id) => id.toString()) // Ensure IDs are strings
                    .toList() ??
                [];
            final templateName =
                recData['template_name'] as String? ?? 'Recommended Workout';
            final focus = recData['focus'] as String? ?? '';

            if (exerciseIds.isNotEmpty) {
              futureWorkouts.add(
                _buildWorkoutFromIds(templateName, focus, exerciseIds),
              );
            }
          }
        }
        final List<Workout> workouts = await Future.wait(futureWorkouts);
        return workouts;
      } else {
        debugPrint(
          'Failed to load $categoryKey recommendations: ${response.statusCode} ${response.body}',
        );
        // Consider more specific error types or logging
        throw Exception('Failed to load $categoryKey recommendations');
      }
    } catch (e) {
      debugPrint('Error fetching $categoryKey recommendations: $e');
      throw Exception('Error fetching $categoryKey recommendations: $e');
    }
  }

  // Helper to fetch exercises and build a Workout object
  Future<Workout> _buildWorkoutFromIds(
    String name,
    String focus, // Added focus/description
    List<String> exerciseIds,
  ) async {
    try {
      // Assuming workoutSupabaseServiceProvider is correctly set up
      final supabaseService = _ref.read(workoutSupabaseServiceProvider);

      debugPrint(
        'Fetching exercise details for workout "$name" from Supabase. Exercise IDs: ${exerciseIds.length}',
      ); // Log start of Supabase call
      final startTimeSupabase = DateTime.now();

      // Ensure getExercisesByIds exists in WorkoutSupabaseService and handles potential errors
      final List<Exercise> exercises = await supabaseService.getExercisesByIds(
        exerciseIds,
      );

      final endTimeSupabase = DateTime.now();
      final durationSupabase = endTimeSupabase.difference(startTimeSupabase);
      debugPrint(
        'Supabase exercise fetch for "$name" finished in: ${durationSupabase.inMilliseconds}ms',
      ); // Log end of Supabase call and duration

      // Estimate duration (e.g., 5 mins per exercise, adjust as needed)
      final estimatedDurationMinutes = exercises.length * 5;

      // Determine image URL, e.g., from the first exercise or a placeholder
      // String? imageUrl;
      // if (exercises.isNotEmpty && exercises.first.imageUrl != null && exercises.first.imageUrl!.isNotEmpty) {
      //   imageUrl = exercises.first.imageUrl;
      // }
      // else if (exercises.isNotEmpty && exercises.first.gifUrl != null && exercises.first.gifUrl!.isNotEmpty) {
      //   imageUrl = exercises.first.gifUrl; // Prioritize GIF if available
      // }

      return Workout(
        id:
            'rec_${name.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        name:
            name, // Using template_name as name. 'focus' can be used if Workout model had a description field.
        // description: focus, // Workout model does not have description
        exercises: exercises,
        duration: Duration(
          minutes: estimatedDurationMinutes,
        ), // Corrected to use Duration
        // estimatedDurationMinutes: estimatedDurationMinutes, // Workout model uses 'duration'
        // imageUrl: imageUrl, // Workout model does not have imageUrl
        // category: 'Recommended',
        // difficultyLevel: 'Intermediate',
        timestamp:
            DateTime.now(), // Setting timestamp to now, can be null if model allows
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error building workout $name: $e');
      return Workout(
        id:
            'error_${name.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Error Loading: $name',
        // description: 'Could not load exercises for this workout.',
        exercises: [],
        duration: Duration.zero, // Corrected to use Duration
        // estimatedDurationMinutes: 0,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  // --- Public Methods for Specific Recommendation Types ---

  Future<List<Workout>> getContentBasedRecommendedWorkouts({
    required String userId,
  }) async {
    return _fetchAndProcessCategorizedRecommendations(
      userId,
      'for_you_recommendations',
    );
  }

  Future<List<Workout>> getCollaborativeRecommendedWorkouts({
    required String userId,
  }) async {
    return _fetchAndProcessCategorizedRecommendations(
      userId,
      'community_recommendations',
    );
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

  // Simulates fetching all "For You" workouts from API
  Future<List<Workout>> getAllRecommendedWorkouts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('User not logged in, cannot fetch recommendations.');
      return []; // Return empty list if user is not logged in
    }
    // This method might be deprecated. If called, perhaps default to content-based.
    // Or, if your old endpoint returned a general mix, this might need a different backend call.
    // For now, let's assume it defaults to content-based if still used.
    debugPrint(
      "getAllRecommendedWorkouts is called, defaulting to content-based. Consider removing or refactoring.",
    );
    return getContentBasedRecommendedWorkouts(userId: userId);
  }
}
