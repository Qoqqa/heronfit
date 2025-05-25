/// Enum representing the status of a booking.
enum BookingStatus {
  /// The booking is confirmed.
  confirmed,

  /// The booking has been cancelled by the user.
  cancelled_user,

  /// The booking has been cancelled by an admin or system.
  cancelled_admin,

  /// The user did not show up for the session.
  no_show,

  /// The session was completed by the user.
  completed,
}
