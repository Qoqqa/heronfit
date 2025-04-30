import 'package:flutter/material.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/booking/views/booking_screen.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme

class UpcomingSessionCard extends StatelessWidget {
  const UpcomingSessionCard({super.key});

  Future<Map<String, dynamic>?> fetchUpcomingSession() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await Supabase.instance.client
        .from('sessions')
        .select()
        .eq('email', user.email!)
        .gte('date', DateTime.now().toIso8601String())
        .order('date', ascending: true)
        .order('time', ascending: true)
        .limit(1)
        .single();

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUpcomingSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching upcoming session'));
        }

        final session = snapshot.data;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: HeronFitTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    context.go(AppRoutes.booking); // Navigate to the BookingScreen using GoRouter
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Session',
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        SolarIconsOutline.clipboardList,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (session != null) ...[
                  HomeInfoRow(
                    icon: SolarIconsOutline.calendar,
                    text: DateFormat('EEEE, MMMM d').format(
                      DateTime.parse(session['date']),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  HomeInfoRow(
                    icon: SolarIconsOutline.clockCircle,
                    text: session['time'],
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ] else ...[
                  const HomeInfoRow(
                    icon: SolarIconsOutline.calendar,
                    text: 'No Booked Sessions!',
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
