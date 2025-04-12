# GitHub Copilot Custom Instructions for HeronFit Project

## 1. Project Overview & Goals

**Project:** HeronFit - A Flutter mobile application for the University of Makati gym.
**Primary Goal:** Streamline gym operations and enhance user experience through features like session booking, real-time occupancy updates, workout tracking, and progress monitoring.
**Target Users:** University students, faculty, and staff.
**Backend:** Supabase (Authentication, Database, Real-time).
**Key Technologies:** Flutter, Dart, Riverpod, Supabase.

**Remember:** An associated Admin Web App interacts with the same Supabase backend. Ensure mobile app development considers potential impacts or shared data structures with the admin system.

## 2. Core Principles & Non-Functional Requirements (NFRs)

Adhere strictly to the following principles and NFRs:

- **Maintainability:** Write clean, readable, and well-documented code. Use meaningful names for variables, functions, and classes. Keep functions short and focused.
- **Reusability:** Create reusable widgets, functions, and services whenever possible. Leverage Flutter's composable nature. Identify patterns that can be abstracted.
- **Modularity:** Design features and components in a modular way. Use the defined project structure (Views, Controllers, Models, Widgets, Core). Ensure low coupling between modules.
- **Modifiability:** Structure code to be easily adaptable to future changes or feature additions outlined in the project charter (e.g., fitness challenges, social integrations).

## 3. Architecture & Project Structure (Features-First)

Follow a features-first project structure to enhance modularity:

- `lib/main.dart`: App entry point, initialization (Supabase, dotenv).
- `lib/app.dart`: MaterialApp setup, routing, theme configuration.
- `lib/core/`: Truly cross-cutting concerns.
  - `constants/`: Application-wide constants.
  - `theme/`: Centralized theme definition (`theme.dart`).
  - `services/`: Base services or wrappers (e.g., Supabase client access).
  - `utils/`: Global utility functions, formatters.
  - `guards/`: Route guards (e.g., `auth_guard.dart`).
- `lib/widgets/`: Highly reusable, generic UI components used across multiple features (e.g., `CustomButton`, `LoadingIndicator`).
- `lib/features/`: Contains individual feature modules.
  - `auth/`
    - `controllers/`: Riverpod providers/controllers for authentication logic.
    - `models/`: Data models specific to authentication (if any beyond user).
    - `views/`: UI screens/pages for auth (Login, Register, Verify).
    - `widgets/`: Widgets specific to the auth feature.
  - `booking/`
    - `controllers/`
    - `models/` (e.g., `BookingModel`, `SessionModel`)
    - `views/`
    - `widgets/`
  - `home/`
    - `controllers/`
    - `views/`
    - `widgets/`
  - `profile/`
    - `controllers/`
    - `models/` (e.g., `UserProfileModel` if extended)
    - `views/`
    - `widgets/`
  - `workout/`
    - `controllers/`
    - `models/` (e.g., `WorkoutModel`, `ExerciseModel`, `SetModel`)
    - `views/`
    - `widgets/` (e.g., `ExerciseCard`, `SetInputRow`)
  - `progress/`
    - `controllers/`
    - `models/` (e.g., `ProgressUpdateModel`, `GoalModel`)
    - `views/`
    - `widgets/` (e.g., `ProgressChart`)
  - `onboarding/`
    - `views/`
    - `widgets/`
  - `splash/`
    - `views/`
- `lib/models/`: (Optional) Can contain core, shared data models like `UserModel` if used extensively across _many_ features, otherwise place models within the feature that primarily owns them.

**State Management:** Use **Riverpod** for state management. Place providers/controllers within the `controllers` directory of their respective feature.

## 4. Coding Standards & Conventions

- **Language:** Dart (latest stable SDK specified in `pubspec.yaml`).
- **Style:** Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and Flutter lint rules (`analysis_options.yaml`). Run `flutter analyze` frequently.
- **Naming:**
  - `UpperCamelCase` for classes, enums, typedefs, and extensions.
  - `lowerCamelCase` for variables, parameters, and function/method names.
  - `lowercase_with_underscores` for file names and directories.
  - Prefix private members with `_`.
- **Comments:** Add comments for complex logic, public APIs, and `// TODO:` markers. Avoid redundant comments.
- **Error Handling:** Implement robust error handling, especially for network requests (Supabase) and user input. Show user-friendly error messages. Use `try-catch` blocks appropriately.
- **Asynchronous Operations:** Use `async/await` for asynchronous code. Handle loading and error states explicitly in the UI.
- **Immutability:** Prefer immutable state where possible. Use `final` for variables that are not reassigned.

## 5. UI/UX Guidelines

