---
description:
globs:
alwaysApply: true
---

# HeronFit: Comprehensive AI Development Guidelines

**Document Version:** 2.1
**Date:** May 25, 2025 (Updated with refined booking flow and build tool guidelines)

## 1. Introduction

This document provides comprehensive, consolidated guidance for the AI-assisted development of the HeronFit mobile application. It merges and refines insights from previous guidance documents (`custom_instructions.md`, `ai_coding_guidelines.md`, `context.md`, `commit_message_instructions.md`) and aligns with the project charter. The goal is to ensure consistent, high-quality, maintainable, and scalable code that adheres to the project's vision and technical requirements.

**Assume:** Familiarity with the project charter, core technologies (Flutter, Dart, Riverpod, Supabase), the existing codebase structure, and the project's current status (post-60% completion).

## 2. Project Overview & Goals

- **Project:** HeronFit - A Flutter mobile application for the University of Makati gym.
- **Primary Goal:** Streamline gym operations and enhance user experience through features like session booking, real-time occupancy updates, workout tracking, and progress monitoring.
- **Target Users:** University students, faculty, and staff.
- **Backend:** Supabase (Authentication, Database, Real-time).
- **Key Technologies:** Flutter, Dart, Riverpod, Supabase.
- **Admin Web App:** Remember an associated Admin Web App interacts with the same Supabase backend. Ensure mobile app development considers potential impacts or shared data structures.
- **External Data:** `yuhonas/free-exercise-db` (Ensure proper attribution and integration strategy).

## 3. Core Principles & Non-Functional Requirements (NFRs)

Adhere strictly to the following principles and NFRs:

- **Maintainability:** Write clean, readable, and well-documented code. Use meaningful names. Keep functions short and focused. Refactor code where necessary for clarity.
- **Reusability:** Create reusable widgets, functions, and services. Leverage Flutter's composable nature. Abstract common patterns.
- **Modularity:** Design features and components in a modular way using the defined project structure. Ensure low coupling between modules.
- **Modifiability:** Structure code to be easily adaptable to future changes (e.g., fitness challenges, social integrations). Ensure the architecture supports modifications and scalability.

## 4. Architecture & Project Structure (Features-First)

Follow a **features-first** project structure:

- `lib/main.dart`: App entry point, initialization (Supabase, dotenv, Riverpod ProviderScope).
- `lib/app.dart`: MaterialApp setup, routing, theme configuration.
- `lib/core/`: Truly cross-cutting concerns.
  - `constants/`: App-wide constants.
  - `theme/`: Centralized theme (`theme.dart`).
  - `services/`: Base services/wrappers (e.g., Supabase client access, centralized error handling).
  - `utils/`: Global utility functions, formatters.
  - `guards/`: Route guards (e.g., `auth_guard.dart`).
- `lib/widgets/`: Highly reusable, generic UI components (e.g., `CustomButton`, `LoadingIndicator`, `ReusableCard`).
- `lib/features/`: Individual feature modules.
  - `<feature_name>/` (e.g., `auth`, `booking`, `home`, `profile`, `workout`, `progress`, `onboarding`, `splash`)
    - `controllers/`: Riverpod providers/controllers for state and logic.
    - `models/`: Data models specific to the feature.
    - `views/`: UI screens/pages.
    - `widgets/`: Widgets specific to the feature.
    - `services/` (Optional): Services specific to the feature if complex.
- `lib/models/`: (Optional) Core, shared data models (e.g., `UserModel`) if used across _many_ features. Prefer placing models within their primary feature module.

## 5. State Management (Riverpod)

- **Standardize on Riverpod:** Use Riverpod for all application state management. Replace any remaining `setState` calls used for managing application state. Keep `setState` _only_ for local, ephemeral UI state within `StatefulWidget`s or `ConsumerStatefulWidget`s if absolutely necessary, but strongly prefer Riverpod.
- **Provider Placement:** Define providers within the `controllers` directory of their respective feature.
- **Provider Types:** Use appropriate provider types (`Provider`, `StateProvider`, `StateNotifierProvider`, `FutureProvider`, `StreamProvider`) based on the state's nature and complexity.
- **Async State:** Handle asynchronous operations (fetching data, Supabase calls) using `FutureProvider` or `StreamProvider`. Leverage `AsyncValue` (`data`, `loading`, `error` states) in the UI (`.when()` method) for clean handling of different states.
- **Immutability:** Ensure state managed by Riverpod is immutable. Use immutable data classes (e.g., with `copyWith` methods) within `StateNotifier`s.

## 6. Coding Standards & Conventions

