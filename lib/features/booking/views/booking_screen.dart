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
    // Redirect to the new booking flow when this screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(AppRoutes.activateGymPass);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is a temporary screen that will be replaced by the new flow
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
