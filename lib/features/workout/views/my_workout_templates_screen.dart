import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/services/workout_storage_service.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';

class MyWorkoutTemplatesScreen extends ConsumerWidget {
  const MyWorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(savedWorkoutsProvider);
    final storageService = ref.read(workoutStorageServiceProvider);

    Future<void> deleteTemplate(String workoutId) async {
      try {
        await storageService.deleteWorkout(workoutId);
        ref.invalidate(savedWorkoutsProvider); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting template: $e')));
      }
    }

    Future<void> _showDeleteConfirmationDialog(
      BuildContext context,
      Workout template,
    ) async {
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Delete Template?'),
            content: Text(
              'Are you sure you want to delete the template "${template.name}"?',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: HeronFitTheme.error,
                ),
                child: const Text('Delete'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  deleteTemplate(template.id); // Perform deletion
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _showDeleteAllConfirmationDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap button!
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Delete All Templates?'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Are you sure you want to delete all your saved workout templates?',
                  ),
                  Text('This action cannot be undone.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: HeronFitTheme.error,
                ),
                child: const Text('Delete All'),
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  try {
                    await storageService.deleteAllWorkouts();
                    ref.invalidate(savedWorkoutsProvider); // Refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All templates deleted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting all templates: $e'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Workout Templates',
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: HeronFitTheme.primary,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          templatesAsync.when(
            data:
                (templates) =>
                    templates.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            SolarIconsOutline.trashBinMinimalistic,
                            color: HeronFitTheme.error,
                          ),
                          tooltip: 'Delete All Templates',
                          onPressed:
                              () => _showDeleteAllConfirmationDialog(context),
                        )
                        : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: templatesAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error:
            (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading templates: $error',
                  style: TextStyle(color: HeronFitTheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      SolarIconsOutline.notebookBookmark,
                      size: 64,
                      color: HeronFitTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Templates Yet',
                      style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create personalized workouts that fit your goals and preferences. Tap the "+" button to start building.',
                      style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        color: HeronFitTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final formattedDate =
                  template.createdAt != null
                      ? DateFormat('MMM d, yyyy').format(template.createdAt!)
                      : 'Date unknown';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 1,
                shadowColor:
                    HeronFitTheme.cardShadow.isNotEmpty
                        ? HeronFitTheme.cardShadow[0].color.withOpacity(0.5)
                        : Colors.black.withAlpha(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: HeronFitTheme.bgSecondary.withAlpha(100),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  leading: const Icon(
                    SolarIconsOutline.notebookBookmark,
                    color: HeronFitTheme.primary,
                    size: 32,
                  ),
                  title: Text(
                    template.name,
                    style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HeronFitTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${template.exercises.length} exercises · Created $formattedDate',
                    style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                      color: HeronFitTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      SolarIconsOutline.trashBinTrash,
                      color: HeronFitTheme.error,
                    ),
                    tooltip: 'Delete Template',
                    onPressed:
                        () => _showDeleteConfirmationDialog(context, template),
                  ),
                  onTap: () {
                    context.push(
                      AppRoutes.workoutStartFromTemplate,
                      extra: template,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
