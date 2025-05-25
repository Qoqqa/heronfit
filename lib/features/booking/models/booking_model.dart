// lib/features/booking/models/booking_model.dart

enum BookingStatus {
  confirmed,    // Booking is active and confirmed.
  cancelled_by_user, // User cancelled the booking.
  cancelled_by_admin, // Admin cancelled the booking.
  attended,       // User attended the session.
  no_show,        // User did not attend the session.
  // 'waitlisted' status will be handled by the WaitlistEntry model
}

class Booking {
  final String id; // UUID from Supabase
  final DateTime createdAt; // Timestamp of when the booking record was created
  final String userId; // Foreign Key to auth.users.id
  final String sessionId; // Foreign Key to sessions.id
  final String ticketIdUsed; // Foreign Key to user_tickets.id
  final DateTime bookingTime; // Timestamp of when the booking was made by the user for the session
  final BookingStatus status;
  final String bookingReferenceId; // User-friendly ID like HERONFIT-YYYYMMDD-XXXX

  Booking({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.sessionId,
    required this.ticketIdUsed,
    required this.bookingTime,
    required this.status,
    required this.bookingReferenceId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      ticketIdUsed: json['ticket_id_used'] as String,
      bookingTime: DateTime.parse(json['booking_time'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      bookingReferenceId: json['booking_reference_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      // 'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'session_id': sessionId,
      'ticket_id_used': ticketIdUsed,
      'booking_time': bookingTime.toIso8601String(),
      'status': status.name,
      'booking_reference_id': bookingReferenceId,
    };
  }

  Booking copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? sessionId,
    String? ticketIdUsed,
    DateTime? bookingTime,
    BookingStatus? status,
    String? bookingReferenceId,
  }) {
    return Booking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      ticketIdUsed: ticketIdUsed ?? this.ticketIdUsed,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      bookingReferenceId: bookingReferenceId ?? this.bookingReferenceId,
    );
  }

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Booking &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.userId == userId &&
      other.sessionId == sessionId &&
      other.ticketIdUsed == ticketIdUsed &&
      other.bookingTime == bookingTime &&
      other.status == status &&
      other.bookingReferenceId == bookingReferenceId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      createdAt.hashCode ^
      userId.hashCode ^
      sessionId.hashCode ^
      ticketIdUsed.hashCode ^
      bookingTime.hashCode ^
      status.hashCode ^
      bookingReferenceId.hashCode;
  }

  @override
  String toString() {
    return 'Booking(id: $id, createdAt: $createdAt, userId: $userId, sessionId: $sessionId, ticketIdUsed: $ticketIdUsed, bookingTime: $bookingTime, status: $status, bookingReferenceId: $bookingReferenceId)';
  }
}
