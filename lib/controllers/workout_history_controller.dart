import 'package:heronfit/core/services/workout_supabase_service.dart';
import 'package:heronfit/models/workout_model.dart';

class WorkoutHistoryController {
  final WorkoutSupabaseService _workoutService = WorkoutSupabaseService();

  Future<List<Workout>> getWorkoutHistory() async {
    return await _workoutService.getWorkoutHistory();
  }

  Future<Map<String, dynamic>> getWorkoutStats() async {
    return await _workoutService.getWorkoutStats();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}