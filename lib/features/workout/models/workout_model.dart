import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Workout {
  final String id;
  final String name;
  final String? notes; // Add notes field
  final List<String> exercises;
  final Duration duration;
  final DateTime
  timestamp; // Renamed from createdAt for consistency? Keep as timestamp.
  final DateTime? createdAt; // Add createdAt field

  Workout({
    required this.id,
    required this.name,
    this.notes, // Add to constructor
    required this.exercises,
    required this.duration,
    DateTime? timestamp,
    this.createdAt, // Add to constructor
  }) : timestamp = timestamp ?? DateTime.now();

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      notes: json['notes'], // Add notes
      exercises: List<String>.from(json['exercises']),
      duration: Duration(seconds: json['duration']),
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null, // Add createdAt
    );
  }

  factory Workout.fromSupabase(Map<String, dynamic> json) {
    return Workout(
      id: json['id'].toString(),
      name: json['name'],
      notes: json['notes'], // Add notes
      exercises: List<String>.from(json['exercises']),
      duration: Duration(seconds: json['duration']),
      timestamp: DateTime.parse(
        json['timestamp'],
      ), // Assuming 'timestamp' exists from Supabase
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null, // Add createdAt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes, // Add notes
      'exercises': exercises,
      'duration': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt?.toIso8601String(), // Add createdAt
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    String? notes,
    List<String>? exercises,
    Duration? duration,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

void testWorkoutSerialization() {}
