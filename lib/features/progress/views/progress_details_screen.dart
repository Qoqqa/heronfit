import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/features/progress/widgets/weight_chart_section.dart'; // Reuse existing chart section
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For min

// State provider for the selected time filter
enum TimeFilter { week, month, allTime }

final timeFilterProvider = StateProvider<TimeFilter>(
  (ref) => TimeFilter.allTime,
);

class ProgressDetailsScreen extends ConsumerWidget {
  const ProgressDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(timeFilterProvider);
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);

    // Filter records based on the selected time filter
    final filteredProgressAsyncValue = progressRecordsAsyncValue.whenData((
      records,
    ) {
      DateTime now = DateTime.now();
      DateTime startDate;
      switch (selectedFilter) {
        case TimeFilter.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case TimeFilter.month:
          startDate = DateTime(
            now.year,
            now.month - 1,
            now.day,
          ); // Approx last 30 days
          break;
        case TimeFilter.allTime:
        default:
          // No filtering needed for all time
          return records;
      }
      return records.where((record) => record.date.isAfter(startDate)).toList();
    });

    final photoRecords =
        progressRecordsAsyncValue
            .whenData(
              (records) =>
                  records
                      .where(
                        (r) => r.photoUrl != null && r.photoUrl!.isNotEmpty,
                      )
                      .toList(),
            )
            .value ??
        []; // Get photo records, default to empty list

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Details'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Weight Chart Section with Filtering ---
            Text('Weight Trend', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            SegmentedButton<TimeFilter>(
              segments: const [
                ButtonSegment(value: TimeFilter.week, label: Text('Week')),
                ButtonSegment(value: TimeFilter.month, label: Text('Month')),
                ButtonSegment(value: TimeFilter.allTime, label: Text('All')),
              ],
              selected: {selectedFilter},
              onSelectionChanged: (newSelection) {
                ref.read(timeFilterProvider.notifier).state =
                    newSelection.first;
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.colorScheme.primary.withOpacity(
                  0.2,
                ),
                selectedForegroundColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Pass the *filtered* data to the chart section
            WeightChartSection(progressAsyncValue: filteredProgressAsyncValue),
            const SizedBox(height: 24),

            // --- Progress Photos Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress Photos', style: theme.textTheme.headlineSmall),
                if (photoRecords
                    .isNotEmpty) // Show "See All" only if photos exist
                  TextButton(
                    onPressed: () => context.push(AppRoutes.progressPhotoList),
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            progressRecordsAsyncValue.when(
              data: (allRecords) {
                // Use the pre-filtered photoRecords list
                if (photoRecords.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No progress photos added yet.'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: photoRecords.length,
                  itemBuilder: (context, index) {
                    final record = photoRecords[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                record.photoUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, progress) =>
                                        progress == null
                                            ? child
                                            : const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                errorBuilder:
                                    (context, error, stack) =>
                                        const Icon(Icons.error, size: 40),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMMM d, yyyy',
                                    ).format(record.date.toLocal()),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${record.weight.toStringAsFixed(1)} kg',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                // Navigate to single photo view, passing index or ID
                                // Example: context.push('${AppRoutes.progressPhotoView}?index=$index');
                                // Need to implement the single photo view route and logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Navigate to single photo view (TODO)',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading photos: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
