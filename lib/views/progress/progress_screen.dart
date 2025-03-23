import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_goals.dart'; // Import the EditGoalsWidget
import 'update_weight.dart'; // Import the UpdateWeightWidget
import 'progress_tracker.dart';

class ProgressDashboardWidget extends StatefulWidget {
  const ProgressDashboardWidget({super.key});

  static String routeName = 'ProgressDashboard';
  static String routePath = '/progressDashboard';

  @override
  State<ProgressDashboardWidget> createState() =>
      _ProgressDashboardWidgetState();
}

class _ProgressDashboardWidgetState extends State<ProgressDashboardWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Progress',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Current Goal: Gain Muscle And Get Stronger',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Build a toned physique and improve your athletic performance.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                color: Colors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Recommended 3-5 workouts per week',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditGoalsWidget(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Edit Goals',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weight',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last 90 Days',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UpdateWeightWidget(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProgressTrackerWidget(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  'Graph Placeholder',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Text(
                          'This Month',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 40,
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 10),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Workouts Completed',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '15',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Workout Time',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '2h 30m',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Average Workout Duration',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '50 min',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Text(
                          'Personal Bests',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 40,
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 10),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Longest Workout Time',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.clock,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '1h 30min',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Most Workout in a Week',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '5',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Longest Workout Time',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Icon(
                                        Icons.arrow_upward,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '15',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}