// d:\Development\heronfit\lib\core\utils\app_strings.dart
class AppStrings {
  // Ticket Validation Error Messages
  static const String ticketNotFoundError = 'Ticket ID not found. Please check the ID and try again.';
  static const String ticketNotAssociatedError = 'This ticket is not associated with your account.';
  static const String ticketAlreadyUsedError = 'This ticket has already been used.';
  static const String ticketExpiredError = 'This ticket has expired.';
  static const String ticketNotActiveError = 'This ticket is not currently active.';
  static const String ticketPendingBookingError = 'This ticket is already pending a booking. Please complete or cancel the existing process.';
  static const String ticketStatusUpdateFailedError = 'Failed to update ticket status. Please try again.';
  static const String ticketValidationFailedError = 'Ticket validation failed. Please try again later.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';

  // Booking Process Messages
  static const String ticketValidatedSuccess = 'Ticket validated. Proceed to select a session.';

  // General
  static const String anErrorOccurred = 'An error occurred';
}
