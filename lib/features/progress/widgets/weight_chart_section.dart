import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class WeightChartSection extends ConsumerWidget {
  final AsyncValue<List<ProgressRecord>> progressAsyncValue;

  const WeightChartSection({required this.progressAsyncValue, super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight Progress', style: theme.textTheme.titleLarge),
                    Text(
                      'Last 90 Days', // Or dynamically calculate range
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  // Use SolarIcons.addCircle
                  icon: Icon(
                    SolarIconsOutline.addCircle,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  tooltip: 'Log New Weight',
                  onPressed: () => context.push('/progress/update-weight'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            progressAsyncValue.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('Log your weight to see progress here.'),
                    ),
                  );
                }
                // Sort records by date ascending for the chart
                final sortedRecords = List<ProgressRecord>.from(records)
                  ..sort((a, b) => a.date.compareTo(b.date));

                // Limit to last 90 days if needed (or adjust based on data)
                // final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
                // final recentRecords = sortedRecords.where((r) => r.date.isAfter(ninetyDaysAgo)).toList();
                final recentRecords = sortedRecords; // Use all for now

                if (recentRecords.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('No weight logged in the last 90 days.'),
                    ),
                  );
                }

                final spots =
                    recentRecords.asMap().entries.map((entry) {
                      // Use timestamp for X axis for better date handling if needed
                      // return FlSpot(entry.value.date.millisecondsSinceEpoch.toDouble(), entry.value.weight);
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList();

                // Determine min/max for Y axis bounds
                double minY =
                    recentRecords
                        .map((r) => r.weight)
                        .reduce((a, b) => a < b ? a : b) -
                    5; // Add padding
                double maxY =
                    recentRecords
                        .map((r) => r.weight)
                        .reduce((a, b) => a > b ? a : b) +
                    5; // Add padding
                minY = minY < 0 ? 0 : minY; // Ensure minY is not negative

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval:
                            (maxY - minY) / 4, // Adjust interval
                        verticalInterval:
                            spots.length > 1
                                ? (spots.last.x - spots.first.x) / 4
                                : 1, // Adjust interval
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.dividerColor.withAlpha(
                              128,
                            ), // 0.5 opacity
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: theme.dividerColor.withAlpha(
                              128,
                            ), // 0.5 opacity
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (maxY - minY) / 4, // Match grid interval
                            getTitlesWidget: (value, meta) {
                              // Show labels at intervals
                              if (value == meta.min ||
                                  value == meta.max ||
                                  value ==
                                      meta.min + (meta.max - meta.min) / 2) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    value.toStringAsFixed(
                                      0,
                                    ), // Format as needed
                                    style: theme.textTheme.labelSmall,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval:
                                spots.length > 1
                                    ? (spots.last.x - spots.first.x) / 3
                                    : 1, // Show fewer labels
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              // Show labels at start, middle, end
                              if (index == 0 ||
                                  index == (recentRecords.length / 2).floor() ||
                                  index == recentRecords.length - 1) {
                                if (index >= 0 &&
                                    index < recentRecords.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8.0,
                                    child: Text(
                                      DateFormat(
                                        'MM/dd',
                                      ).format(recentRecords[index].date),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(fontSize: 10),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                          ), // Show dots on data points
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withAlpha(50),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => theme.colorScheme.primary,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots
                                .map((LineBarSpot touchedSpot) {
                                  final index = touchedSpot.spotIndex;
                                  if (index >= 0 &&
                                      index < recentRecords.length) {
                                    final record = recentRecords[index];
                                    return LineTooltipItem(
                                      '${record.weight.toStringAsFixed(1)} kg',
                                      TextStyle(
                                        color:
                                            theme
                                                .colorScheme
                                                .onPrimary, // Text color on primary background
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: DateFormat(
                                            'MMM d, yyyy',
                                          ).format(record.date),
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary
                                                .withAlpha(204), // 0.8 opacity
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return null;
                                })
                                .whereType<LineTooltipItem>()
                                .toList();
                          },
                        ),
                        handleBuiltInTouches:
                            true, // Enable default touch interactions
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading progress: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
