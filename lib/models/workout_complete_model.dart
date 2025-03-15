class WorkoutCompleteModel {
  final String workoutId;
  final DateTime startTime;
  final DateTime endTime;
  final String workoutName;

  WorkoutCompleteModel({
    required this.workoutId,
    required this.startTime,
    required this.endTime,
    required this.workoutName,
  });

  Duration get workoutDuration => endTime.difference(startTime);
}