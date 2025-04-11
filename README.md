# HeronFit

## MVC Structure

```
lib/
│── main.dart
│── app.dart  // Handles app initialization & routing
│
├── core/      // Core utilities, services, themes
│   ├── constants.dart
│   ├── themes.dart
│   ├── services/
│   │   ├── supabase_service.dart  // Supabase authentication & data handling
│   │   ├── api_service.dart       // If needed for external APIs
│   ├── utils/
│   │   ├── validators.dart        // Form validation helpers
│   │   ├── helpers.dart           // Common functions
│
├── models/    // Data models
│   ├── user_model.dart
│   ├── booking_model.dart
│   ├── workout_model.dart
│   ├── progress_model.dart
│
├── views/     // UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── onboarding_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   ├── booking/
│   │   ├── booking_screen.dart
│   ├── workout/
│   │   ├── workout_screen.dart
│   ├── progress/
│   │   ├── progress_screen.dart
│   ├── splash_screen.dart
│
├── controllers/ // Handles business logic
│   ├── auth_controller.dart
│   ├── profile_controller.dart
│   ├── booking_controller.dart
│   ├── workout_controller.dart
│   ├── progress_controller.dart
│
├── widgets/   // Reusable UI components
│   ├── custom_button.dart
│   ├── input_field.dart
│   ├── workout_card.dart
│   ├── progress_chart.dart

```

- Views: UI screens that only handle the interface (no logic).
- Controllers: Separate business logic from UI, making it easy to manage state.
- Models: Define the data structures for users, bookings, workouts, etc.
- Core: Stores utility functions, themes, and services (like Supabase).
- Widgets: Contains reusable UI components.

  2.1 Feature-First Folder Structure

lib/
├── core/
│ ├── constants/
│ │ ├── app_constants.dart
│ │ └── theme_constants.dart
│ ├── exceptions/
│ │ └── app_exceptions.dart
│ ├── services/
│ │ ├── interfaces/
│ │ │ └── storage_service_interface.dart
│ │ ├── analytics_service.dart
│ │ └── storage_service.dart
│ └── utils/
│ ├── date_utils.dart
│ └── validators.dart
├── models/
│ ├── user.dart
│ ├── workout.dart
│ └── session.dart
├── providers/
│ ├── user_provider.dart
│ ├── gym_availability_provider.dart
│ └── activity_provider.dart
├── views/
│ ├── auth/
│ │ ├── widgets/
│ │ ├── login_screen.dart
│ │ └── signup_screen.dart
│ ├── home/
│ │ ├── widgets/
│ │ │ ├── activity_card.dart
│ │ │ ├── availability_card.dart
│ │ │ └── welcome_header.dart
│ │ └── home_screen.dart
│ ├── booking/
│ │ └── booking_screen.dart
│ └── workout/
│ └── workout_screen.dart
├── widgets/
│ ├── buttons/
│ │ └── primary_button.dart
│ ├── cards/
│ │ └── info_card.dart
│ └── loading/
│ └── skeleton_cards.dart
├── app.dart
└── main.dart
