class SetData {
  int kg;
  int reps;
  bool completed;
  Duration restTimerDuration; // Added rest timer duration

  SetData({
    required this.kg,
    required this.reps,
    required this.completed,
    this.restTimerDuration = const Duration(seconds: 90), // Default 90 seconds
  });

  // Optional: Add copyWith for easier updates if needed elsewhere
  SetData copyWith({
    int? kg,
    int? reps,
    bool? completed,
    Duration? restTimerDuration,
  }) {
    return SetData(
      kg: kg ?? this.kg,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
      restTimerDuration: restTimerDuration ?? this.restTimerDuration,
    );
  }
}
