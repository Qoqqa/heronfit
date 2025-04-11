import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workout_model.dart';
import 'base_recommendation_service.dart';
import '../services/exercise_database_service.dart';
import 'content_based_recommendation_service.dart';

class CollaborativeRecommendationService extends BaseRecommendationService {
  final ExerciseDatabaseService _exerciseService = ExerciseDatabaseService();
  final ContentBasedRecommendationService _fallbackService =
      ContentBasedRecommendationService();

  @override
  Future<List<Workout>> getRecommendations(
    String? userId, {
    int count = 4,
  }) async {
    if (userId == null) {
      return _fallbackService.getRecommendations(null, count: count);
    }

    try {
      // 1. Get user's workout history (exercise preferences)
      final userWorkouts = await _exerciseService.getUserWorkoutHistory(userId);

      if (userWorkouts.isEmpty) {
        // Fallback to content-based if no history
        return _fallbackService.getRecommendations(userId, count: count);
      }

      // 2. Extract user's preferred exercises
      final Set<String> userExercises = {};
      for (var workout in userWorkouts) {
        userExercises.addAll((workout['exercises'] as List).cast<String>());
      }

      // 3. Find similar users (users who did similar exercises)
      final otherUsersWorkouts = await Supabase.instance.client
          .from('workouts')
          .select('user_id, exercises')
          .neq('user_id', userId); // Exclude current user

      // 4. Calculate similarity scores (Jaccard similarity coefficient)
      final Map<String, double> userSimilarity = {};
      final Map<String, Set<String>> otherUserExercises = {};

      for (var workout in otherUsersWorkouts) {
        final otherUserId = workout['user_id'] as String;
        final exercises = Set<String>.from(
          (workout['exercises'] as List).cast<String>(),
        );

        // Aggregate exercises for each user
        otherUserExercises.putIfAbsent(otherUserId, () => {}).addAll(exercises);
      }

      // Calculate similarity for each user
      for (var entry in otherUserExercises.entries) {
        final otherUserId = entry.key;
        final otherExercises = entry.value;

        // Calculate Jaccard similarity: intersection size / union size
        final intersection = userExercises.intersection(otherExercises);
        final union = userExercises.union(otherExercises);

        if (union.isNotEmpty) {
          final similarity = intersection.length / union.length;
          userSimilarity[otherUserId] = similarity;
        }
      }

      // 5. Get top similar users
      final similarUserIds =
          userSimilarity.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final topSimilarUserIds =
          similarUserIds
              .take(min(3, similarUserIds.length))
              .map((e) => e.key)
              .toList();

      if (topSimilarUserIds.isEmpty) {
        return _fallbackService.getRecommendations(userId, count: count);
      }

      // 6. Get workouts from similar users
      final similarUsersWorkouts = await _exerciseService
          .getSimilarUsersWorkouts(topSimilarUserIds);

      // 7. Recommend workouts user hasn't done yet
      final recommendations = <Workout>[];
      final userWorkoutExerciseSets =
          userWorkouts
              .map(
                (w) =>
                    Set<String>.from((w['exercises'] as List).cast<String>()),
              )
              .toList();

      for (var workout in similarUsersWorkouts) {
        // Check if user hasn't done this workout
        final workoutExercises = (workout['exercises'] as List).cast<String>();
        final workoutExerciseSet = Set<String>.from(workoutExercises);

        // Skip if user has done many of these exercises together (similarity > 0.7)
        bool isTooSimilar = false;
        for (var userExerciseSet in userWorkoutExerciseSets) {
          final intersection = workoutExerciseSet.intersection(userExerciseSet);
          if (intersection.length >= 0.7 * workoutExerciseSet.length) {
            isTooSimilar = true;
            break;
          }
        }

        if (isTooSimilar) continue;

        // Create workout recommendation from similar user's workout
        final recommendedWorkout = Workout(
          id: const Uuid().v4(), // New ID for recommendation
          name: workout['name'] as String,
          exercises: workoutExercises,
          duration: Duration(seconds: workout['duration'] as int),
          timestamp: DateTime.now(),
        );

        recommendations.add(recommendedWorkout);

        // Stop after getting enough recommendations
        if (recommendations.length >= count) break;
      }

      // If we couldn't find enough collaborative recommendations
      if (recommendations.length < count) {
        // Fill the rest with content-based recommendations
        final contentBased = await _fallbackService.getRecommendations(
          userId,
          count: count - recommendations.length,
        );
        recommendations.addAll(contentBased);
      }

      return recommendations;
    } catch (e) {
      print('Error generating collaborative recommendations: $e');
      return _fallbackService.getRecommendations(userId, count: count);
    }
  }

  @override
  String get algorithmName => 'Collaborative Filtering Recommendations';
}
