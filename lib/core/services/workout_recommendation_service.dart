import '../../models/workout_model.dart';
import '../recommendation/recommendation_factory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRecommendationService {
  // The algorithm to use - can be changed via settings or UI
  RecommendationAlgorithm _currentAlgorithm = RecommendationAlgorithm.hybrid;
  
  // Get workout recommendations
  Future<List<Workout>> getRecommendedWorkouts(int count) async {
    final recommendationService = 
        RecommendationFactory.getRecommendationService(_currentAlgorithm);
    
    try {
      // Get current user ID if logged in
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      return await recommendationService.getRecommendations(userId, count: count);
    } catch (e) {
      print('Error in recommendation service: $e');
      // Fallback to random recommendations if there's an error
      final fallbackService = 
          RecommendationFactory.getRecommendationService(RecommendationAlgorithm.random);
      return await fallbackService.getRecommendations(null, count: count);
    }
  }
  
  // Set the algorithm to use
  void setAlgorithm(RecommendationAlgorithm algorithm) {
    _currentAlgorithm = algorithm;
  }
  
  // Get available algorithms for UI
  List<Map<String, dynamic>> getAvailableAlgorithms() {
    return RecommendationFactory.getAvailableAlgorithms();
  }
  
  // Get current algorithm name
  String get currentAlgorithmName {
    final service = RecommendationFactory.getRecommendationService(_currentAlgorithm);
    return service.algorithmName;
  }
}