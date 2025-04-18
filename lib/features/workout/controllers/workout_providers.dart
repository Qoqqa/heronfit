import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/services/workout_storage_service.dart'; // Assuming this exists
import 'package:heronfit/core/services/workout_recommendation_service.dart'; // Assuming this exists
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart'; // Import SetData

// Provider for the WorkoutStorageService (adjust if already defined elsewhere)
final workoutStorageServiceProvider = Provider(
  (ref) => WorkoutStorageService(),
);

// Provider for the WorkoutRecommendationService (adjust if already defined elsewhere)
final workoutRecommendationServiceProvider = Provider(
  (ref) => WorkoutRecommendationService(),
);

// Provider to fetch saved workout templates
final savedWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final storageService = ref.watch(workoutStorageServiceProvider);
  // Fetch all workouts first
  final allWorkouts = await storageService.getSavedWorkouts();
  // Sort by createdAt descending (newest first)
  allWorkouts.sort((a, b) {
    final dateA = a.createdAt ?? DateTime(1970); // Handle null createdAt
    final dateB = b.createdAt ?? DateTime(1970);
    return dateB.compareTo(dateA); // Descending order
  });
  return allWorkouts;
});

// Provider to get the most recent N saved workouts
final recentSavedWorkoutsProvider =
    Provider.family<AsyncValue<List<Workout>>, int>((ref, count) {
      return ref.watch(savedWorkoutsProvider).whenData((workouts) {
        return workouts.take(count).toList();
      });
    });

// Provider to fetch recommended workouts for the main screen preview (limit 4)
final recommendedWorkoutsProvider = FutureProvider.autoDispose<List<Workout>>((
  ref,
) async {
  final recommendationService = ref.watch(workoutRecommendationServiceProvider);
  // Fetch a specific number for the preview, e.g., 4
  return recommendationService.getRecommendedWorkouts(4);
});

// Provider to manage the selected category filter on the RecommendedWorkoutsScreen
final selectedCategoryProvider = StateProvider<String>((ref) => 'For You');

// Provider to fetch workouts based on the selected category for RecommendedWorkoutsScreen
final recommendedWorkoutsByCategoryProvider =
    FutureProvider.autoDispose<List<Workout>>((ref) async {
      final selectedCategory = ref.watch(selectedCategoryProvider);
      final recommendationService = ref.watch(
        workoutRecommendationServiceProvider,
      );

      if (selectedCategory == 'For You') {
        // Fetch all "For You" workouts for the dedicated screen
        return recommendationService.getAllRecommendedWorkouts();
      } else {
        // Fetch premade workouts based on the selected goal category
        return recommendationService.getPremadeWorkouts(selectedCategory);
      }
    });

// State for the active workout being created/edited
@immutable
class ActiveWorkoutState {
  final String id;
  final String name;
  final String notes;
  final List<Exercise> exercises; // Exercise should contain its sets
  final Duration duration;
  final bool isTimerRunning;
  final Workout? originalWorkout; // To know if editing a template

  const ActiveWorkoutState({
    required this.id,
    this.name = 'New Workout',
    this.notes = '',
    this.exercises = const [],
    this.duration = Duration.zero,
    this.isTimerRunning = false,
    this.originalWorkout,
  });

  ActiveWorkoutState copyWith({
    String? id,
    String? name,
    String? notes,
    List<Exercise>? exercises,
    Duration? duration,
    bool? isTimerRunning,
    Workout? originalWorkout,
    bool clearOriginalWorkout =
        false, // Flag to explicitly nullify originalWorkout
  }) {
    return ActiveWorkoutState(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      originalWorkout:
          clearOriginalWorkout ? null : originalWorkout ?? this.originalWorkout,
    );
  }
}

