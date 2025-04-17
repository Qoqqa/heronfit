import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';

class MainScreenWrapper extends StatelessWidget {
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

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.booking);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
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
