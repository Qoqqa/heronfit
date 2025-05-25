/// Exception thrown when a user attempts to book a new session
/// while already having an active (not completed or canceled) booking.
class ActiveBookingExistsException implements Exception {
  final String message;

  ActiveBookingExistsException([this.message = "You already have an active booking. Please cancel or wait for your current session to complete before booking another."]);

  @override
  String toString() => "ActiveBookingExistsException: $message";
}
