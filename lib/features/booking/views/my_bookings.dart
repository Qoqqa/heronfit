import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import routes
import '../../../core/theme.dart';

class MyBookingsWidget extends StatefulWidget {
  const MyBookingsWidget({super.key});

  static String routePath = '/myBookings';

  @override
  State<MyBookingsWidget> createState() => _MyBookingsWidgetState();
}

class _MyBookingsWidgetState extends State<MyBookingsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'My Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Handle booking tap
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
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: HeronFitTheme.primary,
                                        size: 32,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Gym Session',
                                            style: HeronFitTheme
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Ticket ID: 12345',
                                            style: HeronFitTheme
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(letterSpacing: 0.0),
                                          ),
                                          Text(
                                            'Date: Mar 24, 2025',
                                            style: HeronFitTheme
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            'Time: 10:00 AM',
                                            style: HeronFitTheme
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
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
              ElevatedButton.icon(
                onPressed: () {
                  context.go(AppRoutes.home); // Navigate back to home
                },
                icon: Icon(Icons.home, size: 15),
                label: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primaryDark,
                  foregroundColor: HeronFitTheme.bgLight,
                  minimumSize: Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                    color: HeronFitTheme.bgLight,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
