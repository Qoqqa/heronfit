import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/workout/models/workout_model.dart';

class WorkoutStorageService {
  static const String _workoutsKey = 'saved_workouts';

  Future<void> saveWorkout(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getSavedWorkouts();
    workouts.add(workout);
    final workoutsJson = workouts.map((w) => w.toJson()).toList();
    print('Saving workouts: $workoutsJson'); // Debug log
    await prefs.setString(_workoutsKey, jsonEncode(workoutsJson));
  }

  Future<List<Workout>> getSavedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = prefs.getString(_workoutsKey);
    print('Retrieved workouts JSON: $workoutsJson'); // Debug log
    if (workoutsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(workoutsJson);
    return decoded.map((json) => Workout.fromJson(json)).toList();
  }
}
