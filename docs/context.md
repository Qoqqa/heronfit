# HeronFit: AI Development Guidance (Post-60% Completion)

**Document Version:** 1.0
**Date:** April 11, 2025
**Based on Project Charter:** Revision 5 (Dated March 23, 2025)

## 1. Introduction

This document provides detailed guidance for the continued development of the HeronFit mobile application, specifically targeting the remaining 40% of the project. It assumes familiarity with the project charter and leverages its contents to outline technical specifications, best practices, and priorities. The goal is to ensure the final product aligns with the project vision, meets user needs, and adheres to high-quality development standards suitable for AI-assisted development.

**Current Status:** The project is approximately 60% complete. Core infrastructure (Flutter setup, Supabase integration, basic UI shells) is likely in place. Focus should now shift to completing feature implementation, refining UI/UX, integrating algorithms, robust testing, and incorporating feedback/recommendations.

## 2. Project Overview Recap

- **Goal:** To streamline the University of Makati gym operations and enhance the user experience via a mobile app.
- **Target Audience:** University of Makati students, faculty, and staff.
- **Core Value Proposition:** Provide a convenient digital platform for gym session booking (using university tickets), real-time occupancy tracking, workout logging, and progress monitoring.
- **Key Modules:** User Module (Onboarding, Auth, Home, Profile, Booking, Workout, Progress) and Admin Module (Dashboard, User Management, Booking Management, Session Management, Announcements, Analytics).

## 3. Technical Architecture & Stack

- **Frontend Framework:** Flutter (Cross-platform for iOS & Android)
- **UI Development Tool:** FlutterFlow (Leverage pre-built components, custom functions/actions, and component library extensively)
- **Backend-as-a-Service (BaaS):** Supabase (Authentication, Real-time PostgreSQL Database, potentially Edge Functions)
- **Database:** PostgreSQL (Managed via Supabase)
- **Recommendation Algorithms:** Python (Content-Based & Collaborative Filtering - Integration approach needs definition, e.g., via Supabase Edge Functions or a separate microservice)
- **Design:** Figma (Primary source for UI/UX specifications)
- **Version Control:** Git (Hosted on GitHub)
- **Project Management:** Plane
- **External Data:** yuhonas/free-exercise-db (Ensure proper attribution and integration strategy)

## 4. Development Best Practices

Adherence to these practices is crucial for maintainability, scalability, and performance.

### 4.1. Flutter Specific

- **State Management:** Standardize on a single state management solution (e.g., Provider, Riverpod - as mentioned in charter tools). Ensure clear separation of UI, business logic, and data layers. Avoid placing business logic directly in widgets.
- **Code Structure:** Maintain a consistent and scalable project structure (e.g., Feature-first or Layer-first). Group related files (screens, view models/controllers, services) together.
- **UI Consistency:**
  - Strictly adhere to the Figma design system (components, styles, spacing, typography).
  - Maximize reuse of FlutterFlow components and custom widgets created within FlutterFlow or manually.
  - Ensure responsiveness across different screen sizes and orientations.
- **Asynchronous Operations:** Use `async/await` with proper error handling (`try-catch`) for all network requests, database operations, and other long-running tasks. Provide user feedback (e.g., loading indicators, skeleton screens).
- **Null Safety:** Leverage Dart's sound null safety features fully. Avoid unnecessary null checks (`!`) and handle potential null values gracefully.
- **Packages:** Use established packages from `pub.dev` (as listed in the charter) but vet them for maintenance status and compatibility. Keep dependencies updated.
- **Performance:**
  - Optimize widget builds (use `const` constructors where possible, minimize `setState` calls, use appropriate state management).
  - Profile the app to identify performance bottlenecks (CPU, memory, rendering).
  - Optimize image loading and caching.
  - Use efficient data structures and algorithms.
- **Testing:** Implement unit tests for business logic, widget tests for UI components, and integration tests for critical user flows (e.g., booking, login).

### 4.2. Fitness App Specific

- **Data Privacy & Security:**
  - Securely handle user data (personal info, health data like weight, goals).
  - Implement robust authentication and authorization using Supabase Auth.
  - Use Supabase Row Level Security (RLS) policies to ensure users can only access their own data.
  - Be mindful of data minimization principles.
- **User Engagement:**
  - Implement reliable push notifications (via Supabase or a dedicated service) for reminders, waitlist updates, and announcements. Make notifications configurable by the user.
  - Ensure progress tracking is visually appealing and motivating (graphs, PBs, statistics).
  - Make workout logging intuitive and quick.
- **Accessibility (A11y):**
  - Ensure sufficient color contrast.
  - Use semantic widgets and provide labels for screen readers (Semantics widget).
  - Ensure interactive elements have adequate touch target sizes.
  - Incorporate recommendations for diverse users/disabilities.
- **Data Synchronization:** Leverage Supabase's real-time capabilities for features like gym occupancy updates. Ensure reliable offline data handling if required (though not explicitly mentioned as a requirement).

### 4.3. General Practices

- **Version Control (Git):** Use meaningful commit messages, utilize branching strategies (e.g., Gitflow), and conduct code reviews.
- **Code Quality:** Write clean, readable, and well-commented code. Adhere to Dart & Flutter style guides. Use linters.
- **Error Handling:** Implement comprehensive error handling and logging (consider integrating a remote logging service). Display user-friendly error messages.
- **API Integration:** Define clear contracts for any APIs (including Supabase functions if used). Handle different HTTP response codes appropriately.
- **Configuration Management:** Manage environment-specific configurations (API keys, backend URLs) securely (e.g., using `.env` files and `flutter_dotenv`).

