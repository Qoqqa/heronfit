import '../../models/workout_model.dart';

abstract class BaseRecommendationService {
  /// Get workout recommendations for a user
  Future<List<Workout>> getRecommendations(String? userId, {int count = 4});
  
  /// Get the name of this recommendation algorithm
  String get algorithmName;
}