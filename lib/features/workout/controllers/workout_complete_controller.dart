import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../../../core/services/workout_storage_service.dart';
import '../models/workout_complete_model.dart';

class WorkoutCompleteController {
  final WorkoutCompleteModel model;
  final WorkoutStorageService _storageService = WorkoutStorageService();

  WorkoutCompleteController(this.model);

  // Add these getters to access model properties
  String get workoutName => model.workoutName;
  DateTime get startTime => model.startTime;
  Duration get workoutDuration => model.workoutDuration;

  Future<void> saveWorkout() async {
    final workout = Workout(
      id: const Uuid().v4(),
      name: model.workoutName,
      exercises: model.exercises,
      duration: model.endTime.difference(model.startTime),
      timestamp: model.endTime,
    );

    await _storageService.saveWorkout(workout);
  }

  String getWorkoutDuration() {
    final duration = model.endTime.difference(model.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
