import 'exercise_model.dart'; // Import Exercise model

class Workout {
  final String id;
  final String name;
  final List<Exercise> exercises; // Changed from List<String>
  final Duration duration;
  final DateTime timestamp;
  final DateTime? createdAt;

  Workout({
    required this.id,
    required this.name,
    required this.exercises, // Keep as required
    required this.duration,
    DateTime? timestamp,
    this.createdAt,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Workout.fromJson(Map<String, dynamic> json) {
    var exerciseListFromJson = json['exercises'] as List? ?? [];
    List<Exercise> exercises =
        exerciseListFromJson.map((exJson) {
          // Handle potential type mismatch during deserialization
          if (exJson is Map<String, dynamic>) {
            return Exercise.fromJson(exJson);
          } else {
            // Log or handle unexpected data format if necessary
            print("Warning: Unexpected exercise format in JSON: $exJson");
            // Return a default/empty Exercise or throw an error
            return Exercise(
              id: '',
              name: 'Invalid Exercise Data',
              force: '',
              level: '',
              equipment: '',
              primaryMuscle: '',
              secondaryMuscles: [],
              instructions: [],
              category: '',
              imageUrl: '',
            ); // Example default
          }
        }).toList();

    return Workout(
      id: json['id'] ?? '', // Provide default value if null
      name: json['name'] ?? 'Unnamed Workout', // Provide default value if null
      exercises: exercises, // Use parsed list
      duration: Duration(seconds: json['duration'] ?? 0), // Provide default
      timestamp:
          json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp']) ??
                  DateTime.now() // Use tryParse
              : DateTime.now(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) // Use tryParse
              : null,
    );
  }

  factory Workout.fromSupabase(Map<String, dynamic> json) {
    return Workout(
      id: json['id'].toString(),
      name: json['name'],
      exercises: [], // Will be populated later by the service layer
      duration: Duration(seconds: json['duration'] ?? 0),
      timestamp: DateTime.parse(json['timestamp']),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises':
          exercises
              .map((ex) => ex.toJson()) // Use Exercise.toJson()
              .toList(),
      'duration': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises, // Changed type
    Duration? duration,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises, // Use updated type
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
