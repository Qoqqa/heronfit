import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String? first_name; // Changed from firstName
  final String? last_name; // Changed from lastName
  final int? height;
  final double?
  weight; // Keep as double, handle conversion in fromMap/toMap if needed
  final String? birthday;
  final String? contact;
  final String? email_address; // Changed from email
  final String? avatar; // Changed from profileImageUrl
  final String? goal; // Added goal field
  final String? gender; // Added gender field
  final bool? has_session; // Added has_session field
  final DateTime? created_at; // Added created_at field

  const UserModel({
    required this.id,
    this.first_name,
    this.last_name,
    this.height,
    this.weight,
    this.birthday,
    this.contact,
    this.email_address,
    this.avatar,
    this.goal, // Added goal
    this.gender, // Added gender
    this.has_session, // Added has_session
    this.created_at, // Added created_at
  });

  // Factory constructor for creating from a map (e.g., from Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // Helper to safely parse DateTime
    DateTime? parseTimestamp(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    // Helper to safely parse double from num or String
    double? parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Helper to safely parse int from num or String
    int? parseInt(dynamic value) {
      if (value is num) {
        return value.toInt();
      } else if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    return UserModel(
      id: id,
      first_name: map['first_name'] as String?,
      last_name: map['last_name'] as String?,
      // Use helper for safe parsing, assuming DB returns int8 (int) or text
      height: parseInt(map['height']),
      // Use helper for safe parsing, assuming DB returns text (String) or numeric
      weight: parseDouble(map['weight']),
      birthday: map['birthday'] as String?, // Assuming text
      contact: map['contact'] as String?, // Assuming text
      email_address: map['email_address'] as String?, // Changed key
      avatar: map['avatar'] as String?, // Changed key
      goal: map['goal'] as String?, // Added goal
      gender: map['gender'] as String?, // Added gender
      has_session: map['has_session'] as bool?, // Added has_session
      created_at: parseTimestamp(
        map['created_at'],
      ), // Added created_at with parsing
    );
  }

  // Method to convert to a map (e.g., for updating Supabase)
  // Excludes id, email_address, created_at as they usually aren't updated this way
  Map<String, dynamic> toMap() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'height': height,
      // Convert weight back to String if DB expects text, otherwise keep as double/num
      'weight':
          weight?.toString(), // Or just 'weight': weight if DB type is numeric
      'birthday': birthday,
      'contact': contact,
      'avatar': avatar,
      'goal': goal,
      'gender': gender,
      // 'has_session' might be updated elsewhere or by triggers
    }..removeWhere(
      (key, value) => value == null,
    ); // Remove nulls before sending
  }

  // copyWith method for immutability
  UserModel copyWith({
    String? id,
    ValueGetter<String?>? first_name,
    ValueGetter<String?>? last_name,
    ValueGetter<int?>? height,
    ValueGetter<double?>? weight,
    ValueGetter<String?>? birthday,
    ValueGetter<String?>? contact,
    ValueGetter<String?>? email_address,
    ValueGetter<String?>? avatar,
    ValueGetter<String?>? goal,
    ValueGetter<String?>? gender,
    ValueGetter<bool?>? has_session,
    ValueGetter<DateTime?>? created_at,
  }) {
    return UserModel(
      id: id ?? this.id,
      first_name: first_name != null ? first_name() : this.first_name,
      last_name: last_name != null ? last_name() : this.last_name,
      height: height != null ? height() : this.height,
      weight: weight != null ? weight() : this.weight,
      birthday: birthday != null ? birthday() : this.birthday,
      contact: contact != null ? contact() : this.contact,
      email_address:
          email_address != null ? email_address() : this.email_address,
      avatar: avatar != null ? avatar() : this.avatar,
      goal: goal != null ? goal() : this.goal,
      gender: gender != null ? gender() : this.gender,
      has_session: has_session != null ? has_session() : this.has_session,
      created_at: created_at != null ? created_at() : this.created_at,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, first_name: $first_name, last_name: $last_name, height: $height, weight: $weight, birthday: $birthday, contact: $contact, email_address: $email_address, avatar: $avatar, goal: $goal, gender: $gender, has_session: $has_session, created_at: $created_at)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.first_name == first_name &&
        other.last_name == last_name &&
        other.height == height &&
        other.weight == weight &&
        other.birthday == birthday &&
        other.contact == contact &&
        other.email_address == email_address &&
        other.avatar == avatar &&
        other.goal == goal &&
        other.gender == gender &&
        other.has_session == has_session &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        first_name.hashCode ^
        last_name.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        birthday.hashCode ^
        contact.hashCode ^
        email_address.hashCode ^
        avatar.hashCode ^
        goal.hashCode ^
        gender.hashCode ^
        has_session.hashCode ^
        created_at.hashCode;
  }
}
