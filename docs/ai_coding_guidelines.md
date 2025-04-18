# HeronFit: AI Development Guidelines

**Document Version:** 1.1
**Date:** April 11, 2025 (Updated from context.md v1.0 & guide.md)

## 1. Introduction

This document provides consolidated and refined guidance for the AI-assisted development of the HeronFit mobile application. It merges insights from previous guidance documents (`context.md`, `guide.md`) and aligns with the project charter and established custom instructions. The goal is to ensure consistent, high-quality, maintainable, and scalable code that adheres to the project's vision and technical requirements.

**Assume:** Familiarity with the project charter, core technologies (Flutter, Dart, Riverpod, Supabase), and the existing codebase structure.

## 2. Project Overview & Goals

- **Project:** HeronFit - A Flutter mobile application for the University of Makati gym.
- **Primary Goal:** Streamline gym operations and enhance user experience through features like session booking, real-time occupancy updates, workout tracking, and progress monitoring.
- **Target Users:** University students, faculty, and staff.
- **Backend:** Supabase (Authentication, Database, Real-time).
- **Key Technologies:** Flutter, Dart, Riverpod, Supabase.
- **Admin Web App:** Remember an associated Admin Web App interacts with the same Supabase backend. Ensure mobile app development considers potential impacts or shared data structures.

## 3. Core Principles & Non-Functional Requirements (NFRs)

Adhere strictly to the following principles and NFRs:

- **Maintainability:** Write clean, readable, and well-documented code. Use meaningful names. Keep functions short and focused.
- **Reusability:** Create reusable widgets, functions, and services. Leverage Flutter's composable nature. Abstract common patterns.
- **Modularity:** Design features and components in a modular way using the defined project structure. Ensure low coupling.
- **Modifiability:** Structure code to be easily adaptable to future changes (e.g., fitness challenges, social integrations).

## 4. Architecture & Project Structure (Features-First)

Follow a **features-first** project structure:

- `lib/main.dart`: App entry point, initialization (Supabase, dotenv, Riverpod ProviderScope).
- `lib/app.dart`: MaterialApp setup, routing, theme configuration.
- `lib/core/`: Cross-cutting concerns.
  - `constants/`: App-wide constants.
  - `theme/`: Centralized theme (`theme.dart`).
  - `services/`: Base services/wrappers (e.g., Supabase client access, centralized error handling).
  - `utils/`: Global utility functions, formatters.
  - `guards/`: Route guards (e.g., `auth_guard.dart`).
- `lib/widgets/`: Highly reusable, generic UI components (e.g., `CustomButton`, `LoadingIndicator`, `ReusableCard`).
- `lib/features/`: Individual feature modules.
  - `<feature_name>/` (e.g., `auth`, `booking`, `home`, `profile`, `workout`, `progress`)
    - `controllers/`: Riverpod providers/controllers for state and logic.
    - `models/`: Data models specific to the feature.
    - `views/`: UI screens/pages.
    - `widgets/`: Widgets specific to the feature.
    - `services/` (Optional): Services specific to the feature if complex.
- `lib/models/`: (Optional) Core, shared data models (e.g., `UserModel`) if used across _many_ features. Prefer placing models within their primary feature module.

## 5. State Management (Riverpod)

- **Standardize on Riverpod:** Use Riverpod for all state management. Replace any remaining `setState` calls used for managing application state (keep `setState` only for local, ephemeral UI state within `StatefulWidget`s if necessary, but prefer Riverpod).
- **Provider Placement:** Define providers within the `controllers` directory of their respective feature.
- **Provider Types:** Use appropriate provider types (`Provider`, `StateProvider`, `StateNotifierProvider`, `FutureProvider`, `StreamProvider`) based on the state's nature.
- **Async State:** Handle asynchronous operations (fetching data, etc.) using `FutureProvider` or `StreamProvider` and leverage `AsyncValue` ( `data`, `loading`, `error` states) in the UI for clean handling of different states.
- **Example Structure (within a feature):**
  - `features/home/controllers/user_greeting_provider.dart`
  - `features/booking/controllers/booking_controller.dart` (using `StateNotifierProvider` for complex logic)
  - `features/workout/controllers/exercise_list_provider.dart` (using `FutureProvider.autoDispose.family` for fetching exercises with parameters)

