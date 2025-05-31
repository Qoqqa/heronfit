import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

enum SessionStatus { available, full }

class Session {
  final String id;
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  final TimeOfDay startTime; // Parsed from "HH:mm:ss"
  final TimeOfDay endTime; // Parsed from "HH:mm:ss"
  final String category; // e.g., "Student", "Faculty/Employee"
  final int capacity;
  final int bookedSlots;
  final bool isActive;
  final DateTime date; // Added session date
  final DateTime? overrideDate; // Nullable
  final String? notes; // Nullable

  Session({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.capacity,
    required this.bookedSlots,
    required this.isActive,
    required this.date, // Added session date to constructor
    this.overrideDate,
    this.notes,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    // Helper to parse time string "HH:mm:ss" to TimeOfDay
    TimeOfDay _parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      // Seconds are available in parts[2] if needed
    }

    return Session(
      id: json['id'] as String,
      dayOfWeek: json['day_of_week'] as String,
      startTime: _parseTime(json['start_time_of_day'] as String),
      endTime: _parseTime(json['end_time_of_day'] as String),
      category: json['category'] as String,
      capacity: json['capacity'] as int,
      bookedSlots: json['booked_slots'] as int,
      isActive: json['is_active'] as bool,
      date: DateTime.parse(json['date'] as String), // Parse session date
      overrideDate:
          json['override_date'] == null
              ? null
              : DateTime.parse(json['override_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    // Helper to parse time strings like "10:00:00" into TimeOfDay
    TimeOfDay _parseTimeOfDay(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    // Provide default values for potentially missing string fields from RPC response
    final String id =
        map['id'] as String? ??
        'unknown_id'; // Should always be present from RPC
    final String dayOfWeek = map['day_of_week'] as String? ?? 'N/A';
    final String startTimeStr =
        map['start_time_of_day'] as String? ?? '00:00:00';
    final String endTimeStr = map['end_time_of_day'] as String? ?? '00:00:00';
    final String category = map['category'] as String? ?? 'General';
    final bool isActive = map['is_active'] as bool? ?? false;

    return Session(
      id: id,
      dayOfWeek: dayOfWeek,
      startTime: _parseTimeOfDay(startTimeStr),
      endTime: _parseTimeOfDay(endTimeStr),
      capacity: map['capacity'] as int? ?? 0, // Default to 0 if null
      bookedSlots: map['booked_slots'] as int? ?? 0, // Default to 0 if null
      category: category,
      isActive: isActive,
      date: DateTime.parse(
        map['date'] as String? ?? DateTime.now().toIso8601String(),
      ), // Parse session date with fallback
      overrideDate:
          map['override_date'] == null
              ? null
              : DateTime.parse(map['override_date'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to format TimeOfDay to "HH:mm:ss" string
    String _formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }

    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time_of_day': _formatTime(startTime),
      'end_time_of_day': _formatTime(endTime),
      'category': category,
      'capacity': capacity,
      'booked_slots': bookedSlots,
      'is_active': isActive,
      'date': date.toIso8601String().substring(0, 10), // Format as YYYY-MM-DD
      'override_date': overrideDate?.toIso8601String().substring(
        0,
        10,
      ), // Format as YYYY-MM-DD
      'notes': notes,
    };
  }

  Session copyWith({
    String? id,
    String? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? category,
    int? capacity,
    int? bookedSlots,
    bool? isActive,
    DateTime? date, // Added date to copyWith
    DateTime? overrideDate,
    String? notes,
    bool setOverrideDateToNull =
        false, // To explicitly set overrideDate to null
    bool setNotesToNull = false, // To explicitly set notes to null
  }) {
    return Session(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      capacity: capacity ?? this.capacity,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      isActive: isActive ?? this.isActive,
      date: date ?? this.date, // Updated copyWith
      overrideDate:
          setOverrideDateToNull ? null : overrideDate ?? this.overrideDate,
      notes: setNotesToNull ? null : notes ?? this.notes,
    );
  }

  // Helper for display
  String get timeRangeShort {
    // Format TimeOfDay to h:mm AM/PM string
    String _formatTime(TimeOfDay time) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt); // e.g., 8:00 AM
    }

    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String get availability {
    final available = capacity - bookedSlots;
    return '$available/$capacity slots';
  }

  SessionStatus get status {
    if (bookedSlots >= capacity) return SessionStatus.full;
    // Add logic for 'facultyOnly' if that concept is reintroduced via 'category' or another field
    return SessionStatus.available;
  }

  // Add a getter to check if the session is in the past
  bool get isPast {
    final now = DateTime.now();
    final sessionEndDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
    return sessionEndDateTime.isBefore(now);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.id == id &&
        other.dayOfWeek == dayOfWeek &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.category == category &&
        other.capacity == capacity &&
        other.bookedSlots == bookedSlots &&
        other.isActive == isActive &&
        other.date == date &&
        other.overrideDate == overrideDate &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dayOfWeek.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        category.hashCode ^
        capacity.hashCode ^
        bookedSlots.hashCode ^
        isActive.hashCode ^
        date.hashCode ^
        overrideDate.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'Session(id: $id, dayOfWeek: $dayOfWeek, startTime: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}, endTime: ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}, category: $category, capacity: $capacity, bookedSlots: $bookedSlots, isActive: $isActive, date: $date, overrideDate: $overrideDate, notes: $notes)';
  }
}
