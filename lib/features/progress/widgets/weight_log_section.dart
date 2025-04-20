import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import 'dart:math'; // Import math for min function

class WeightLogSection extends ConsumerWidget {
  final AsyncValue<List<ProgressRecord>> progressAsyncValue;

  const WeightLogSection({required this.progressAsyncValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Weight Log',
              style: theme.textTheme.titleLarge,
            ), // Updated title
            const SizedBox(height: 16),
            progressAsyncValue.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No weight entries yet.'),
                    ),
                  );
                }
                // Limit to max 3 records
                final limitedRecords = records.sublist(
                  0,
                  min(records.length, 3),
                );

                return Column(
                  // Wrap ListView and Button in Column
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: limitedRecords.length, // Use limited count
                      itemBuilder: (context, index) {
                        final record = limitedRecords[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary
                                .withAlpha(50),
                            child: Icon(
                              SolarIconsOutline.scale,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          title: Text('${record.weight.toStringAsFixed(1)} kg'),
                          subtitle: Text(
                            DateFormat(
                              'MMMM d, yyyy \'at\' hh:mm a',
                            ).format(record.date.toLocal()),
                          ),
                          trailing:
                              record.photoUrl != null
                                  ? Icon(
                                    SolarIconsOutline.gallery,
                                    color: theme.hintColor,
                                  )
                                  : null,
                        );
                      },
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                    ),
                    // Add "View More" button if there are more than 3 records
                    if (records.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the new details screen
                              context.push(AppRoutes.progressDetails);
                            },
                            child: Text(
                              'View More',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading log: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
