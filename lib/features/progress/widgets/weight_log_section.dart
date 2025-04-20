import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

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
            Text('Weight Log', style: theme.textTheme.titleLarge),
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
                // Records are already sorted descending by date from the provider
                return ListView.separated(
                  shrinkWrap: true, // Important in a Column/ListView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling within the list itself
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary.withAlpha(
                          50,
                        ),
                        // Use SolarIconsOutline.scale instead of .weight
                        child: Icon(
                          SolarIconsOutline.scale,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text('${record.weight.toStringAsFixed(1)} kg'),
                      subtitle: Text(
                        // Correct DateFormat string by escaping 'at'
                        DateFormat(
                          'MMMM d, yyyy \'at\' hh:mm a',
                        ).format(record.date.toLocal()), // Show time as well
                      ),
                      trailing:
                          record.photoUrl != null
                              // Use SolarIcons.gallery
                              ? Icon(
                                SolarIconsOutline.gallery,
                                color: theme.hintColor,
                              )
                              : null,
                      // Add onTap to view details or photo if needed
                      // onTap: () {
                      //   // Handle tap, e.g., show photo
                      // },
                    );
                  },
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
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