## 6. Coding Standards & Conventions

- **Language:** Dart (latest stable SDK).
- **Style:** Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and Flutter lint rules (`analysis_options.yaml`). Run `flutter analyze` frequently.
- **Naming:** `UpperCamelCase` for classes/enums, `lowerCamelCase` for variables/functions, `lowercase_with_underscores` for files/directories. Prefix private members with `_`.
- **Comments:** Add comments for complex logic, public APIs, and `// TODO:` markers. Avoid redundant comments. Document public classes and methods.
- **Immutability:** Prefer immutable state. Use `final` extensively. Use immutable data classes (e.g., with `copyWith` methods).
- **`const`:** Use `const` constructors for widgets and objects where possible to improve performance.

## 7. UI/UX Guidelines

- **Consistency:** Adhere strictly to the Figma design system. Use the central theme.
- **Theme:** Use `lib/core/theme/theme.dart` for all colors, typography, and widget styling. Avoid hardcoding values.
- **Responsiveness:** Design layouts that adapt to different screen sizes.
- **Widgets:** Build UI by composing small, reusable widgets. Place generic widgets in `lib/widgets/` and feature-specific ones in `lib/features/<feature_name>/widgets/`. Prefer `StatelessWidget` or `ConsumerWidget` (Riverpod). Use `StatefulWidget` or `ConsumerStatefulWidget` sparingly.
- **Loading/Error States:** Implement clear loading indicators (e.g., `CircularProgressIndicator`, skeleton screens) and user-friendly error messages/widgets, especially when using `AsyncValue` from Riverpod.
- **Assets:** Manage assets correctly via `pubspec.yaml`.

## 8. Backend Integration (Supabase)

- **Client:** Use the initialized Supabase client (`Supabase.instance.client`). Consider a wrapper service in `lib/core/services/` for easier testing and management.
- **Authentication:** Implement auth logic within `lib/features/auth/controllers/`. Use Supabase Auth features (email/pass, verification, recovery).
- **Database:** Interact with PostgreSQL via `supabase_flutter`. Define models in `models/` or feature folders. Handle data operations within Riverpod controllers/notifiers.
- **Real-time:** Utilize Supabase Realtime for live updates (e.g., gym occupancy) via `StreamProvider` in Riverpod.
- **Security:** Implement and test Row Level Security (RLS) policies rigorously. Use `.env` files for keys (`flutter_dotenv`).
- **Error Handling:** Wrap Supabase calls in `try-catch` blocks within controllers/services. Map Supabase errors to application-specific errors or states.

### Database Schema Overview

_(Based on provided diagram - review data types and relationships. The schema below reflects the visual information provided.)_

**`users`**

```sql
-- Links to auth.users via id
id uuid PK
created_at timestamptz
first_name text
last_name text
email_address text
birthday text
gender text
weight text -- Consider numeric/float type?
height int8
goal text
contact text
has_session bool
```

**`exercises`**

```sql
id uuid PK
name text
force text
level text
mechanic text
equipment text
primaryMuscles jsonb
secondaryMuscles jsonb
instructions jsonb
category text
images jsonb
```

**`workouts`**

```sql
id uuid PK
name text
exercises _text -- Note: Seems redundant given workout_exercises table. Verify purpose. Consider if this should be text[] or removed.
duration int8
timestamp timestamptz
user_id uuid FK -> users.id
```

**`workout_exercises`** (Join Table)

```sql
id uuid PK
workout_id uuid FK -> workouts.id
exercise_id uuid FK -> exercises.id
order_index int8
```