// Notifier for managing the active workout state
class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  Timer? _timer;
  final Ref _ref;

  ActiveWorkoutNotifier(this._ref, Workout? initialWorkout)
    : super(
        ActiveWorkoutState(
          // Use a new UniqueKey for the active session ID, not the template ID
          id: UniqueKey().toString(),
          name: initialWorkout?.name ?? 'New Workout',
          exercises:
              initialWorkout?.exercises.map((exName) {
                // TODO: Fetch full Exercise details from a repository/service based on exName
                // For now, creating a basic Exercise object
                return Exercise(
                  id:
                      UniqueKey()
                          .toString(), // Each exercise instance needs a unique ID
                  name: exName,
                  // Initialize other fields as needed, potentially from fetched data
                  force: '',
                  level: '',
                  equipment: '',
                  primaryMuscle: '',
                  secondaryMuscles: [],
                  instructions: [],
                  category: '',
                  imageUrl: '',
                  sets: [], // Start with empty sets for a new session
                );
              }).toList() ??
              [],
          // Reset duration when starting from a template or new
          duration: Duration.zero,
          originalWorkout: initialWorkout, // Keep reference to the template
        ),
      ) {
    // Always start the timer when the notifier is created (new workout or from template)
    startTimer();
    // The logic to set duration from initialWorkout is removed
    // as we always want to start fresh.
  }

  void setWorkoutName(String name) {
    state = state.copyWith(name: name);
  }

  void setWorkoutNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void addExercise(Exercise exercise) {
    state = state.copyWith(exercises: [...state.exercises, exercise]);
  }

  void removeExercise(Exercise exercise) {
    state = state.copyWith(
      exercises: state.exercises.where((e) => e != exercise).toList(),
    );
  }

  void addSet(Exercise exercise) {
    final updatedExercises =
        state.exercises.map((e) {
          if (e.id == exercise.id) {
            final newSet = SetData(kg: 0, reps: 0, completed: false);
            return e.copyWith(sets: [...e.sets, newSet]);
          }
          return e;
        }).toList();
    state = state.copyWith(exercises: updatedExercises);
  }

  void updateSet(Exercise exercise, int setIndex, SetData updatedSet) {
    final updatedExercises =
        state.exercises.map((e) {
          if (e.id == exercise.id) {
            final updatedSets = List<SetData>.from(e.sets);
            if (setIndex >= 0 && setIndex < updatedSets.length) {
              updatedSets[setIndex] = updatedSet;
            }
            return e.copyWith(sets: updatedSets);
          }
          return e;
        }).toList();
    state = state.copyWith(exercises: updatedExercises);
  }

  void removeSet(Exercise exercise, int setIndex) {
    final updatedExercises =
        state.exercises.map((e) {
          if (e.id == exercise.id) {
            final updatedSets = List<SetData>.from(e.sets);
            if (setIndex >= 0 && setIndex < updatedSets.length) {
              updatedSets.removeAt(setIndex);
            }
            return e.copyWith(sets: updatedSets);
          }
          return e;
        }).toList();
    state = state.copyWith(exercises: updatedExercises);
  }

  void startTimer() {
    if (state.isTimerRunning) return;
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  Future<Workout?> finishWorkout() async {
    stopTimer();
    final workoutToSave = Workout(
      id: state.id,
      name: state.name,
      notes: state.notes,
      exercises: state.exercises.map((e) => e.name).toList(),
      duration: state.duration,
      createdAt: DateTime.now(),
      timestamp: DateTime.now(), // Ensure timestamp is set
    );

    try {
      await _ref.read(workoutStorageServiceProvider).saveWorkout(workoutToSave);
      debugPrint('Workout Finished and Saved: ${workoutToSave.name}');
      return workoutToSave; // Return the saved workout
    } catch (e) {
      debugPrint('Error saving workout: $e');
      return null; // Return null on error
    }
  }

  void cancelWorkout() {
    stopTimer();
    debugPrint('Workout Cancelled');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider for the active workout notifier
final activeWorkoutProvider = StateNotifierProvider.autoDispose
    .family<ActiveWorkoutNotifier, ActiveWorkoutState, Workout?>((
      ref,
      initialWorkout,
    ) {
      return ActiveWorkoutNotifier(ref, initialWorkout);
    });
