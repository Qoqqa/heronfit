import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/features/progress/controllers/progress_controller.dart'; // Import controller
import 'package:heronfit/features/progress/models/progress_record.dart'; // Import model
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class ProgressPhotosListWidget extends ConsumerWidget {
  const ProgressPhotosListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);
    final theme = Theme.of(context); // Get theme

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Set background to transparent
          elevation: 0, // Remove elevation
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              SolarIconsOutline.altArrowLeft, // Use SolarIcons
              color: theme.primaryColor, // Use primary color
              size: 28, // Adjust size as needed
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
          title: Text(
            'Progress Photos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColor, // Use primary color
              fontWeight: FontWeight.bold, // Set font weight to bold
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                SolarIconsOutline.squareTransferHorizontal, // Use SolarIcons
                color: theme.primaryColor, // Use primary color
              ),
              tooltip: 'Compare Photos',
              onPressed: () {
                // Navigate to compare photos screen
                // context.push(AppRoutes.compareProgressPhotos);
              },
            ),
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16), // Consistent padding
            child: progressRecordsAsyncValue.when(
              data: (records) {
                final photoRecords =
                    records
                        .where(
                          (r) => r.photoUrl != null && r.photoUrl!.isNotEmpty,
                        )
                        .toList();

                if (photoRecords.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No progress photos found. Add some via Update Weight screen.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemCount: photoRecords.length,
                  itemBuilder: (context, index) {
                    final record = photoRecords[index];
                    return Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        // Wrap with InkWell for tap effect
                        onTap: () {
                          // Navigate to view single photo (if needed)
                          // context.push('${AppRoutes.viewProgressPhoto}/${record.id}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigate to View Photo (TODO)'),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: theme.shadowColor.withOpacity(0.1),
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12), // Adjust padding
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    record.photoUrl!,
                                    width: 80, // Adjust size
                                    height: 80,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date: ${record.date.toLocal().toString().split(' ')[0]}',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              fontWeight:
                                                  FontWeight
                                                      .w600, // Make date bold
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Weight: ${record.weight} kg',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  SolarIconsOutline
                                      .altArrowRight, // Use SolarIcons
                                  color: theme.hintColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading photos: $error')),
            ),
          ),
        ),
      ),
    );
  }
}
