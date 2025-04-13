import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/workout/models/workout_model.dart';

class WorkoutSupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveWorkout(Workout workout) async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('workouts').insert({
      'user_id': userId,
      'name': workout.name,
      'duration': workout.duration.inSeconds,
      'exercises': workout.exercises,
      'timestamp': workout.timestamp.toIso8601String(),
    });
  }

  Future<List<Workout>> getWorkoutHistory() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);

    return response.map<Workout>((json) => Workout.fromSupabase(json)).toList();
  }

  Future<Map<String, dynamic>> getWorkoutStats() async {
    final userId = _supabase.auth.currentUser!.id;

    final workouts = await _supabase
        .from('workouts')
        .select()
        .eq('user_id', userId);

    if (workouts.isEmpty) {
      return {
        'total_workouts': 0,
        'total_duration': 0,
        'total_exercises': 0,
        'avg_duration': 0,
      };
    }

    int totalWorkouts = workouts.length;
    int totalDuration = 0;
    int totalExercises = 0;

    for (var workout in workouts) {
      totalDuration += workout['duration'] as int;
      totalExercises += (workout['exercises'] as List).length;
    }

    double avgDuration = totalDuration / totalWorkouts;

    return {
      'total_workouts': totalWorkouts,
      'total_duration': totalDuration,
      'total_exercises': totalExercises,
      'avg_duration': avgDuration,
    };
  }
}
