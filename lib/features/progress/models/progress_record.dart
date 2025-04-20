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
    return ProgressRecord(
      id: json['id'] as String,
      date: DateTime.parse(
        json['date'] as String,
      ), // Use parse, handle errors upstream if needed
      weight:
          (json['weight'] as num)
              .toDouble(), // Assume weight is always present and numeric
      photoUrl: json['photo_url'] as String?, // Match DB column name
      photoPath: json['photo_path'] as String?, // Match DB column name
    );
  }

  // Add toJson method if needed for updates (though controller handles inserts)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'photo_url': photoUrl,
      'photo_path': photoPath,
    };
  }

  // Add copyWith if needed
}

@immutable
class UserGoal {
  final String id;
  final String userId;
  final String? goalType; // Made nullable to match controller placeholder usage
  final double? targetWeight;
  final DateTime? targetDate;
  // Add other goal-specific fields as necessary

  const UserGoal({
    required this.id,
    required this.userId,
    this.goalType, // Made nullable
    this.targetWeight,
    this.targetDate,
  });

  // Add fromJson factory based on controller's usage and potential DB structure
  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'] as String, // Assuming 'id' is the primary key
      userId: json['user_id'] as String,
      goalType: json['goal_type'] as String?,
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      targetDate:
          json['target_date'] == null
              ? null
              : DateTime.tryParse(json['target_date'] as String),
    );
  }

  // Add toJson method based on controller's usage and potential DB structure
  // Note: 'id' might not be needed for inserts/upserts if auto-generated or based on conflict
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'target_weight': targetWeight,
      'target_date': targetDate?.toIso8601String(),
    };
  }

  // Add copyWith if needed
}