- **Consistency:** Ensure UI elements, layouts, and interactions are consistent across the app, adhering to the designs (Figma).
- **Theme:** Use the central theme defined in `lib/core/theme/theme.dart` for colors, typography, and widget styling. Avoid hardcoding colors or styles directly in widgets.
- **Responsiveness:** Design layouts that adapt reasonably to different screen sizes.
- **Widgets:** Build complex UI by composing smaller widgets. Place feature-specific widgets in `lib/features/<feature_name>/widgets/`. Place highly reusable, generic widgets in `lib/widgets/`. Prefer `StatelessWidget` unless local, ephemeral state is required, then use `StatefulWidget` sparingly or manage state via Riverpod.
- **Assets:** Manage assets (images, fonts, .env) correctly as defined in `pubspec.yaml`.

## 6. Backend Integration (Supabase)

- **Client:** Use the initialized Supabase client (`Supabase.instance.client`). Consider wrapping client interactions in dedicated service classes within `lib/core/services/` or within feature-specific controllers/services if the interaction is highly feature-specific.
- **Authentication:** Implement auth logic within `lib/features/auth/controllers/`. Use Supabase Auth.
- **Database:** Interact with Supabase PostgreSQL database using the `supabase_flutter` package. Define data models primarily within `lib/features/<feature_name>/models/`. Handle data operations within the controllers of the relevant feature (`lib/features/<feature_name>/controllers/`).
- **Real-time:** Utilize Supabase Realtime capabilities for features like live gym occupancy updates if required by the design.
- **Security:** Follow Supabase best practices for Row Level Security (RLS) to ensure users can only access their own data or data they are permitted to see. Do not embed sensitive keys directly in code; use `.env`.

## 7. Feature Implementation Guidance

When implementing features from the Project Charter:

- **Break Down Features:** Decompose large features into smaller, manageable tasks within their feature directory (e.g., `lib/features/booking/`).
- **Follow Architecture:** Implement features using the defined structure within each feature folder.
  - **View:** Build the UI in `lib/features/<feature_name>/views/` using widgets from `lib/features/<feature_name>/widgets/` and `lib/widgets/`.
  - **Controller:** Create Riverpod providers in `lib/features/<feature_name>/controllers/` to manage state and logic.
  - **Model:** Define data structures in `lib/features/<feature_name>/models/` or `lib/models/` if truly shared.
  - **Service:** Interact with Supabase via classes in `lib/core/services/` or directly within controllers if simple.
- **User Flow:** Ensure user flows match the charter (e.g., Registration (`auth` feature) -> Email Verification (`auth` feature) -> Login (`auth` feature) -> Home (`home` feature)).
- **Workout Tracking:** Implement within `lib/features/workout/`.
- **Booking System:** Implement within `lib/features/booking/`.
- **Progress Tracking:** Implement within `lib/features/progress/`.
- **Recommendations:** See Section 10 below for implementation guidance.

## 8. Dependency Management

- Use `flutter pub add <package>` to add new dependencies.
- Keep dependencies updated (`flutter pub upgrade --major-versions`).
- Refer to `pubspec.yaml` for the list of current dependencies. Use packages effectively (e.g., `google_fonts`, `intl`, `cached_network_image`, `riverpod`).

## 9. Tooling

- **Version Control:** Git & GitHub. Commit frequently with clear messages.
- **IDE:** VS Code / Android Studio.
- **Design:** Figma (ensure implementation matches).
- **Backend:** Supabase.

## 10. Recommendation System Implementation

- **Approach:** Implement the recommendation logic (content-based, collaborative filtering, hybrid) as a **backend service**, separate from the Flutter application. This aligns with the project charter mentioning Python libraries (`scikit-learn`, `pandas`, `numpy`).
- **Rationale:**
  - Leverages mature Python data science libraries.
  - Avoids heavy computation on the client device, preserving app performance.
  - Facilitates processing of multi-user data required for collaborative filtering.
  - Enhances maintainability and scalability by decoupling the recommendation engine from the mobile app.
- **Technology:** Preferably Python (using Flask, FastAPI, or similar) hosted as a microservice or potentially using serverless functions (e.g., Google Cloud Functions, AWS Lambda). Supabase Edge Functions (Deno/TypeScript) could be an alternative for simpler logic or as a proxy to a Python backend.
- **Integration:**
  - The backend service should expose an API endpoint (e.g., `/recommendations?userId=<user_id>`).
  - The Flutter app will make an HTTP request to this endpoint.
  - The backend service computes recommendations based on user data, workout data, and interaction history.
  - The API returns a list of recommended workout/program IDs.
  - The Flutter app fetches details for these IDs from Supabase and displays them.
- **Client-Side Logic:** Avoid implementing complex recommendation algorithms directly in Dart/Flutter. Client-side logic should be limited to calling the recommendation API and displaying the results.

## 11. Tooling

- **Version Control:** Git & GitHub. Commit frequently with clear messages.
- **IDE:** VS Code / Android Studio.
- **Design:** Figma (ensure implementation matches).
- **Backend:** Supabase (Primary App Backend), Separate Service/Functions (Recommendation Engine).

## 12. Final Check

Before completing a feature or task, review if the implementation adheres to the NFRs (Maintainability, Reusability, Modularity, Modifiability) and the guidelines mentioned above, particularly the features-first structure and the recommendation system approach.
