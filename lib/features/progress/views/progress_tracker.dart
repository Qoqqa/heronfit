import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/core/theme.dart'; // Import theme
import 'package:heronfit/features/progress/controllers/progress_controller.dart'; // Import controller
import 'package:heronfit/features/progress/models/progress_record.dart'; // Import model
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class ProgressTrackerWidget extends ConsumerWidget {
  const ProgressTrackerWidget({super.key});

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
            'Progress Tracker',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColor, // Use primary color
              fontWeight: FontWeight.bold, // Set font weight to bold
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16), // Consistent padding
            child: progressRecordsAsyncValue.when(
              data:
                  (records) => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Use min size
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align left
                      children: [
                        // Weight Chart Section (Simplified)
                        Text(
                          'Weight', // Section Title
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                HeronFitTheme.cardShadow, // Apply custom shadow
                          ),
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Last 90 Days', // Subtitle
                                        style: theme.textTheme.labelMedium,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          SolarIconsOutline
                                              .addCircle, // Use SolarIcons
                                          color: theme.primaryColor,
                                          size: 28,
                                        ),
                                        tooltip: 'Add Weight Entry',
                                        onPressed: () {
                                          context.push(
                                            AppRoutes.progressUpdateWeight,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildChart(
                                    context,
                                    records,
                                  ), // Extracted chart logic
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Progress Photos Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress Photos',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.push(AppRoutes.progressPhotoList);
                              },
                              child: Text(
                                'See All',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildPhotoList(
                          context,
                          records,
                        ), // Extracted photo list logic
                      ],
                    ),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading progress: $error')),
            ),
          ),
        ),
      ),
    );
  }

  // Extracted Chart Widget Builder
  Widget _buildChart(BuildContext context, List<ProgressRecord> records) {
    final theme = Theme.of(context);
    final spots = _createSpots(records);

    if (spots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Not enough data for chart. Tap + to add weight.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Determine min/max with padding, handle single point case
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
    if (spots.length == 1) {
      minY = spots.first.y - 10;
      maxY = spots.first.y + 10;
    }
    minY = minY < 0 ? 0 : minY; // Ensure minY is not negative

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false, // Only vertical lines
            verticalInterval:
                spots.length > 5 ? (spots.length / 5).ceilToDouble() : 1,
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withOpacity(0.5),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: false, // Keep titles hidden as per previous design
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted Photo List Widget Builder
  Widget _buildPhotoList(BuildContext context, List<ProgressRecord> records) {
    final theme = Theme.of(context);
    final photoRecords =
        records
            .where((r) => r.photoUrl != null && r.photoUrl!.isNotEmpty)
            .toList();

    if (photoRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        alignment: Alignment.center,
        child: Text('No photos added yet.', style: theme.textTheme.bodyMedium),
      );
    }

    // Display only the latest 3 photos with URLs
    final latestPhotos = photoRecords.reversed.take(3).toList();

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8.0), // Add padding above list
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: latestPhotos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = latestPhotos[index];
        return InkWell(
          onTap: () {
            // Navigate to the specific photo view, passing the record ID or index
            // Example: context.push('${AppRoutes.viewProgressPhoto}/${record.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to View Photo (TODO)')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: HeronFitTheme.cardShadow, // Apply custom shadow
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Adjust padding
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        record.photoUrl!,
                        width: 60, // Slightly smaller image
                        height: 60,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${record.date.toLocal().toString().split(' ')[0]}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
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
                      SolarIconsOutline.altArrowRight, // Use SolarIcons
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
  }

  // Keep _createSpots method as is, but ensure it handles < 2 records gracefully
  List<FlSpot> _createSpots(List<ProgressRecord> records) {
    if (records.length < 2) {
      // Return empty list or handle as needed if less than 2 points
      return [];
    }
    final sortedRecords = List<ProgressRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedRecords.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }
}
