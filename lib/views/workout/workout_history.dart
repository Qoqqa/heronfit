import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class WorkoutHistoryWidget extends StatefulWidget {
  const WorkoutHistoryWidget({super.key});

  static String routeName = 'WorkoutHistory';
  static String routePath = '/workoutHistory';

  @override
  State<WorkoutHistoryWidget> createState() => _WorkoutHistoryWidgetState();
}

class _WorkoutHistoryWidgetState extends State<WorkoutHistoryWidget> {
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
        backgroundColor: HeronFitTheme.bgLight,
        appBar: AppBar(
          backgroundColor: HeronFitTheme.bgLight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Workout History',
            style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
              color: HeronFitTheme.primary,
              fontSize: 20,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            // Handle workout tap
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: HeronFitTheme.bgSecondary,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 40,
                                  color: HeronFitTheme.textMuted.withOpacity(0.1),
                                  offset: Offset(0, 10),
                                )
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Workout Name',
                                            style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                              color: HeronFitTheme.primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            '3 days ago',
                                            style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                                              color: HeronFitTheme.textPrimary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: HeronFitTheme.textPrimary,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '1 hour 30 minutes',
                                            style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}