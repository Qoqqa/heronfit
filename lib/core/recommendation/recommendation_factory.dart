import '../../features/workout/models/workout_model.dart';
import 'base_recommendation_service.dart';
import 'random_recommendation_service.dart';
import 'content_based_recommendation_service.dart';
import 'collaborative_recommendation_service.dart';
import 'hybrid_recommendation_service.dart';

enum RecommendationAlgorithm { random, contentBased, collaborative, hybrid }

class RecommendationFactory {
  static BaseRecommendationService getRecommendationService(
    RecommendationAlgorithm algorithm,
  ) {
    switch (algorithm) {
      case RecommendationAlgorithm.random:
        return RandomRecommendationService();
      case RecommendationAlgorithm.contentBased:
        return ContentBasedRecommendationService();
      case RecommendationAlgorithm.collaborative:
        return CollaborativeRecommendationService();
      case RecommendationAlgorithm.hybrid:
        return HybridRecommendationService();
      default:
        return RandomRecommendationService();
    }
  }

  static List<Map<String, dynamic>> getAvailableAlgorithms() {
    return [
      {
        'algorithm': RecommendationAlgorithm.random,
        'name': 'Random',
        'description': 'Completely random workout recommendations',
      },
      {
        'algorithm': RecommendationAlgorithm.contentBased,
        'name': 'Personalized',
        'description': 'Based on your workout history and preferences',
      },
      {
        'algorithm': RecommendationAlgorithm.collaborative,
        'name': 'Community',
        'description': 'Based on what similar users are doing',
      },
      {
        'algorithm': RecommendationAlgorithm.hybrid,
        'name': 'Smart Mix',
        'description': 'Combination of all recommendation techniques',
      },
    ];
  }
}
