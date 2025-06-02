/// Enum representing the status of a booking.
enum BookingStatus {
  /// The booking is confirmed.
  confirmed,

  /// The booking has been cancelled by the user.
  cancelled_by_user,

  /// The booking has been cancelled by an admin or system.
  cancelled_by_admin,

  /// The user did not show up for the session.
  no_show,

  /// The session was completed by the user.
  completed,

  /// The booking is pending admin confirmation.
  pending,

  /// The booking is pending attendance confirmation at the gym.
  pending_attendance,

  /// The booking is pending receipt number input from the user.
  pending_receipt_number,
}
