class AppRoutes {
  static const splash = '/splash'; // Add splash route
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const registerVerify = '/register/verify'; // Example, adjust as needed
  static const requestOtp =
      '/password-recovery/request-otp'; // Renamed and new path
  static const enterOtp =
      '/password-recovery/enter-otp'; // New route for OTP entry
  static const createNewPassword =
      '/password-recovery/create-new-password'; // New route for new password
  static const registerStep2 = '/register/step2'; // Example, adjust as needed
  static const registerGettingToKnow = '/register/getting-to-know';
  static const registerSetGoals = '/register/set-goals';
  static const registerSuccess = '/register/success';

  static const home =
      '/home'; // Base for main app features often using ShellRoute
  static const booking = '/booking'; // Route for the main booking tab (legacy)

  // Profile Routes
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileHistory = '/profile/history';
  static const profileContact = '/profile/contact';
  static const profilePrivacy = '/profile/privacy';
  static const profileTerms = '/profile/terms';

  // Booking Flow Routes
  static const bookings = '/bookings';
  static const activateGymPass = '/booking/activate';
  static const selectSession = '/booking/select-session';
  static const reviewBooking = '/booking/review-booking'; // New route
  static const bookingDetails = '/booking/booking-details'; // New route

  // Workout Routes
  static const workout = '/workout'; // Maybe a base screen
  static const workoutAddExercise = '/workout/add-exercise';
  static const exerciseDetails =
      '/workout/exercise-details'; // Added route for details
  static const workoutActive = '/workout/active';
  static const workoutComplete = '/workout/complete';
  static const workoutSelectTemplate = '/workout/select-template';
  static const workoutStartNew =
      '/workout/start-new'; // Route for StartNewWorkoutWidget
  static const workoutStartFromTemplate =
      '/workout/start-template'; // Route for StartWorkoutFromTemplate
  static const workoutMyTemplates = '/workout/my-templates'; // Added route
  static const recommendedWorkouts =
      '/workout/recommended'; // Add route for recommended screen

  // Progress Routes
  static const progress = '/progress'; // Base route for progress dashboard
  static const progressTracker = '/progress/tracker';
  static const progressEditGoals = '/progress/edit-goals'; // Added route
  static const progressUpdateWeight = '/progress/update-weight'; // Added route
  static const progressPhotoList = '/progress/photos';
  static const progressPhotoCompare = '/progress/photos/compare';
  // static const progressPhotoList = '/progress/photo-list'; // Added route
  static const progressAddPhoto = '/progress/add-photo'; // Example if needed
  static const progressViewPhoto =
      '/progress/view-photo'; // Needs parameter for photo ID/details
  static const progressCompare = '/progress/compare'; // Needs parameters
  static const progressSelectPhoto =
      '/progress/select-photo'; // Example if needed
  static const progressDetails = '/progress/details'; // Add new route

  // ADDED: Route for the Workout Details screen
  static const String workoutDetails = '/workoutDetails';

  // Add other routes as needed

  // ADDED: Route for the notifications screen
  static const String notifications = '/notifications';
  // ADDED: Route for the notification details screen
  static const String notificationDetails = '/notifications/:id';

  // Legacy booking routes (to be removed after migration)
  static const String legacyBookings = '/legacy/bookings';
  static const String legacyBookingDetails = '/legacy/booking-details';
}