- **Language:** Dart (latest stable SDK specified in `pubspec.yaml`).
- **Style:** Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and Flutter lint rules defined in `analysis_options.yaml`. Run `flutter analyze` frequently.
- **Naming:**
  - `UpperCamelCase` for classes, enums, typedefs, and extensions.
  - `lowerCamelCase` for variables, parameters, and function/method names.
  - `lowercase_with_underscores` for file names and directories.
  - Prefix private members (`_`) only when necessary to enforce privacy within a library.
- **Comments:** Add comments for complex logic, public APIs (`///` for documentation comments), and `// TODO:` markers. Avoid redundant comments. Document public classes and methods.
- **Immutability:** Prefer immutable state and variables. Use `final` extensively.
- **`const`:** Use `const` constructors for widgets and objects wherever possible to improve performance and reduce rebuilds.
- **Null Safety:** Leverage Dart's sound null safety features fully. Avoid unnecessary null checks (`!`) and handle potential null values gracefully.
- **Code Generation:** **DO NOT use `build_runner` or similar code generation tools (e.g., `freezed`, `json_serializable`) for data models or Riverpod providers.** Manually implement `copyWith` methods and `fromJson`/`toJson` for data models. Riverpod's `codegen` should also be avoided; define providers explicitly. This ensures maximum readability, maintainability, and control over generated code.

## 7. UI/UX Guidelines

- **Consistency:** Adhere strictly to the Figma design system (components, styles, spacing, typography). Perform UI audits against Figma. Refine design inconsistencies.
- **Theme:** Use `lib/core/theme/theme.dart` for all colors, typography, and widget styling. Avoid hardcoding style values directly in widgets.
- **Responsiveness:** Design layouts that adapt reasonably to different screen sizes and orientations.
- **Widgets:** Build UI by composing small, reusable widgets. Place generic widgets in `lib/widgets/` and feature-specific ones in `lib/features/<feature_name>/widgets/`. Prefer `StatelessWidget` or `ConsumerWidget` (Riverpod). Use `StatefulWidget` or `ConsumerStatefulWidget` sparingly for local UI state.
- **Loading/Error States:** Implement clear loading indicators (e.g., `CircularProgressIndicator`, skeleton screens) and user-friendly error messages/widgets, especially when handling `AsyncValue` from Riverpod.
- **Clarity:** Provide clearer labels and instructions throughout the app. Improve the onboarding flow. Review all user-facing text.
- **Assets:** Manage assets (images, fonts, `.env`) correctly via `pubspec.yaml`. Use `flutter_dotenv` for environment variables.

## 8. Backend Integration (Supabase)

- **Client:** Use the initialized Supabase client (`Supabase.instance.client`). Consider a wrapper service in `lib/core/services/supabase_service.dart` for easier testing, management, and potential abstraction.
- **Authentication:** Implement auth logic within `lib/features/auth/controllers/`. Utilize Supabase Auth features (email/pass, email verification, password recovery).
- **Database:** Interact with PostgreSQL via `supabase_flutter`. Define data models in `models/` or feature folders. Handle data operations (CRUD) within Riverpod controllers/notifiers, potentially delegating to feature-specific services.
- **Real-time:** Utilize Supabase Realtime subscriptions for live updates (e.g., gym occupancy, booking status) via `StreamProvider` in Riverpod. Ensure subscriptions are properly managed and disposed.
- **Edge Functions:** If used (e.g., for simple backend logic or proxying), define clear API endpoints, manage dependencies, and ensure secure invocation from the Flutter app.
- **Data Models:** Finalize PostgreSQL table schemas, ensuring appropriate relationships, constraints, and indexing for performance.
  - **Workout History Update:** The schema now includes `workouts`, `exercises`, `workout_exercises`, and `exercise_sets` tables to store detailed workout history. A Supabase database function `save_full_workout` is used for transactional saving of workout data.
- **Security:**
  - Implement and test comprehensive Row Level Security (RLS) policies for all tables containing user-specific or sensitive data. Ensure users can only access their own data or data they are permitted to see.
  - Use `.env` files for Supabase URL and Anon Key. Do not commit `.env` files.

## 9. Error Handling

- **Robustness:** Implement comprehensive error handling, especially for network requests (Supabase calls) and user input validation.
- **`try-catch`:** Wrap potentially failing operations (especially async calls like Supabase interactions) in `try-catch` blocks within controllers or services.
- **UI Feedback:** Display user-friendly error messages using dedicated widgets, dialogs, or SnackBars. Avoid showing raw exception messages or stack traces to the user. Leverage Riverpod's `AsyncValue.error` state for displaying errors related to async operations.
- **Logging:** Implement robust logging (e.g., using the `logging` package). Consider integrating a remote logging service (like Sentry) for production monitoring and diagnosing component failures.
- **Centralized Service (Optional):** Consider an error handling service in `lib/core/services/` to standardize logging and potentially user notification logic.

