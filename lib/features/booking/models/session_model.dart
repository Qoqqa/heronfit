import 'package:flutter/material.dart';

class SessionTime {
  final TimeOfDay start;
  final TimeOfDay end;

  const SessionTime({required this.start, required this.end});

  String getDisplayTime(BuildContext context) {
    return '${start.format(context)} - ${end.format(context)}';
  }

  // For potential future use if direct string representation is needed without context
  @override
  String toString() {
    // Helper to format TimeOfDay to HH:MM AM/PM (e.g., 08:00 AM)
    String formatTimeOfDay(TimeOfDay tod) {
      final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final minute = tod.minute.toString().padLeft(2, '0');
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
    return '${formatTimeOfDay(start)} - ${formatTimeOfDay(end)}';
  }
}

class Session {
  final String id;
  final String name;
  final SessionTime time;
  final int totalSlots;
  int bookedSlots;
  final bool facultyOnly;
  List<String> waitlistUserIds; // List of user IDs on the waitlist

  Session({
    required this.id,
    required this.name,
    required this.time,
    required this.totalSlots,
    this.bookedSlots = 0,
    this.facultyOnly = false,
    List<String>? waitlistUserIds,
  }) : waitlistUserIds = waitlistUserIds ?? [];

  bool get isFull => bookedSlots >= totalSlots;
  int get availableSlots => totalSlots - bookedSlots;
}