**`exercise_sets`**

```sql
id int8 PK -- Consider uuid if high volume expected?
workout_exercise_id uuid FK -> workout_exercises.id
weight_kg numeric
reps int8
completed bool
set_number int8
```

**`update_weight`**

```sql
id int8 PK -- Consider uuid?
date text -- Consider date/timestamp type?
pic text
email text
identifier_id uuid -- Likely FK -> users.id, verify relationship
weight text -- Consider numeric/float type?
```

## 9. Error Handling

- **Centralized Service (Optional but Recommended):** Consider creating an error handling service in `lib/core/services/` for logging errors (e.g., to a remote service like Sentry) and potentially showing standardized user messages.
- **UI Feedback:** Display user-friendly error messages using dedicated widgets or dialogs. Avoid showing raw exception messages. Leverage Riverpod's `AsyncValue.error` state.
- **Logging:** Implement robust logging for debugging.

## 10. Performance Optimization

- **Widget Builds:** Use `const` widgets. Minimize widget rebuilds using appropriate Riverpod providers and `select`.
- **Lists:** Implement pagination (`FutureProvider.family` with page numbers, infinite scrolling) for long lists (e.g., workout history, exercises). Use `ListView.builder`. Use keys if list items change order or identity.
- **Images:** Use `cached_network_image` for network images. Optimize image sizes and formats. Consider lazy loading.
- **Async:** Avoid blocking the UI thread. Use `async/await` correctly.
- **Profiling:** Use Flutter DevTools to identify and fix performance bottlenecks.

## 11. Feature Implementation Guidance

- **Follow Architecture:** Implement features within their dedicated folders (`lib/features/<feature_name>/`).
- **Booking System:** Implement ticket validation, waitlists, real-time occupancy updates. Add user type restrictions and trainer assistance requests.
- **Workout Tracking:** Integrate exercise DB (`yuhonas/free-exercise-db`), add GIF support, implement equipment filtering, complete customization/program features.
- **Recommendation System:**
  - **Backend Focus:** Implement core logic (content-based, collaborative filtering) as a **separate backend service** (Python/Flask/FastAPI preferred, or Supabase Edge Functions if simpler).
  - **Flutter Role:** Call the recommendation API endpoint, receive recommendations (e.g., list of workout IDs), fetch details from Supabase, and display them.
  - **Data:** Ensure the backend service has access to necessary user/workout data.
  - **Enhancements:** Allow user preferences, implement feedback loops.
- **Profile:** Implement all sections (Bookings, History, Settings, etc.).
- **Admin Features (Informational):** Be aware of Admin needs like analytics, attendance tracking, and targeted alerts when designing shared data structures.

## 12. Testing

- **Unit Tests:** Test business logic within Riverpod controllers/notifiers and utility functions (`test` package). Mock dependencies (services, repositories).
- **Widget Tests:** Test individual widgets and simple screen interactions (`flutter_test` package). Verify UI elements based on state.
- **Integration Tests:** Test critical user flows spanning multiple screens and services (e.g., login -> booking, start workout -> save) (`integration_test` package).

## 13. Accessibility (A11y)

- **Semantics:** Use `Semantics` widgets to provide labels for screen readers.
- **Contrast:** Ensure sufficient color contrast using `ThemeData`.
- **Touch Targets:** Ensure buttons and interactive elements have minimum touch target sizes (e.g., 48x48 dp).
- **Dynamic Text:** Support system font size settings.

## 14. Security

- **Input Validation:** Validate all user input.
- **API Calls:** Secure communication with backend services (HTTPS).
- **Dependencies:** Keep packages updated and check for vulnerabilities.
- **RLS:** Enforce Supabase Row Level Security.

## 15. Final Check

Before completing tasks, review against these guidelines, NFRs, and the features-first structure. Ensure code is clean, tested, and performs well.
