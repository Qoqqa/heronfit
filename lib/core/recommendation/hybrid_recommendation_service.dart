import 'dart:math';
import '../../models/workout_model.dart';
import 'base_recommendation_service.dart';
import 'content_based_recommendation_service.dart';
import 'collaborative_recommendation_service.dart';
import 'random_recommendation_service.dart';

class HybridRecommendationService extends BaseRecommendationService {
  final ContentBasedRecommendationService _contentBasedService = ContentBasedRecommendationService();
  final CollaborativeRecommendationService _collaborativeService = CollaborativeRecommendationService();
  final RandomRecommendationService _randomService = RandomRecommendationService();
  
  @override
  Future<List<Workout>> getRecommendations(String? userId, {int count = 4}) async {
    try {
      final recommendations = <Workout>[];
      
      // If no userId provided, just use random recommendations
      if (userId == null) {
        return _randomService.getRecommendations(null, count: count);
      }
      
      // 1. Get recommendations from collaborative filtering (2)
      final collaborative = await _collaborativeService.getRecommendations(
        userId, 
        count: 2
      );
      recommendations.addAll(collaborative);
      
      // 2. Get recommendations from content-based (2)
      if (recommendations.length < count) {
        final contentBased = await _contentBasedService.getRecommendations(
          userId, 
          count: 2
        );
        recommendations.addAll(contentBased);
      }
      
      // 3. If we don't have enough, fill with random recommendations
      if (recommendations.length < count) {
        final random = await _randomService.getRecommendations(
          userId,
          count: count - recommendations.length
        );
        recommendations.addAll(random);
      }
      
      // Ensure we don't return more than requested
      return recommendations.take(count).toList();
    } catch (e) {
      print('Error generating hybrid recommendations: $e');
      // Fallback to random recommendations if anything goes wrong
      return _randomService.getRecommendations(userId, count: count);
    }
  }
  
  @override
  String get algorithmName => 'Hybrid Recommendations';
}