## 5. Feature Implementation Guidance (Remaining 40%)

Prioritize based on the project milestones and address the recommendations from the charter.

### 5.1. High Priority / Core Functionality Completion:

- **Booking System Refinements:**
  - **Ticket ID Validation:** Implement the logic for same-day ticket ID validation for advanced bookings. Clarify if this is manual (Admin) or user-driven. Implement the Admin approval/decline flow based on validation.
  - **Waitlist Management:** Ensure robust logic for joining waitlists and automated notifications (push/in-app) when spots become available. Implement Admin controls for waitlist monitoring and promotion.
  - **Real-time Occupancy:** Ensure Supabase real-time subscriptions are correctly implemented to display live gym occupancy. Define how occupancy is updated (Admin input? Sensor integration - unlikely based on charter?).
  - **Recommendation:** Implement "Restrict gym session bookings to university students only" (requires validation against university ID/email format during registration/booking).
  - **Recommendation:** Implement "Introduce an option for users to request assistance from a personal trainer during booking" (requires UI element and potentially a notification/request flow to Admins/Trainers).
- **Workout Tracking Enhancements:**
  - **Exercise Library Integration:** Fully integrate the `yuhonas/free-exercise-db`. Ensure efficient searching/filtering.
  - **Recommendation:** Replace static images with GIFs for exercise demonstrations. Source or create appropriate GIFs.
  - **Recommendation:** Add filtering for exercises based on available university gym equipment. This requires mapping exercises to equipment and adding equipment data to the database/app.
  - **Customization & Programs:** Complete the "Customize Your Workout" and "Recommended/All Programs" sections.
- **Recommendation Algorithms (Content & Collaborative Filtering):**
  - **Integration:** Define the integration strategy. Options:
    - **Supabase Edge Functions (Deno/TypeScript):** Port Python logic or use JS libraries. Good for tight integration.
    - **Separate Python Microservice (e.g., Flask/FastAPI):** Requires separate hosting and API communication. More flexible for complex Python libraries.
  - **Data:** Ensure necessary user data (goals, history, ratings if any) and exercise data are available to the algorithms.
  - **Triggering:** Decide when recommendations are generated (on-demand, background task?).
  - **Recommendation:** Improve the algorithm for recommending beginner workouts based on fitness levels (requires capturing/using fitness level data).
- **Admin Module Completion:**
  - **Analytics & Reports:** Implement report generation for usage, peak times, demographics, and engagement metrics using Supabase data. Visualize data effectively.
  - **Session Attendance:** Implement tracking mechanism (Admin manual check-in? User self-check-in?).
  - **Targeted Alerts:** Implement logic to send notifications to specific user segments based on criteria (e.g., booked session users, waitlisted users).

### 5.2. UI/UX Refinement & Recommendations:

- **Recommendation:** Refine the app's design to address inconsistencies (based on Figma). Perform a thorough UI audit against the design system.
- **Recommendation:** Provide clearer labels, instructions, and improve the onboarding flow. Review all user-facing text for clarity.
- **Recommendation:** Consider accessibility features for diverse users. Conduct accessibility testing.
- Implement all profile sections (My Bookings categorization, Workout History details, Notifications settings, Contact Us, Privacy Policy).

### 5.3. Testing & Quality Assurance:

- Execute the testing plan outlined in the milestones rigorously: Functional, Usability, Cross-Platform Compatibility, Performance.
- Focus testing on complex interactions: Booking logic, waitlists, real-time updates, algorithm outputs.

### 5.4. Security & Maintainability:

- **Recommendation:** Strengthen security mechanisms against common attacks (Input validation, secure API calls, dependency vulnerability checks). Perform basic security testing.
- **Recommendation:** Develop features/logging to assess component failure or deficiencies (robust error logging, health checks if applicable).
- **Recommendation:** Ensure the architecture supports modifications and scalability. Refactor code where necessary for clarity and maintainability.

## 6. Backend Integration (Supabase)

- **Data Models:** Finalize PostgreSQL table schemas in Supabase, ensuring appropriate relationships, constraints, and indexing for performance.
- **Row Level Security (RLS):** Implement comprehensive RLS policies for all tables containing user-specific or sensitive data. Test policies thoroughly.
- **Real-time:** Configure real-time subscriptions for tables requiring live updates (e.g., gym session occupancy, booking status).
- **Authentication:** Utilize Supabase Auth features (email/password, email verification, password recovery).
- **Edge Functions (If used for algorithms):** Define clear API endpoints, manage dependencies, and ensure secure invocation from the Flutter app.

## 7. Deployment

- Prepare build configurations for Android (Google Play Store) and iOS (App Store).
- Set up deployment pipelines (e.g., using GitHub Actions) for automated builds and releases.
- Ensure all necessary app store metadata, screenshots, and privacy policy links are ready.
- Deploy the Admin Portal (if it's a separate web app) ensuring proper hosting and domain configuration.

## 8. Future Considerations

While focusing on the current scope, keep the potential future expansions (fitness challenges, social integrations) in mind to avoid architectural decisions that might hinder future development.

## 9. Conclusion

This document provides a roadmap for completing the HeronFit app. By focusing on the remaining features, incorporating user feedback and recommendations, adhering to best practices, and leveraging the chosen tech stack effectively, the development team can deliver a high-quality, valuable application for the University of Makati community. Consistent communication, rigorous testing, and adherence to the project plan are key to success.