## 10. Performance Optimization

- **Widget Builds:** Use `const` widgets extensively. Minimize widget rebuilds using appropriate Riverpod providers (`.autoDispose`, `.family`) and `ref.watch` / `ref.select` judiciously.
- **Lists:** Implement pagination or infinite scrolling (`FutureProvider.family` with page/offset parameters) for long lists (e.g., workout history, exercises). Use `ListView.builder`. Use keys (`ValueKey`) if list items have stable identities and might change order.
- **Images:** Use `cached_network_image` for efficient loading and caching of network images. Optimize image sizes and formats before uploading. Consider lazy loading images within lists. Replace static images with GIFs for exercises where appropriate.
- **Async:** Avoid blocking the UI thread. Use `async/await` correctly. Offload heavy computations to isolates if necessary (though prefer backend processing).
- **Profiling:** Use Flutter DevTools (CPU profiler, memory profiler, widget rebuild tracker) to identify and fix performance bottlenecks.

## 11. Feature Implementation Guidance (Remaining 40% Focus)

Prioritize based on project milestones and address charter recommendations.

- **Follow Architecture:** Implement all features within their dedicated folders (`lib/features/<feature_name>/`). Break down large features into smaller tasks.

- **Booking System Implementation (Refined Flow):**
  The booking system must adhere strictly to the following streamlined, single-session ticket flow:

  1.  **User Navigation:** User taps the **"Book" icon** in the bottom navigation bar.

  2.  **Screen: Activate Your Gym Pass**

      - **Purpose:** The entry point for gym booking, requiring a valid single-session ticket ID upfront.
      - **Title:** "Activate Your Gym Pass"
      - **Primary Message:** "To book your single gym session at the **University of Makati HPSB 11th Floor Gym**, please enter your valid Ticket ID."
      - **Input Field:** "Ticket ID" (e.g., `XXXX-XXXX-XXXX-XXXX`)
      - **Help Text:** "Find your Ticket ID on your purchase confirmation email or receipt."
      - **Button:** "Activate & Find Sessions"
      - **Backend Validation (Critical):**
        - Validate Ticket ID existence, `active` status (not used/expired), and **association with the current user's logged-in account**.
        - Temporarily mark ticket as `pending_booking` in Supabase upon successful validation.
        - Provide clear, specific error messages for invalid, used, expired, or unassociated tickets.

  3.  **Screen: Select Your Session**

      - **Purpose:** Allows users to choose a date and available time slot after ticket activation.
      - **Title:** "Select Your Session"
      - **Location Display:** Prominently display: "Location: **University of Makati HPSB 11th Floor Gym**"
      - **Calendar View:**
        - Visually distinguish dates with available slots.
        - Disable/grey out dates with no availability or in the past.
      - **Available Slots List:**
        - For each slot: Display "Time Slot", "Capacity Status" ("X of 15 slots remaining" or "Full").
        - **Action Button:** "Book This Slot" (if available) or "Join Waitlist" (if full).

  4.  **Waitlist Interaction (If Slot is Full):**

      - **Purpose:** Offers users an option to be notified if a slot becomes available.
      - **User Action:** Taps "Join Waitlist" on a full slot.
      - **Modal: Join Waitlist?**
        - **Title:** "Join Waitlist?"
        - **Message:** "This session is currently full. If a slot becomes available, we'll notify you. Would you like to join the waitlist for [Date], [Time Slot]?"
        - **Buttons:** "Yes, Join Waitlist" / "No, Find Another Session"
      - **Backend Process:** If "Yes, Join Waitlist" is tapped, add user to waitlist in Supabase. **Revert the `pending_booking` status of the Ticket ID**, allowing it to be used for a different booking or waitlist entry.
      - **Confirmation Message (Waitlist):** "You've been added to the waitlist for [Date], [Time Slot]. We'll send you an in-app notification if a slot opens up!"

  5.  **Screen: Review Your Booking**

      - **Purpose:** Presents selected details for final confirmation before booking.
      - **Title:** "Review Your Booking"
      - **Details Display:** Summarize Date, Time, Location, and the partial Ticket ID used.
      - **Buttons:** "Confirm Booking" / "Change Session" (to go back to `Select Your Session`).

  6.  **Booking Finalization (Backend Process):**

      - Upon "Confirm Booking" tap: Update slot status in Supabase and **permanently mark the Ticket ID as `used`**.
      - Ensure robust RLS to prevent unauthorized modifications or double-bookings.

  7.  **Modal: Session Confirmed!**

      - **Purpose:** Immediate visual confirmation of successful booking.
      - **Title:** "Session Confirmed!"
      - **Brief Message:** "Your gym session is booked for [Date] at [Time]!"
      - **Button:** "View Booking Details" (leads to the final summary screen).

  8.  **Screen: Your Booking Details**
      - **Purpose:** Provides a comprehensive summary of the confirmed booking and next steps.
      - **Title:** "Your Booking Details"
      - **Comprehensive Summary:** Includes Date, Time, Location, Booking Reference ID, and the full Ticket ID used.
      - **Important Instructions/Next Steps:** Clear guidance on arrival, check-in, and cancellation policy.
      - **Buttons:** "Add to Calendar", "View My Bookings". **Do NOT include a "Download Receipt" button.** The screen itself, along with an auto-sent email, serves as the confirmation.

