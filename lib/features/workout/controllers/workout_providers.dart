import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/services/workout_storage_service.dart'; // Assuming this exists
import 'package:heronfit/core/services/workout_recommendation_service.dart'; // Assuming this exists
import 'package:heronfit/core/services/workout_supabase_service.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart'; // Import SetData
import 'package:uuid/uuid.dart'; // Import Uuid for unique IDs
import 'package:heronfit/features/auth/controllers/auth_controller.dart'; // For currentUserProvider

// Provider for the WorkoutStorageService (adjust if already defined elsewhere)
final workoutStorageServiceProvider = Provider(
  (ref) => WorkoutStorageService(),
);

// Provider for the WorkoutRecommendationService (adjust if already defined elsewhere)
final workoutRecommendationServiceProvider = Provider(
  (ref) => WorkoutRecommendationService(ref), // Pass ref to the constructor
);

// Provider for the WorkoutSupabaseService instance
final workoutServiceProvider = Provider<WorkoutSupabaseService>((ref) {
  return WorkoutSupabaseService();
});

// FutureProvider to fetch the workout history list
final workoutHistoryProvider = FutureProvider<List<Workout>>((ref) async {
  final workoutService = ref.watch(workoutServiceProvider);
  return await workoutService.getWorkoutHistory();
});

// FutureProvider to fetch workout statistics
final workoutStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final workoutService = ref.watch(workoutServiceProvider);
  return await workoutService.getWorkoutStats();
});

// Provider for formatting duration (can be kept simple or moved to utils)
final formatDurationProvider = Provider<String Function(Duration)>((ref) {
  return (Duration duration) {
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
  };
});

// Provider for formatting date (can be kept simple or moved to utils)
final formatDateProvider = Provider<String Function(DateTime)>((ref) {
  return (DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      // Consider using intl package for more robust formatting
      return '${date.day}/${date.month}/${date.year}';
    }
  };
});

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
  final userId = ref.watch(currentUserProvider)?.id;

  if (userId == null) {
    // If no user is logged in, return empty list or handle as appropriate
    return [];
  }
  // Fetch all content-based recommendations
  final allContentBased = await recommendationService
      .getContentBasedRecommendedWorkouts(userId: userId);
  // Return the first 4 for the preview
  return allContentBased.take(4).toList();
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
  final List<Exercise> exercises; // Exercise should contain its sets
  final Duration duration;
  final bool isTimerRunning;
  final Workout? originalWorkout; // To know if editing a template

  const ActiveWorkoutState({
    required this.id,
    this.name = 'New Workout',
    this.exercises = const [],
    this.duration = Duration.zero,
    this.isTimerRunning = false,
    this.originalWorkout,
  });

  ActiveWorkoutState copyWith({
    String? id,
    String? name,
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
          id: const Uuid().v4(),
          name: initialWorkout?.name ?? 'New Workout',
          // Correctly map Exercise objects, ensuring sets are initialized
          exercises:
              initialWorkout?.exercises.map((ex) {
                // Create a new Exercise instance, copying details and initializing sets
                return ex.copyWith(
                  sets: [],
                ); // Start with empty sets for a new session
              }).toList() ??
              [],
          duration: Duration.zero,
          originalWorkout: initialWorkout,
        ),
      ) {
    startTimer();
  }

  void setWorkoutName(String name) {
    state = state.copyWith(name: name);
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
            // Removed rest timer duration logic
            final newSet = SetData(kg: 0, reps: 0, completed: false);
            return e.copyWith(sets: [...e.sets, newSet]);
          }
          return e;
        }).toList();
    state = state.copyWith(exercises: updatedExercises);
  }

  // Updated method to handle individual field updates
  void updateSetData(
    Exercise exercise,
    int setIndex, {
    int? kg,
    int? reps,
    bool? completed,
  }) {
    final updatedExercises =
        state.exercises.map((e) {
          if (e.id == exercise.id) {
            final updatedSets = List<SetData>.from(e.sets);
            if (setIndex >= 0 && setIndex < updatedSets.length) {
              final currentSet = updatedSets[setIndex];
              updatedSets[setIndex] = currentSet.copyWith(
                kg: kg ?? currentSet.kg,
                reps: reps ?? currentSet.reps,
                completed: completed ?? currentSet.completed,
              );
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

    final exercisesWithCompletedSets =
        state.exercises
            .where((ex) => ex.sets.any((set) => set.completed))
            // Create new Exercise instances with only the completed sets for saving history
            .map(
              (ex) => ex.copyWith(
                sets: ex.sets.where((set) => set.completed).toList(),
              ),
            )
            .toList();

    if (exercisesWithCompletedSets.isEmpty) {
      debugPrint('No exercises with completed sets found. Workout not saved.');
      return null; // Don't save if nothing was completed
    }

    final workoutToSave = Workout(
      id: state.id,
      name: state.name,
      // Save the List<Exercise> with their completed sets
      exercises: exercisesWithCompletedSets,
      duration: state.duration,
      createdAt: DateTime.now(),
      timestamp: DateTime.now(),
    );

    try {
      // Use the Supabase service provider to save workout history
      await _ref.read(workoutServiceProvider).saveWorkout(workoutToSave);
      debugPrint(
        'Workout Finished and Saved to Supabase: ${workoutToSave.name}',
      );
      // Invalidate providers to refresh history/stats
      _ref.invalidate(workoutHistoryProvider);
      _ref.invalidate(workoutStatsProvider);
      return workoutToSave;
    } catch (e) {
      debugPrint('Error saving workout to Supabase: $e');
      // Consider showing an error message to the user
      return null;
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
