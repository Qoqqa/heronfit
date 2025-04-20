import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Hide UserGoal from controller import to resolve ambiguity
import 'package:heronfit/features/progress/controllers/progress_controller.dart'
    hide UserGoal;
import 'package:heronfit/features/progress/models/progress_record.dart';
// Corrected import path for LoadingIndicator
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
// Corrected import for fl_chart
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsyncValue = ref.watch(progressRecordsProvider);
    final goalsAsyncValue = ref.watch(userGoalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(progressRecordsProvider);
          ref.invalidate(userGoalsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGoalsSection(context, ref, goalsAsyncValue),
            const SizedBox(height: 24),
            _buildWeightChartSection(context, ref, progressAsyncValue),
            const SizedBox(height: 24),
            _buildWeightLogSection(context, ref, progressAsyncValue),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/progress/update-weight'),
        label: const Text('Log Weight'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserGoal?> goalsAsyncValue,
  ) {
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
                Text('Your Goals', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                  onPressed: () => context.push('/progress/edit-goals'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            goalsAsyncValue.when(
              data: (goal) {
                if (goal == null ||
                    goal.goalType == null ||
                    goal.goalType!.isEmpty) {
                  return const Text(
                    'No goals set yet. Tap the edit icon to add your goals!',
                  );
                }
                final goalType = goal.goalType ?? 'N/A';
                final targetWeight = goal.targetWeight?.toString() ?? 'N/A';
                final targetDate =
                    goal.targetDate != null
                        ? DateFormat('MMMM d, yyyy').format(goal.targetDate!)
                        : 'N/A';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalRow('Goal Type:', goalType),
                    _buildGoalRow('Target Weight:', '$targetWeight kg'),
                    _buildGoalRow('Target Date:', targetDate),
                  ],
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading goals: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildWeightChartSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ProgressRecord>> progressAsyncValue,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weight Progress', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            progressAsyncValue.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Text('Log your weight to see progress here.'),
                  );
                }
                final sortedRecords = List<ProgressRecord>.from(records)
                  ..sort((a, b) => a.date.compareTo(b.date));
                final spots =
                    sortedRecords.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList();

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index == 0 ||
                                  index == sortedRecords.length - 1 ||
                                  index == (sortedRecords.length / 2).floor()) {
                                if (index >= 0 &&
                                    index < sortedRecords.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      DateFormat(
                                        'MM/dd',
                                      ).format(sortedRecords[index].date),
                                      style: const TextStyle(fontSize: 10),
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
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withAlpha(50),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots
                                .map((LineBarSpot touchedSpot) {
                                  final index = touchedSpot.spotIndex;
                                  if (index >= 0 &&
                                      index < sortedRecords.length) {
                                    final record = sortedRecords[index];
                                    return LineTooltipItem(
                                      '${record.weight.toStringAsFixed(1)} kg\n',
                                      TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: DateFormat(
                                            'MMM d, yyyy',
                                          ).format(record.date),
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return null;
                                })
                                .whereType<LineTooltipItem>()
                                .toList();
                          },
                        ),
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

  Widget _buildWeightLogSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ProgressRecord>> progressAsyncValue,
  ) {
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
                  return const Center(child: Text('No weight entries yet.'));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary.withAlpha(
                          50,
                        ),
                        child: Icon(
                          Icons.monitor_weight_outlined,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text('${record.weight.toStringAsFixed(1)} kg'),
                      subtitle: Text(
                        DateFormat('MMMM d, yyyy').format(record.date),
                      ),
                      trailing:
                          record.photoUrl != null
                              ? Icon(Icons.image, color: theme.hintColor)
                              : null,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
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
