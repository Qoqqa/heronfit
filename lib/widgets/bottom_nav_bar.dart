import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart'; // Ensure SolarIcons is imported
import 'package:heronfit/core/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0 ? SolarIconsBold.home : SolarIconsOutline.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1 ? SolarIconsBold.calendar : SolarIconsOutline.calendar,
          ),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? SolarIconsBold.dumbbellLarge : SolarIconsOutline.dumbbellLarge,
          ),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 3 ? SolarIconsBold.chartSquare : SolarIconsOutline.chartSquare,
          ),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 4 ? SolarIconsBold.user : SolarIconsOutline.user,
          ),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: HeronFitTheme.primary,
      unselectedItemColor: HeronFitTheme.textMuted,
      onTap: onTap,
    );
  }
}
