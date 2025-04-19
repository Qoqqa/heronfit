# HeronFit

**HeronFit** is a Flutter-based mobile app built for the University of Makati gym. It streamlines gym operations and elevates the fitness experience for students, faculty, and staff by offering seamless session booking, real-time occupancy updates, personalized workout tracking, and tailored recommendations—all powered by a modern, scalable backend.

## ✨ Features

- **Session Booking:** Easily book gym sessions in advance.
- **Real-time Occupancy:** View current gym occupancy levels.
- **Workout Tracking:** Log your workouts, including exercises, sets, reps, and weight.
- **Progress Monitoring:** Track your fitness journey and achievements over time.
- **Exercise Database:** Browse and search a comprehensive database of exercises (powered by [free-exercise-db](https://github.com/yuhonas/free-exercise-db)).
- **Recommended Workouts:** Get personalized workout recommendations based on your goals and history (via external recommendation service).
- **Custom Workouts:** Create and save your own workout routines.
- **Booking Management:** View and manage your upcoming and past bookings.
- **Notifications:** Receive reminders and updates about your bookings and gym activities.

## 🚀 Technologies

- **Frontend:** Flutter & Dart
- **State Management:** Riverpod
- **Backend:** Supabase (Authentication, PostgreSQL Database, Real-time Subscriptions)
- **Recommendation Engine:** External Python service (Flask/FastAPI) - _Details in `docs/recommendation_engine_guide.md`_

## ⚙️ Setup & Installation

1.  **Prerequisites:**
    - Flutter SDK (See `pubspec.yaml` for version)
    - Dart SDK
    - IDE (VS Code or Android Studio recommended)
    - Supabase Account & Project
2.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd heronfit
    ```
3.  **Environment Setup:**
    - Create a `.env` file in the `assets/` directory.
    - Add your Supabase URL and Anon Key:
      ```env
      SUPABASE_URL=YOUR_SUPABASE_URL
      SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
      ```
4.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
5.  **Run the App:**
    ```bash
    flutter run
    ```
    _(Ensure you have a connected device or running emulator/simulator)._

## 🏛️ Architecture

This project follows a **features-first** architecture, organizing code by application features (e.g., `auth`, `booking`, `workout`). Core functionalities, shared widgets, and utilities are located in the `lib/core/` and `lib/widgets/` directories.
