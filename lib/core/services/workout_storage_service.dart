import 'dart:convert';
import 'package:flutter/material.dart'; // Import material for UniqueKey and debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/workout/models/workout_model.dart';

class WorkoutStorageService {
  static const String _workoutsKey = 'saved_workouts';

  Future<void> saveWorkout(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getSavedWorkouts();

    // Check if a workout with the same name already exists
    final existingIndex = workouts.indexWhere((w) => w.name == workout.name);

    if (existingIndex != -1) {
      // If it exists, replace it (update) - Ensure ID remains consistent if needed,
      // but current logic generates new ID when saving template.
      // For simplicity, we replace based on name match.
      // We might want to preserve the original ID if updating an existing template.
      // Let's update the existing entry but keep its original ID and createdAt.
      final originalWorkout = workouts[existingIndex];
      final updatedWorkout = workout.copyWith(
        id: originalWorkout.id, // Keep original ID
        createdAt: originalWorkout.createdAt, // Keep original creation date
        // Update other fields like exercises, potentially duration if relevant for template
        exercises: workout.exercises,
        duration: workout.duration, // Or decide if duration should be updated
      );
      workouts[existingIndex] = updatedWorkout;
      debugPrint(
        'Updating existing workout template: ${workout.name}',
      ); // Use debugPrint
    } else {
      // If it doesn't exist, add the new workout (likely a new template)
      // Ensure it has an ID if not provided (though UniqueKey is used in WorkoutCompleteScreen)
      final workoutToAdd =
          workout.id.isEmpty
              ? workout.copyWith(id: UniqueKey().toString())
              : workout;
      workouts.add(workoutToAdd);
      debugPrint(
        'Adding new workout/template: ${workoutToAdd.name}',
      ); // Use debugPrint
    }

    final workoutsJson = workouts.map((w) => w.toJson()).toList();
    debugPrint('Saving workouts: $workoutsJson'); // Use debugPrint
    await prefs.setString(_workoutsKey, jsonEncode(workoutsJson));
  }

  Future<List<Workout>> getSavedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = prefs.getString(_workoutsKey);
    debugPrint('Retrieved workouts JSON: $workoutsJson'); // Use debugPrint
    if (workoutsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(workoutsJson);
    return decoded.map((json) => Workout.fromJson(json)).toList();
  }

  Future<void> deleteWorkout(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getSavedWorkouts();
    workouts.removeWhere((workout) => workout.id == workoutId);
    final workoutsJson = workouts.map((w) => w.toJson()).toList();
    debugPrint(
      'Saving workouts after deletion: $workoutsJson',
    ); // Use debugPrint
    await prefs.setString(_workoutsKey, jsonEncode(workoutsJson));
  }

  Future<void> deleteAllWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workoutsKey); // Remove the key to delete all
    debugPrint('Deleted all saved workouts.'); // Use debugPrint
  }
}
