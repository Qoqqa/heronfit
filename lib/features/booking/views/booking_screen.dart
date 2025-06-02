import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  static String routeName = 'BookingScreen';
  static String routePath = '/bookingScreen';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to the select session screen when this screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(AppRoutes.selectSession);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current day is a weekend
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    // This is a temporary screen that will be replaced by the new flow
    return Scaffold(
      body: Center(
        child: isWeekend
            ? const Text('Gym is closed on weekends!')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
