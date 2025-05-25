// lib/features/booking/models/waitlist_entry_model.dart

enum WaitlistStatus {
  pending,    // User is on the waitlist.
  confirmed,  // User has been moved from waitlist to a confirmed booking.
}

class WaitlistEntry {
  final String id; // UUID from Supabase
  final DateTime createdAt;
  final String userId; // Foreign Key to auth.users.id
  final String sessionId; // Foreign Key to sessions.id
  final String ticketId; // Ticket ID that would be used if spot becomes available
  final DateTime requestTime; // When the user joined the waitlist
  WaitlistStatus status;
  final int? position; // Optional: if you want to show waitlist position

  WaitlistEntry({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.sessionId,
    required this.ticketId,
    required this.requestTime,
    required this.status,
    this.position,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) {
    return WaitlistEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      ticketId: json['ticket_id'] as String,
      requestTime: DateTime.parse(json['request_time'] as String),
      status: WaitlistStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WaitlistStatus.pending,
      ),
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      // 'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'session_id': sessionId,
      'ticket_id': ticketId,
      'request_time': requestTime.toIso8601String(),
      'status': status.name,
      'position': position,
    };
  }

  WaitlistEntry copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? sessionId,
    String? ticketId,
    DateTime? requestTime,
    WaitlistStatus? status,
    int? position,
  }) {
    return WaitlistEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      ticketId: ticketId ?? this.ticketId,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaitlistEntry &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.userId == userId &&
      other.sessionId == sessionId &&
      other.ticketId == ticketId &&
      other.requestTime == requestTime &&
      other.status == status &&
      other.position == position;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      createdAt.hashCode ^
      userId.hashCode ^
      sessionId.hashCode ^
      ticketId.hashCode ^
      requestTime.hashCode ^
      status.hashCode ^
      position.hashCode;
  }

  @override
  String toString() {
    return 'WaitlistEntry(id: $id, createdAt: $createdAt, userId: $userId, sessionId: $sessionId, ticketId: $ticketId, requestTime: $requestTime, status: $status, position: $position)';
  }
}
