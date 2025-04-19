import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/workout/models/exercise_model.dart';
import '../../features/workout/models/set_data_model.dart';
import '../../features/workout/models/workout_model.dart';

class WorkoutSupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Updated saveWorkout to handle nested structure
  Future<void> saveWorkout(Workout workout) async {
    final userId = _supabase.auth.currentUser!.id;

    try {
      // Use a transaction to ensure all or nothing is saved
      await _supabase.rpc(
        'save_full_workout',
        params: {
          'p_user_id': userId,
          'p_workout_name': workout.name,
          'p_workout_duration': workout.duration.inSeconds,
          'p_workout_timestamp': workout.timestamp.toIso8601String(),
          'p_exercises':
              workout.exercises
                  .map(
                    (exercise) => {
                      'exercise_id':
                          exercise.id, // Assuming Exercise model has the DB ID
                      'order_index': workout.exercises.indexOf(exercise),
                      'sets':
                          exercise.sets
                              .map(
                                (set) => {
                                  'set_number': exercise.sets.indexOf(set) + 1,
                                  'weight_kg': set.kg,
                                  'reps': set.reps,
                                  'completed': set.completed,
                                },
                              )
                              .toList(),
                    },
                  )
                  .toList(),
        },
      );
    } catch (e) {
      debugPrint('Error saving workout: $e'); // Use debugPrint
      // Consider throwing a custom exception or returning an error status
      rethrow; // Re-throw the error to be handled by the caller
    }
  }

  // Updated getWorkoutHistory to fetch nested structure and fix PGRST108
  Future<List<Workout>> getWorkoutHistory() async {
    final userId = _supabase.auth.currentUser!.id;

    try {
      // Refined select query using explicit aliases for relationships
      final response = await _supabase
          .from('workouts')
          .select('''
            id, name, duration, timestamp, 
            workout_exercises:workout_exercises (
              id, order_index, exercise_id,
              exercise:exercises ( id, name, force, level, mechanic, equipment, "primaryMuscles", "secondaryMuscles", instructions, category, images ),
              sets:exercise_sets ( id, set_number, weight_kg, reps, completed )
            )
          ''') // Removed created_at
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .order(
            'order_index',
            referencedTable: 'workout_exercises',
            ascending: true,
          )
          .order(
            'set_number',
            referencedTable:
                'workout_exercises.exercise_sets', // Correct parameter name
            ascending: true,
          );

      // Map the response to Workout objects
      final List<Workout> workouts = [];
      for (final workoutData in response) {
        final List<Exercise> exercises = [];
        // Use the alias 'workout_exercises' used in the select query
        final workoutExercisesData =
            workoutData['workout_exercises'] as List? ?? [];

        for (final workoutExercise in workoutExercisesData) {
          // Use the alias 'exercise' used in the select query
          final exerciseData = workoutExercise['exercise'];
          // Use the alias 'sets' used in the select query
          final setsData = workoutExercise['sets'] as List? ?? [];

          if (exerciseData != null) {
            final List<SetData> sets =
                setsData.map((setData) {
                  return SetData(
                    kg: (setData['weight_kg'] ?? 0).toInt(),
                    reps: setData['reps'] ?? 0,
                    completed: setData['completed'] ?? false,
                  );
                }).toList();

            try {
              // Ensure Exercise.fromJson can handle the nested 'exercise' data
              exercises.add(
                Exercise.fromJson(exerciseData).copyWith(sets: sets),
              );
            } catch (e) {
              debugPrint(
                "Error parsing exercise during history fetch: $e\nData: $exerciseData",
              ); // Use debugPrint
            }
          }
        }

        workouts.add(
          Workout.fromSupabase(workoutData).copyWith(exercises: exercises),
        );
      }

      return workouts;
    } catch (e) {
      debugPrint('Error loading history: $e'); // Use debugPrint
      rethrow;
    }
  }

  // New method to fetch exercises by IDs
  Future<List<Exercise>> getExercisesByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .inFilter('id', ids);

      final exercises =
          response.map((data) => Exercise.fromJson(data)).toList();

      // Create a map for quick lookup
      final exerciseMap = {for (var ex in exercises) ex.id: ex};

      // Return exercises in the original order of IDs
      return ids.map((id) => exerciseMap[id]).whereType<Exercise>().toList();
    } catch (e) {
      debugPrint('Error fetching exercises by IDs: $e');
      rethrow;
    }
  }

  // Updated getWorkoutStats to use workout_exercises and exercise_sets
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final userId = _supabase.auth.currentUser!.id;

    // Fetch basic workout info
    final workoutResponse = await _supabase
        .from('workouts')
        .select('id, duration')
        .eq('user_id', userId);

    if (workoutResponse.isEmpty) {
      return {
        'total_workouts': 0,
        'total_duration': 0,
        'total_exercises_performed': 0,
        'total_sets_performed': 0,
        'avg_duration': 0.0,
      };
    }

    final workoutIds = workoutResponse.map((w) => w['id'] as String).toList();

    // Count distinct exercises performed across all workouts
    final exerciseCountResponse = await _supabase
        .from('workout_exercises')
        .select('exercise_id')
        .inFilter('workout_id', workoutIds)
        .count(CountOption.exact);

    // Get workout_exercise_ids for the sets count
    final workoutExerciseIdsResponse = await _supabase
        .from('workout_exercises')
        .select('id')
        .inFilter('workout_id', workoutIds);
    final workoutExerciseIds =
        workoutExerciseIdsResponse.map((e) => e['id']).toList();

    int totalSetsPerformed = 0;
    if (workoutExerciseIds.isNotEmpty) {
      final setsCountResponse = await _supabase
          .from('exercise_sets')
          .select('id')
          .inFilter('workout_exercise_id', workoutExerciseIds)
          .count(CountOption.exact);
      totalSetsPerformed = setsCountResponse.count; // Remove unnecessary ?? 0
    }

    int totalWorkouts = workoutResponse.length;
    int totalDurationSeconds = workoutResponse.fold(
      0,
      (sum, w) => sum + (w['duration'] as int? ?? 0),
    );
    int totalExercisesPerformed =
        exerciseCountResponse.count; // Remove unnecessary ?? 0

    double avgDuration =
        totalWorkouts > 0 ? totalDurationSeconds / totalWorkouts : 0.0;

    return {
      'total_workouts': totalWorkouts,
      'total_duration': totalDurationSeconds,
      'total_exercises_performed': totalExercisesPerformed,
      'total_sets_performed': totalSetsPerformed,
      'avg_duration': avgDuration,
    };
  }
}

