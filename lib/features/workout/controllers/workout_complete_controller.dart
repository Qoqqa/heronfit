import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../../../core/services/workout_supabase_service.dart';
import '../models/workout_complete_model.dart';
import 'workout_providers.dart';

class WorkoutCompleteController {
  final WorkoutCompleteModel model;
  final WorkoutSupabaseService _supabaseService;

  WorkoutCompleteController(this.model, this._supabaseService);

  String get workoutName => model.workoutName;
  DateTime get startTime => model.startTime;
  Duration get workoutDuration => model.workoutDuration;

  Future<void> saveWorkout(WidgetRef ref) async {
    final workout = Workout(
      id: const Uuid().v4(), // Placeholder ID
      name: model.workoutName,
      exercises: model.exercises, // Pass List<Exercise>
      duration: model.endTime.difference(model.startTime),
      timestamp: model.endTime,
    );

    try {
      await _supabaseService.saveWorkout(workout);
      ref.invalidate(workoutHistoryProvider);
      ref.invalidate(workoutStatsProvider);
    } catch (e) {
      rethrow;
    }
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
