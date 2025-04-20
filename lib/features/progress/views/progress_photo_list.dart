import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/features/progress/controllers/progress_controller.dart'; // Import controller
import 'package:heronfit/features/progress/models/progress_record.dart'; // Import model
import 'package:heronfit/features/progress/widgets/progress_photo_list_item.dart'; // Import the reusable item widget
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
                    // Use the reusable ProgressPhotoListItem widget
                    return ProgressPhotoListItem(
                      record: record,
                      index:
                          index, // Pass the index directly as this list is not filtered
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
