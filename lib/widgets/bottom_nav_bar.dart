import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
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
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(IconlyBold.calendar), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(IconlyBold.work), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(IconlyBold.chart), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(IconlyBold.profile), label: 'Profile'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: HeronFitTheme.primary,
      unselectedItemColor: HeronFitTheme.textMuted,
      onTap: onTap,
    );
  }
}
