import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart'; // Import Exercise
import 'package:heronfit/features/workout/models/set_data_model.dart'; // Import SetData
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Import providers

// Convert to ConsumerWidget
class WorkoutCompleteScreen extends ConsumerWidget {
  final Workout workout;
  final List<Exercise> detailedExercises; // Receive detailed exercises

  const WorkoutCompleteScreen({
    super.key,
    required this.workout,
    required this.detailedExercises,
  });

  // Helper function to format sets and reps
  String _formatSetsAndReps(List<SetData> sets) {
    if (sets.isEmpty) {
      return 'No sets recorded';
    }
    // Example: Group similar sets, e.g., 3 sets of 8 reps -> "3 x 8"
    // This is a simple example; more complex grouping might be needed
    final firstSet = sets.first;
    int count = 0;
    for (final set in sets) {
      if (set.kg == firstSet.kg && set.reps == firstSet.reps) {
        count++;
      } else {
        // If sets vary, provide a more general summary or list them all
        return '${sets.length} sets'; // Simple fallback
      }
    }
    return '$count x ${firstSet.reps} reps${firstSet.kg > 0 ? ' @ ${firstSet.kg}kg' : ''}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy'); // Date formatter
    final String formattedDate = dateFormat.format(workout.timestamp);
    final String durationString =
        '${workout.duration.inMinutes} min ${workout.duration.inSeconds.remainder(60)} sec';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
            size: 30.0,
          ),
          onPressed: () {
            // Navigate home when back is pressed on this screen
            context.go(AppRoutes.home);
          },
        ),
        title: Text(
          'Workout Complete',
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: HeronFitTheme.primary,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Make content scrollable
                  child: Column(
                    children: [
                      // --- Image and Congrats Message ---
                      Container(
                        width: double.infinity,
                        height: 180.0, // Adjusted height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/workout_complete.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'You\'re One Step Closer to Your Goals!', // Corrected string literal
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          // Slightly larger
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'You crushed it today! Keep up the momentum.',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          // Slightly larger
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // --- Workout Summary Card ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: HeronFitTheme.bgSecondary,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0, // Reduced blur
                              color: HeronFitTheme.dropShadow.withAlpha(
                                (255 * 0.5).round(),
                              ), // Use withAlpha
                              offset: const Offset(0.0, 4.0), // Reduced offset
                            ),
                          ],
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // More rounded
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            16.0,
                          ), // Adjusted padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.name,
                                style: HeronFitTheme.textTheme.titleMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration: $durationString',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                  Text(
                                    'Date: $formattedDate',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16.0),
                              Text(
                                'Exercises Performed:',
                                style: HeronFitTheme.textTheme.labelLarge
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              // Display detailed exercises with sets/reps
                              if (detailedExercises.isEmpty)
                                Text(
                                  'No exercises recorded.',
                                  style: HeronFitTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.textMuted,
                                      ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable inner scroll
                                  itemCount: detailedExercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise = detailedExercises[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            // Allow text wrapping
                                            child: Text(
                                              exercise.name,
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        HeronFitTheme
                                                            .textPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            _formatSetsAndReps(exercise.sets),
                                            style: HeronFitTheme
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      HeronFitTheme.textMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Action Buttons ---
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  // 1. Save the workout as a template
                  final storageService = ref.read(
                    workoutStorageServiceProvider,
                  ); // Use ref.read
                  bool savedSuccessfully = false;
                  try {
                    // Create a new Workout object specifically for saving as a template
                    // Use a new ID or let the service handle ID generation if needed
                    final templateToSave = Workout(
                      id:
                          UniqueKey()
                              .toString(), // Generate new ID for template
                      name: workout.name,
                      exercises:
                          detailedExercises
                              .map((e) => e.name)
                              .toList(), // Save exercise names
                      duration:
                          workout
                              .duration, // Duration might be less relevant for a template?
                      createdAt:
                          DateTime.now(), // Set the creation timestamp for sorting
                      // timestamp/createdAt are not needed for a template definition
                    );
                    await storageService.saveWorkout(
                      templateToSave,
                    ); // Assuming this saves as a template
                    savedSuccessfully = true;
                  } catch (e) {
                    // Show error message immediately if save fails
                    if (!context.mounted) return; // Add mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving template: $e')),
                    );
                  }

                  // Show success message only if saved successfully
                  if (savedSuccessfully) {
                    if (!context.mounted) return; // Add mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout saved as template!'),
                      ),
                    );
                    // Invalidate the provider to refresh the list on the workout screen
                    ref.invalidate(savedWorkoutsProvider);
                  }

                  // 2. Navigate home regardless of save success/failure
                  if (!context.mounted) return; // Add mounted check
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  backgroundColor: HeronFitTheme.primary,
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Match card rounding
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Save as Template & Go Home'), // Updated text
              ),
              const SizedBox(height: 12.0), // Space between buttons
              OutlinedButton(
                // Use OutlinedButton for secondary action
                onPressed: () {
                  // Simply navigate home without saving
                  context.go(AppRoutes.home);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  foregroundColor: HeronFitTheme.primary, // Text color
                  side: BorderSide(
                    color: HeronFitTheme.primary,
                  ), // Border color
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Match card rounding
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Go Home'), // New button
              ),
            ],
          ),
        ),
      ),
    );
  }
}
