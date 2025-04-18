import 'dart:convert';
import 'set_data_model.dart'; // Import SetData

class Exercise {
  final String id;
  final String name;
  final String force;
  final String level;
  final String? mechanic;
  final String equipment;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final String imageUrl;
  final List<SetData> sets; // Make final

  static const String _imageBaseUrl =
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

  Exercise({
    required this.id,
    required this.name,
    required this.force,
    required this.level,
    this.mechanic,
    required this.equipment,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.imageUrl,
    this.sets = const [], // Add sets to constructor with default
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      force: json['force'] ?? '',
      level: json['level'] ?? '',
      mechanic: json['mechanic'],
      equipment: json['equipment'] ?? '',
      primaryMuscle: _getFirstValue(json['primaryMuscles']),
      secondaryMuscles: _parseJsonList(json['secondaryMuscles']),
      instructions: _parseJsonList(json['instructions']),
      category: json['category'] ?? '',
      imageUrl: _getFullImageUrl(json['images']),
    );
  }

  // Extract first value safely from a JSONB array
  static String _getFirstValue(dynamic data) {
    if (data == null) return 'Unknown';

    // If data is already a List (parsed JSON)
    if (data is List && data.isNotEmpty) {
      return data.first.toString();
    }

    // If data is a string (JSONB as string)
    if (data is String) {
      try {
        final List<dynamic> parsedData = jsonDecode(data);
        if (parsedData.isNotEmpty) {
          return parsedData.first.toString();
        }
      } catch (e) {
        print('Error parsing JSON from string: $e');
      }
    }

    return 'Unknown';
  }

  // Convert JSONB array to List<String>
  static List<String> _parseJsonList(dynamic data) {
    if (data == null) return [];

    // If data is already a List (parsed JSON)
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    // If data is a string (JSONB as string)
    if (data is String) {
      try {
        final List<dynamic> parsedData = jsonDecode(data);
        return parsedData.map((e) => e.toString()).toList();
      } catch (e) {
        print('Error parsing JSON from string: $e');
      }
    }

    return [];
  }

  // Append GitHub base URL to the first image path
  static String _getFullImageUrl(dynamic images) {
    // If images is null, return empty string
    if (images == null) return '';

    try {
      // If images is already a List (parsed JSON)
      if (images is List && images.isNotEmpty) {
        final String imagePath = images.first.toString();
        return '$_imageBaseUrl$imagePath';
      }

      // If images is a string (JSONB as string)
      if (images is String) {
        try {
          final List<dynamic> parsedImages = jsonDecode(images);
          if (parsedImages.isNotEmpty) {
            final String imagePath = parsedImages.first.toString();
            return '$_imageBaseUrl$imagePath';
          }
        } catch (e) {
          print('Error parsing JSON images from string: $e');
        }
      }
    } catch (e) {
      print('Error getting full image URL: $e');
    }

    return ''; // Return empty string and handle in the UI
  }

  // Add copyWith method
  Exercise copyWith({
    String? id,
    String? name,
    String? force,
    String? level,
    String? mechanic,
    String? equipment,
    String? primaryMuscle,
    List<String>? secondaryMuscles,
    List<String>? instructions,
    String? category,
    String? imageUrl,
    List<SetData>? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      force: force ?? this.force,
      level: level ?? this.level,
      mechanic: mechanic ?? this.mechanic,
      equipment: equipment ?? this.equipment,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sets: sets ?? this.sets,
    );
  }
}
