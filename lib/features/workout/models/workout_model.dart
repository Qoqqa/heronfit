import '../../../../core/utils/model_utils.dart';
import 'dart:ui';
import '../views/workout_widget.dart' show WorkoutWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class WorkoutModel {
  final WorkoutWidget widget;

  WorkoutModel(this.widget);

  void initState(BuildContext context) {}

  void dispose() {}
}

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
  }) : this.timestamp = timestamp ?? DateTime.now();

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
}

void testWorkoutSerialization() {
  final workout = Workout(
    id: '1',
    name: 'Test Workout',
    exercises: ['Push-ups', 'Squats'],
    duration: Duration(minutes: 30),
  );

  final json = workout.toJson();
  print('Serialized workout: $json'); // Debug log

  final deserializedWorkout = Workout.fromJson(json);
  print('Deserialized workout: $deserializedWorkout'); // Debug log
}
