import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:intl/intl.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

class ReviewBookingScreen extends StatelessWidget {
  final Session session;
  final DateTime selectedDay;

  const ReviewBookingScreen({
    super.key,
    required this.session,
    required this.selectedDay,
  });

  Widget _buildSummaryRow(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: HeronFitTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: HeronFitTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE - MMMM d, yyyy');
    final String formattedDate = dateFormat.format(selectedDay);
    final String sessionTime = session.time.getDisplayTime(context);
    final int availableSlots = session.totalSlots - session.bookedSlots;

    const String mockTicketId = "AR20241008";

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review Booking Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review your booking details below before confirming. Make sure all the information is correct.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HeronFitTheme.textSecondary,
                    fontFamily: 'Poppins',
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: HeronFitTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: HeronFitTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow(context, icon: SolarIconsOutline.ticket, text: 'Ticket ID: $mockTicketId'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.calendar, text: 'Date: $formattedDate'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.clockCircle, text: 'Time: $sessionTime'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.usersGroupRounded, text: 'Capacity: $availableSlots/${session.totalSlots} spots left'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  _showSessionConfirmedModal(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                ),
                child: const Text('Confirm Booking'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: HeronFitTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: HeronFitTheme.primary,
                      ),
                ),
                child: const Text('Change Session'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSessionConfirmedModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Session Confirmed!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', color: HeronFitTheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Your gym session is booked for ${DateFormat('MMMM d, yyyy').format(selectedDay)} at ${session.time.getDisplayTime(dialogContext)}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  'View Booking Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pushNamed(
                    AppRoutes.bookingDetails,
                    extra: {'session': session, 'selectedDay': selectedDay},
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
