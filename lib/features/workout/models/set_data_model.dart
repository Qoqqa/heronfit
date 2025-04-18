class SetData {
  final int kg;
  final int reps;
  final bool completed;

  SetData({required this.kg, required this.reps, this.completed = false});

  SetData copyWith({int? kg, int? reps, bool? completed}) {
    return SetData(
      kg: kg ?? this.kg,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'kg': kg, 'reps': reps, 'completed': completed};
  }

  factory SetData.fromJson(Map<String, dynamic> json) {
    return SetData(
      kg: json['kg'] ?? 0,
      reps: json['reps'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }
}
