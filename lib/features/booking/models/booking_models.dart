class Ticket {
  final String id;
  final String userId;
  final String status; // active, used, expired, pending_booking
  final DateTime createdAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  Ticket({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.usedAt,
    this.expiresAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at'] as String) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  Ticket copyWith({
    String? id,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? usedAt,
    DateTime? expiresAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class GymSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCapacity;
  final int slotsBooked;
  final bool isFull;

  GymSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.slotsBooked,
  }) : isFull = slotsBooked >= maxCapacity;

  factory GymSession.fromJson(Map<String, dynamic> json) {
    return GymSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      maxCapacity: json['max_capacity'] as int,
      slotsBooked: json['slots_booked'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'max_capacity': maxCapacity,
      'slots_booked': slotsBooked,
    };
  }
}

class Booking {
  final String id;
  final String userId;
  final String sessionId;
  final String ticketId;
  final String status; // confirmed, cancelled, completed, no_show
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Booking({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.ticketId,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      ticketId: json['ticket_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'ticket_id': ticketId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
    };
  }
}
