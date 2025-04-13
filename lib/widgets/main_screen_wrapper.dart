import 'package:flutter/material.dart';
import 'package:heronfit/features/home/views/home_screen.dart';
import 'package:heronfit/features/profile/views/profile_screen.dart';
import 'package:heronfit/features/workout/views/workout_widget.dart';
import 'package:heronfit/features/booking/views/booking_screen.dart';
import 'package:heronfit/features/progress/views/progress_screen.dart';
import 'package:heronfit/widgets/bottom_nav_bar.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeWidget(),
    const BookingScreen(),
    const WorkoutWidget(),
    const ProgressDashboardWidget(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
