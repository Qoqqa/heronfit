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
  final List<String> exercises;
  final Duration duration;
  final DateTime timestamp;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.duration,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      exercises: List<String>.from(json['exercises']),
      duration: Duration(seconds: json['duration']),
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  factory Workout.fromSupabase(Map<String, dynamic> json) {
    return Workout(
      id: json['id'].toString(),
      name: json['name'],
      exercises: List<String>.from(json['exercises']),
      duration: Duration(seconds: json['duration']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises,
      'duration': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
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
