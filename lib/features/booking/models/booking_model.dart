// lib/features/booking/models/booking_model.dart
import 'package:intl/intl.dart'; // Added import for DateFormat
import 'package:heronfit/features/booking/models/booking_status.dart';

class Booking {
  final String id; // UUID from Supabase
  final DateTime createdAt; // Timestamp of when the booking record was created
  final String userId; // Foreign Key to auth.users.id
  final String sessionId; // Foreign Key to sessions.id
  final String? userTicketId; // Foreign Key to user_tickets.id, nullable
  final DateTime bookingTime; // Timestamp of when the booking was made by the user for the session
  final BookingStatus status;
  final String? bookingReferenceId; // User-friendly ID like HERONFIT-YYYYMMDD-XXXX, can be null if not generated yet
  final String? sessionOccurrenceId; // Foreign Key to session_occurrences.id, nullable

  // Session details - denormalized for easier display in booking lists
  // These fields will be populated from the 'bookings' table which now stores them directly.
  final String sessionCategory; 
  final DateTime sessionDate; 
  final String sessionStartTime; // Store as string 'HH:mm:ss' as received from DB
  final String sessionEndTime;   // Store as string 'HH:mm:ss' as received from DB

  Booking({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.sessionId,
    this.userTicketId, // Nullable
    required this.bookingTime,
    required this.status,
    this.bookingReferenceId,
    this.sessionOccurrenceId, // Add to constructor
    required this.sessionCategory,
    required this.sessionDate,
    required this.sessionStartTime,
    required this.sessionEndTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Helper to parse time strings like "10:00:00" into TimeOfDay
    // This might not be needed if we store time as string directly in the model
    // and format it in the UI.
    // TimeOfDay _parseTime(String? timeStr) {
    //   if (timeStr == null) return TimeOfDay(hour: 0, minute: 0); // Default or handle error
    //   final parts = timeStr.split(':');
    //   return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    // }

    return Booking(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String), // Assumes 'created_at' is always present
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      userTicketId: json['user_ticket_id'] as String?, // Corrected key and nullable
      bookingTime: DateTime.parse(json['booking_time'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending, // Default status set to pending
      ),
      bookingReferenceId: json['booking_reference_id'] as String?,
      sessionOccurrenceId: json['session_occurrence_id'] as String?, // Add this line
      // Denormalized fields from the 'bookings' table
      sessionCategory: json['session_category'] as String? ?? 'N/A', // From bookings table
      sessionDate: DateTime.parse(json['session_date'] as String? ?? DateTime.now().toIso8601String()), // From bookings table
      sessionStartTime: json['session_start_time'] as String? ?? '00:00:00', // From bookings table
      sessionEndTime: json['session_end_time'] as String? ?? '00:00:00',     // From bookings table
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include for passing object state
      'created_at': createdAt.toIso8601String(), // Include for passing object state
      'user_id': userId,
      'session_id': sessionId,
      'user_ticket_id': userTicketId,
      'booking_time': bookingTime.toIso8601String(),
      'status': status.name,
      'booking_reference_id': bookingReferenceId,
      'session_category': sessionCategory,
      'session_date': DateFormat('yyyy-MM-dd').format(sessionDate),
      'session_start_time': sessionStartTime,
      'session_end_time': sessionEndTime,
      'session_occurrence_id': sessionOccurrenceId, // Add this line
    };
  }

  Booking copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? sessionId,
    String? userTicketId,
    DateTime? bookingTime,
    BookingStatus? status,
    String? bookingReferenceId,
    String? sessionCategory,
    DateTime? sessionDate,
    String? sessionStartTime,
    String? sessionEndTime,
    String? sessionOccurrenceId,
  }) {
    return Booking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      userTicketId: userTicketId ?? this.userTicketId,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      bookingReferenceId: bookingReferenceId ?? this.bookingReferenceId,
      sessionOccurrenceId: sessionOccurrenceId ?? this.sessionOccurrenceId,
      sessionCategory: sessionCategory ?? this.sessionCategory,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
    );
  }

  // Getter for a short, formatted time range (e.g., "10:00 AM - 11:00 AM")
  String get sessionTimeRangeShort {
    try {
      // Parse start time
      final startTimeParts = sessionStartTime.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final startDateTime = DateTime(sessionDate.year, sessionDate.month, sessionDate.day, startHour, startMinute);
      final formattedStartTime = DateFormat.jm().format(startDateTime);

      // Parse end time
      final endTimeParts = sessionEndTime.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);
      final endDateTime = DateTime(sessionDate.year, sessionDate.month, sessionDate.day, endHour, endMinute);
      final formattedEndTime = DateFormat.jm().format(endDateTime);

      return '$formattedStartTime - $formattedEndTime';
    } catch (e) {
      // Fallback in case of parsing errors
      print('Error formatting session time range: $e');
      return '$sessionStartTime - $sessionEndTime';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Booking &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.userId == userId &&
      other.sessionId == sessionId &&
      other.userTicketId == userTicketId &&
      other.bookingTime == bookingTime &&
      other.status == status &&
      other.bookingReferenceId == bookingReferenceId &&
      other.sessionCategory == sessionCategory &&
      other.sessionDate == sessionDate &&
      other.sessionStartTime == sessionStartTime &&
      other.sessionEndTime == sessionEndTime &&
      other.sessionOccurrenceId == sessionOccurrenceId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      createdAt.hashCode ^
      userId.hashCode ^
      sessionId.hashCode ^
      userTicketId.hashCode ^
      bookingTime.hashCode ^
      status.hashCode ^
      bookingReferenceId.hashCode ^
      sessionCategory.hashCode ^
      sessionDate.hashCode ^
      sessionStartTime.hashCode ^
      sessionEndTime.hashCode ^
      sessionOccurrenceId.hashCode;
  }

  @override
  String toString() {
    return 'Booking(id: $id, createdAt: $createdAt, userId: $userId, sessionId: $sessionId, userTicketId: $userTicketId, bookingTime: $bookingTime, status: $status, bookingReferenceId: $bookingReferenceId, sessionCategory: $sessionCategory, sessionDate: $sessionDate, sessionStartTime: $sessionStartTime, sessionEndTime: $sessionEndTime, sessionOccurrenceId: $sessionOccurrenceId)';
  }
}
