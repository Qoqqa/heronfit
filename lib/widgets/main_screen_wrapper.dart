import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/home/home_providers.dart';

class MainScreenWrapper extends ConsumerWidget {
  final Widget child;

  const MainScreenWrapper({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) {
      return 0;
    }
    if (location.startsWith(AppRoutes.booking)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.workout)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.progress)) {
      return 3;
    }
    if (location.startsWith(AppRoutes.profile)) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) async {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        final upcomingSessionData =
            await ref.read(upcomingSessionProvider.future);
        bool hasActiveBooking = false;

        if (upcomingSessionData != null) {
          final dynamic sessionDateActualDynamic = upcomingSessionData['session_date_actual'];
          final dynamic endTimeStrDynamic = upcomingSessionData['session_end_time'];

          if (sessionDateActualDynamic is DateTime && endTimeStrDynamic is String) {
            final DateTime sessionDate = sessionDateActualDynamic;
            final String endTimeStr = endTimeStrDynamic;
            final now = DateTime.now();

            try {
              final endTimeParts = endTimeStr.split(':');
              final DateTime sessionEndDateTime = DateTime(
                sessionDate.year,
                sessionDate.month,
                sessionDate.day,
                int.parse(endTimeParts[0]),
                int.parse(endTimeParts[1]),
                endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
              );
              if (sessionEndDateTime.isAfter(now)) {
                hasActiveBooking = true;
              }
            } catch (e) {
              print('[MainScreenWrapper] Error parsing session end time for active booking check: $e');
            }
          } else {
            print('[MainScreenWrapper] Debug: session_date_actual is not DateTime or session_end_time is not String.');
            print('[MainScreenWrapper] Debug: session_date_actual type: ${sessionDateActualDynamic?.runtimeType}, value: $sessionDateActualDynamic');
            print('[MainScreenWrapper] Debug: session_end_time type: ${endTimeStrDynamic?.runtimeType}, value: $endTimeStrDynamic');
          }
        }

        if (hasActiveBooking) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Active Booking Found'),
                  content: const Text(
                    'You already have an upcoming session. Please cancel it or wait for it to complete before booking a new one.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('View My Bookings'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go(AppRoutes.bookings);
                      },
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // Optionally, navigate to home or do nothing
                        // context.go(AppRoutes.home);
                      },
                    ),
                  ],
                );
              },
            );
          }
        } else {
          context.go(AppRoutes.booking);
        }
        break;
      case 2:
        context.go(AppRoutes.workout);
        break;
      case 3:
        context.go(AppRoutes.progress);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context, ref),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 0 ? SolarIconsBold.home : SolarIconsOutline.home,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 1
              ? SolarIconsBold.calendar
              : SolarIconsOutline.calendar,
        ),
        label: 'Bookings',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 2
              ? SolarIconsBold.dumbbellLarge
              : SolarIconsOutline.dumbbellLarge,
        ),
        label: 'Workout',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 3 ? SolarIconsBold.graph : SolarIconsOutline.graph,
        ),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 4 ? SolarIconsBold.user : SolarIconsOutline.user,
        ),
        label: 'Profile',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: HeronFitTheme.bgLight,
      selectedItemColor: HeronFitTheme.primary,
      unselectedItemColor: HeronFitTheme.textMuted,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 4.0,
      items: navItems,
    );
  }
}
