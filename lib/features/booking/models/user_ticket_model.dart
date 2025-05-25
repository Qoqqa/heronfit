// lib/features/booking/models/user_ticket_model.dart

enum TicketStatus {
  available,     // Ticket is valid and can be used for booking
  pending_booking, // Ticket is selected, user is in booking process (e.g., selecting session)
  used,           // Ticket has been consumed for a booking.
  expired,        // Ticket has passed its validity date.
}

class UserTicket {
  final String id; // UUID from Supabase
  final DateTime createdAt;
  final String ticketCode; // The human-readable/enterable code
  final String userId; // Foreign Key to auth.users.id (non-nullable)
  TicketStatus status;
  final DateTime? activationDate; // When the ticket becomes active (if applicable)
  final DateTime? expiryDate; // When the ticket is no longer valid
  final String? sessionId; // Foreign key to sessions table, nullable

  UserTicket({
    required this.id,
    required this.createdAt,
    required this.ticketCode,
    required this.userId,
    required this.status,
    this.activationDate,
    required this.expiryDate, // Making expiry date required for a single-use ticket context
    this.sessionId,
  });

  factory UserTicket.fromJson(Map<String, dynamic> json) {
    return UserTicket(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ticketCode: json['ticket_code'] as String,
      userId: json['user_id'] as String,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'], // Using .name for enum comparison
        orElse: () => TicketStatus.available,
      ),
      activationDate: json['activation_date'] == null
          ? null
          : DateTime.parse(json['activation_date'] as String),
      expiryDate: json['expiry_date'] == null
          ? null // Should ideally not be null if it's a core part of ticket validity
          : DateTime.parse(json['expiry_date'] as String),
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Usually not sent on create
      // 'created_at': createdAt.toIso8601String(), // Usually not sent
      'ticket_code': ticketCode,
      'user_id': userId,
      'status': status.name, // Store enum as string name
      'activation_date': activationDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'session_id': sessionId,
    };
  }

  UserTicket copyWith({
    String? id,
    DateTime? createdAt,
    String? ticketCode,
    String? userId,
    TicketStatus? status,
    DateTime? activationDate,
    DateTime? expiryDate,
    String? sessionId,
  }) {
    return UserTicket(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      ticketCode: ticketCode ?? this.ticketCode,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      activationDate: activationDate ?? this.activationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserTicket &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.ticketCode == ticketCode &&
      other.userId == userId &&
      other.status == status &&
      other.activationDate == activationDate &&
      other.expiryDate == expiryDate &&
      other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      createdAt.hashCode ^
      ticketCode.hashCode ^
      userId.hashCode ^
      status.hashCode ^
      activationDate.hashCode ^
      expiryDate.hashCode ^
      sessionId.hashCode;
  }

  @override
  String toString() {
    return 'UserTicket(id: $id, createdAt: $createdAt, ticketCode: $ticketCode, userId: $userId, status: $status, activationDate: $activationDate, expiryDate: $expiryDate, sessionId: $sessionId)';
  }
}
