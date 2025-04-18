import '../models/exercise_model.dart'; // Import Exercise model

class WorkoutCompleteModel {
  final String workoutId;
  final DateTime startTime;
  final DateTime endTime;
  final String workoutName;
  final List<Exercise> exercises; // Changed type

  WorkoutCompleteModel({
    required this.workoutId,
    required this.startTime,
    required this.endTime,
    required this.workoutName,
    required this.exercises,
  });

  Duration get workoutDuration => endTime.difference(startTime);
}
