import '../../../widgets/recommendation_algorithm_selector.dart'; // Assuming this exists and is used

class WorkoutWidget extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState(); // Call super.initState()
    // Use the helper function from model_utils.dart
    _model = createWorkoutModel(context, widget); // Correctly use the helper
    _storageService = WorkoutStorageService();
    _recommendationService = WorkoutRecommendationService();
    _loadSavedWorkouts();
    _loadRecommendedWorkouts();
  }
}
