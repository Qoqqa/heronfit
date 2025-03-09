class Exercise {
  final String id;
  final String name;
  final String force;
  final String level;
  final String? mechanic;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final List<String> images;

  Exercise({
    required this.id,
    required this.name,
    required this.force,
    required this.level,
    this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      force: json['force'],
      level: json['level'],
      mechanic: json['mechanic'],
      equipment: json['equipment'],
      primaryMuscles: _parseJsonList(json['primaryMuscles']),
      secondaryMuscles: _parseJsonList(json['secondaryMuscles']),
      instructions: _parseJsonList(json['instructions']),
      category: json['category'],
      images: _parseJsonList(json['images']),
    );
  }

  // ✅ **Fix: Properly handle Supabase `jsonb` fields**
  static List<String> _parseJsonList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map((e) => e.toString()).toList();
    return [];
  }
}