### Booking System Data Model Update: Recurring Sessions & Session Occurrences

#### Motivation

To efficiently support recurring gym sessions, real-time capacity tracking, and robust admin management (without bloating the database with every possible date), HeronFit now uses a two-table model:

1. **sessions** (Recurring Template Table)

   - Stores the _template_ for a recurring session (e.g., "Monday 8am-9am, 15 slots").
   - Key fields: `id`, `day_of_week`, `start_time_of_day`, `end_time_of_day`, `category`, `capacity`, `is_active`, `notes`, `override_date` (for one-off overrides).

2. **session_occurrences** (Actual Instance Table)
   - Stores _actual_ session instances for a specific date, only when needed (e.g., when a booking is made or admin wants to track attendance/capacity for a date).
   - Key fields: `id`, `session_id` (FK to sessions), `date`, `booked_slots`, `attended_count`, `status`, `override_capacity`, `notes`, `created_at`.
   - **Unique constraint:** (`session_id`, `date`) to prevent duplicates.

#### How It Works in the App

- **User browses sessions:**
  - The app shows available sessions for a selected date by combining recurring templates (`sessions`) with any existing occurrences (`session_occurrences`) for that date.
  - If no occurrence exists, the app "virtually" shows the session as available (using the template's default capacity).
- **User books a session:**
  - If no occurrence exists for that session/date, the app creates one (with `booked_slots = 1`).
  - If an occurrence exists, it increments `booked_slots`.
- **Capacity/Attendance:**
  - Capacity is tracked per occurrence. Admin can override capacity for a specific date.
  - Attendance is tracked per occurrence (admin marks users as attended).

#### Admin Dashboard Integration

- **Admin can:**
  - Edit recurring templates (sessions).
  - View, edit, and manage occurrences (per date), including capacity, attendance, and status.
  - Override capacity for a specific date (e.g., for holidays or special events).
  - Mark users as attended (for attendance tracking).
  - Cancel or reschedule a specific occurrence.

#### Benefits

- **No table bloat:** Only actual, needed occurrences are created.
- **Full flexibility:** Admin can override, cancel, or adjust any specific date/session.
- **Easy reporting:** Track attendance, bookings, and capacity per occurrence.

#### Migration/Transition

- No need to pre-populate `session_occurrences`.
- Existing bookings can be migrated to reference the new occurrence if needed.

#### Example Table Structure

| Table               | Purpose                    | Example Row                                               |
| ------------------- | -------------------------- | --------------------------------------------------------- |
| sessions            | Recurring template         | id: 1, day_of_week: Monday, 8am-9am, 15 slots             |
| session_occurrences | Actual instance for a date | id: 101, session_id: 1, date: 2025-05-30, booked_slots: 3 |

## 12. Testing

- **Unit Tests:** Test business logic within Riverpod controllers/notifiers, services, and utility functions (`test` package). Mock dependencies (Supabase client, repositories) using packages like `mockito` or `mocktail`.
- **Widget Tests:** Test individual widgets and simple screen flows (`flutter_test` package). Verify UI elements render correctly based on state provided by mocked Riverpod providers.
- **Integration Tests:** Test critical end-to-end user flows spanning multiple screens and interacting with a real (or mocked) backend (`integration_test` package). Focus on complex interactions: Booking, Waitlists, Real-time updates, Workout saving, Login/Registration.
- **Coverage:** Aim for good test coverage, especially for core logic and critical features.

## 13. Accessibility (A11y)

- **Semantics:** Use `Semantics` widgets and properties (`label`, `hint`, `button`, etc.) to provide context for screen readers.
- **Contrast:** Ensure sufficient color contrast between text and background, adhering to WCAG guidelines. Use the theme colors defined in `HeronFitTheme`.
- **Touch Targets:** Ensure buttons, icons, and other interactive elements have minimum touch target sizes (>= 48x48 dp). Use `Padding` or `SizedBox` if needed.
- **Dynamic Text:** Test the app with larger font sizes enabled in system settings to ensure layouts adapt gracefully. Use relative font sizes from the theme.
- **Consider Diverse Users:** Incorporate recommendations for users with various disabilities where applicable.

## 14. Security

- **Input Validation:** Sanitize and validate all user input on both the client and backend (if applicable) to prevent injection attacks.
- **API Calls:** Use HTTPS for all communication with backend services (Supabase, recommendation engine).
- **Dependencies:** Keep Flutter and package dependencies updated (`flutter pub upgrade --major-versions`). Regularly check for known vulnerabilities.
- **RLS:** Rigorously enforce and test Supabase Row Level Security policies.
- **Authentication/Authorization:** Implement robust authentication using Supabase Auth. Ensure authorization checks are performed where necessary (e.g., before allowing data modification).
- **Secrets Management:** Use `.env` files via `flutter_dotenv` for sensitive keys (Supabase URL/Key). **Never commit `.env` files to version control.**

## 15. Version Control (Git) & Commit Messages

- **Branching:** Use a branching strategy (e.g., Gitflow - `main`, `develop`, `feature/`, `fix/`, `release/`).
- **Commits:** Commit frequently with clear, concise messages following the Conventional Commits format.
- **Code Reviews:** Conduct code reviews for feature branches before merging into `develop`.

### Commit Message Format (Conventional Commits)

Follow the [Conventional Commits specification](https://www.conventionalcommits.org).

**Basic Format:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Header (`<type>[optional scope]: <description>`)**

- **Type:** Must be one of:
  - `feat`: A new feature for the user.
  - `fix`: A bug fix for the user.
  - `build`: Changes affecting the build system or external dependencies (e.g., `pubspec.yaml`, `gradle`).
  - `chore`: Other changes that don't modify `src` or `test` files (e.g., updating dependencies, documentation).
  - `ci`: Changes to CI configuration files/scripts.
  - `docs`: Documentation only changes.
  - `perf`: A code change that improves performance.
  - `refactor`: A code change that neither fixes a bug nor adds a feature.
  - `revert`: Reverts a previous commit.
  - `style`: Code style changes (formatting, whitespace).
  - `test`: Adding missing tests or correcting existing tests.
- **Scope (Optional):** Noun describing the affected codebase section (e.g., `auth`, `booking`, `workout`, `profile`, `core`, `theme`, `ci`, `deps`). Use lowercase.
- **Description:** Short, imperative mood summary (e.g., "add login screen"). Use lowercase. No period at the end.

**Example Headers:**

- `feat(auth): add email verification screen`
- `fix(workout): correct total weight calculation`
- `refactor(core): simplify supabase service wrapper`
- `docs: update comprehensive ai guidelines`
- `chore(deps): update riverpod to 2.5.1`
- `style(theme): adjust primary color shade`
- `test(booking): add unit tests for booking controller`

**Body (Optional)**

- Explain **why** the change was made, providing context.
- Describe previous behavior if fixing a bug.
- Use bullet points for lists.
- Reference issue numbers (`Closes #123`, `Refs #456`).

**Footer (Optional)**

- **Breaking Changes:** Start with `BREAKING CHANGE:` followed by details.
- **Issue References:** `Closes #12`, `Refs #34, #56`.

**General Commit Guidelines:**

- **Comprehensive:** Message reflects _all_ changes in the commit.
- **Explain "Why":** Focus on motivation.
- **Imperative Mood:** "fix bug" not "fixed bug".
- **Keep Lines Short:** Aim for ~72 characters in body/footer.

## 16. Tooling

- **Version Control:** Git & GitHub.
- **IDE:** VS Code / Android Studio. Use recommended extensions (Dart, Flutter).
- **Design:** Figma (Primary source for UI/UX).
- **Backend:** Supabase (Primary App Backend), Separate Service/Functions (Recommendation Engine).
- **Project Management:** Plane (Refer for tasks and milestones).

## 17. Final Check

Before completing tasks or submitting code for review:

- Does the implementation adhere to the NFRs (Maintainability, Reusability, Modularity, Modifiability)?
- Does it follow the features-first architecture?
- Is Riverpod used correctly for state management?
- Does it meet coding standards and UI/UX guidelines?
- Is error handling robust and user-friendly?
- Are performance considerations addressed?
- Is the code adequately tested?
- Are accessibility and security requirements met?
- Does the commit message follow the Conventional Commits format?

---