// Helper function (or place inside the class) to create the Supabase function
/*
-- Run this SQL in your Supabase SQL Editor ONCE:

CREATE OR REPLACE FUNCTION save_full_workout(
    p_user_id uuid,
    p_workout_name text,
    p_workout_duration int,
    p_workout_timestamp timestamptz,
    p_exercises jsonb -- Array of exercises with their sets
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_workout_id uuid;
    v_exercise jsonb;
    v_workout_exercise_id uuid;
    v_set jsonb;
BEGIN
    -- Insert into workouts table
    INSERT INTO public.workouts (user_id, name, duration, "timestamp")
    VALUES (p_user_id, p_workout_name, p_workout_duration, p_workout_timestamp)
    RETURNING id INTO v_workout_id;

    -- Loop through exercises in the input JSON array
    FOR v_exercise IN SELECT * FROM jsonb_array_elements(p_exercises)
    LOOP
        -- Insert into workout_exercises table
        INSERT INTO public.workout_exercises (workout_id, exercise_id, order_index)
        VALUES (v_workout_id, (v_exercise->>'exercise_id')::uuid, (v_exercise->>'order_index')::int)
        RETURNING id INTO v_workout_exercise_id;

        -- Loop through sets in the exercise's 'sets' JSON array
        FOR v_set IN SELECT * FROM jsonb_array_elements(v_exercise->'sets')
        LOOP
            -- Insert into exercise_sets table
            INSERT INTO public.exercise_sets (workout_exercise_id, set_number, weight_kg, reps, completed)
            VALUES (
                v_workout_exercise_id,
                (v_set->>'set_number')::int,
                (v_set->>'weight_kg')::numeric,
                (v_set->>'reps')::int,
                (v_set->>'completed')::boolean
            );
        END LOOP;
    END LOOP;
END;
$$;

*/
