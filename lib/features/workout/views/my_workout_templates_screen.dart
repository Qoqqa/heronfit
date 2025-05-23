import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import 'package:heronfit/core/services/workout_supabase_service.dart';

class MyWorkoutTemplatesScreen extends ConsumerWidget {
  const MyWorkoutTemplatesScreen({super.key});

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) async {
    final workoutService = ref.read(workoutServiceProvider);

    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Template?'),
          content: const Text(
            'Are you sure you want to delete this workout template?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: HeronFitTheme.error),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await workoutService.deleteWorkoutTemplate(templateId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Template deleted successfully!'),
                    ),
                  );
                  ref.invalidate(savedWorkoutsProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting template: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteAllConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final workoutService = ref.read(workoutServiceProvider);

    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
              style: TextButton.styleFrom(foregroundColor: HeronFitTheme.error),
              child: const Text('Delete All'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delete All functionality not yet implemented remotely.',
                      ),
                    ),
                  );

                  ref.invalidate(savedWorkoutsProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting all templates: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(savedWorkoutsProvider);

    final deleteConfirmationDialog =
        (String templateId) =>
            showDeleteConfirmationDialog(context, ref, templateId);
    final deleteAllConfirmationDialog =
        () => showDeleteAllConfirmationDialog(context, ref);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: Text(
            'My Workout Templates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            templatesAsync.maybeWhen(
              data:
                  (templates) =>
                      templates.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              SolarIconsOutline.trashBinMinimalistic,
                            ),
                            color: HeronFitTheme.error,
                            tooltip: 'Delete All Templates',
                            onPressed: deleteAllConfirmationDialog,
                          )
                          : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: HeronFitTheme.bgLight,
        body: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, st) => Center(child: Text('Error loading templates: $err')),
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Text('No workout templates saved yet.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  template.name,
                                  style: HeronFitTheme.textTheme.titleMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  SolarIconsOutline.trashBinMinimalistic,
                                ),
                                color: HeronFitTheme.error,
                                tooltip: 'Delete Template',
                                onPressed:
                                    () => deleteConfirmationDialog(template.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${template.exercises.length} exercises',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
