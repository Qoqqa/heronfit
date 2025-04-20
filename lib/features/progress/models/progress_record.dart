import 'package:flutter/foundation.dart';

@immutable
class ProgressRecord {
  final String id;
  final DateTime date;
  final double weight;
  final String? photoUrl; // Optional photo associated with the record
  final String? photoPath; // Optional storage path

  const ProgressRecord({
    required this.id,
    required this.date,
    required this.weight,
    this.photoUrl,
    this.photoPath, // Add photoPath to constructor
  });

  // Updated fromJson factory
  factory ProgressRecord.fromJson(Map<String, dynamic> json) {
    // Add basic error handling for parsing
    try {
      return ProgressRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight_kg'] as num).toDouble(), // Use weight_kg
        photoUrl: json['photo_url'] as String?,
        photoPath: json['photo_path'] as String?,
      );
    } catch (e) {
      // Log error or rethrow with more context if needed in production
      print('Error parsing ProgressRecord from JSON: $e, JSON: $json');
      // Depending on requirements, you might return a default/error state
      // or rethrow the exception.
      // For now, rethrowing to make the error visible during development.
      rethrow;
    }
  }

  // Add toJson method if needed for updates (though controller handles inserts)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Usually not needed for inserts if DB generates it
      'date': date.toIso8601String(),
      'weight_kg': weight, // Use weight_kg
      'photo_url': photoUrl,
      'photo_path': photoPath,
      // 'user_id' will be added by the controller/service layer
    };
  }

  // Add copyWith if needed for state management updates
  ProgressRecord copyWith({
    String? id,
    DateTime? date,
    double? weight,
    String? photoUrl,
    String? photoPath,
  }) {
    return ProgressRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

@immutable
class UserGoal {
  final String id;
  final String userId;
  final String? goalType; // Keep only goalType

  const UserGoal({
    required this.id,
    required this.userId,
    this.goalType, // Keep only goalType
  });

  // Add fromJson factory based on controller's usage and potential DB structure
  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'] as String, // Assuming 'id' is the primary key
      userId: json['user_id'] as String,
      goalType: json['goal_type'] as String?, // Keep only goalType
    );
  }

  // Add toJson method based on controller's usage and potential DB structure
  // Note: 'id' might not be needed for inserts/upserts if auto-generated or based on conflict
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType, // Keep only goalType
    };
  }

  // Add copyWith if needed
}
