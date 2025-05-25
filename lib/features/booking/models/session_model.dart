import 'package:flutter/material.dart';

enum SessionStatus {
  available,
  full,
}

class Session {
  final String id;
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  final TimeOfDay startTime; // Parsed from "HH:mm:ss"
  final TimeOfDay endTime;   // Parsed from "HH:mm:ss"
  final String category;    // e.g., "Student", "Faculty/Employee"
  final int capacity;
  final int bookedSlots;
  final bool isActive;
  final DateTime? overrideDate; // Nullable
  final String? notes;          // Nullable

  Session({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.capacity,
    required this.bookedSlots,
    required this.isActive,
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
      overrideDate: json['override_date'] == null
          ? null
          : DateTime.parse(json['override_date'] as String),
      notes: json['notes'] as String?,
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
      'override_date': overrideDate?.toIso8601String().substring(0, 10), // Format as YYYY-MM-DD
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
    DateTime? overrideDate,
    String? notes,
    bool setOverrideDateToNull = false, // To explicitly set overrideDate to null
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
      overrideDate: setOverrideDateToNull ? null : overrideDate ?? this.overrideDate,
      notes: setNotesToNull ? null : notes ?? this.notes,
    );
  }

  // Helper for display
  String get timeRangeShort {
    // Format TimeOfDay to HH:mm string
    String _formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
      overrideDate.hashCode ^
      notes.hashCode;
  }

  @override
  String toString() {
    return 'Session(id: $id, dayOfWeek: $dayOfWeek, startTime: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}, endTime: ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}, category: $category, capacity: $capacity, bookedSlots: $bookedSlots, isActive: $isActive, overrideDate: $overrideDate, notes: $notes)';
  }
}
