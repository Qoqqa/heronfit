# HeronFit Admin Dashboard: Product Requirements Document

**Document Version:** 1.1
**Date:** May 24, 2025

## 1. Introduction

This document outlines the product requirements for the HeronFit Admin Dashboard. This web-based application will serve as the primary tool for University of Makati gym administrators and staff to manage core gym operations, particularly user accounts, bookings, session occupancy, announcements, and to gain insights into app usage. The dashboard will interact with the same Supabase backend used by the HeronFit mobile application.

**Assumption:** Familiarity with the HeronFit mobile application's features, the existing Supabase backend structure, and the overall project goals as detailed in the `comprehensive_ai_guidelines.md`.

## 2. Project Goals

- **Streamline Core Gym Administration:** Provide administrators with efficient tools to manage daily booking operations, user access, and gym sessions.
- **Enhance Control & Oversight:** Offer comprehensive control over user management, bookings, and real-time gym occupancy.
- **Enable Data-Driven Decisions:** Present key analytics related to bookings, user activity, and session attendance.
- **Maintain System Integrity:** Ensure secure access and management of the HeronFit ecosystem.
- **Seamless Integration:** Work flawlessly with the existing Supabase backend and complement the user-facing mobile application.

## 3. Target Users

- University of Makati Gym Administrators
- Authorized Gym Staff

## 4. Core Principles & Non-Functional Requirements (NFRs)

- **Usability:** Intuitive, clear, and efficient user interface that requires minimal training.
- **Security:** Robust authentication and authorization mechanisms to protect sensitive data and administrative functions. Adherence to Supabase RLS.
- **Performance:** Fast load times and responsive interactions, especially when handling large datasets (e.g., user lists, booking history).
- **Maintainability:** Clean, well-structured, and documented codebase for ease of updates and future development.
- **Reliability:** Stable and consistent operation, with graceful error handling.
- **Scalability:** Architecture should support potential growth in users, data, and features.

## 5. Tech Stack & Architecture

- **Frontend Framework:** Next.js (React)
- **Programming Language:** TypeScript (for type safety and improved developer experience)
- **Backend:** Supabase (leveraging existing PostgreSQL database, Authentication, Realtime features)
- **Styling:**
  - **Recommended:** Tailwind CSS for utility-first styling and rapid UI development.
  - **Alternative:** A comprehensive React component library like Material UI (MUI) or Ant Design for pre-built components.
- **State Management (Client-side):**
  - React Context API for simple global state.
  - Zustand or Jotai for more complex client-side state management needs.
- **Data Fetching & Caching:**
  - SWR or React Query (TanStack Query) for efficient data fetching, caching, mutations, and synchronization with Supabase.
- **Forms:** React Hook Form for performant and flexible form handling and validation.
- **Deployment:** Vercel (recommended for Next.js applications) or a similar modern hosting platform.
- **Project Structure (Illustrative Next.js App Router Structure):**
  ```
  heronfit-admin/
  ├── app/
  │   ├── (auth)/             # Authentication pages (login)
  │   │   └── login/
  │   │       └── page.tsx
  │   ├── (dashboard)/        # Protected admin routes
  │   │   ├── layout.tsx      # Dashboard layout (sidebar, navbar)
  │   │   ├── dashboard/      # Overview page
  │   │   │   └── page.tsx
  │   │   ├── users/
  │   │   │   └── page.tsx    # User management
  │   │   ├── bookings/
  │   │   │   └── page.tsx    # Booking management
  │   │   ├── sessions/       # Session (Gym Occupancy) management
  │   │   │   └── page.tsx
  │   │   ├── announcements/
  │   │   │   └── page.tsx
  │   │   └── analytics/
  │   │       └── page.tsx
  │   └── global.css
  ├── components/
  │   ├── ui/                 # Reusable UI components (buttons, inputs, etc.)
  │   └── layout/             # Layout components (Sidebar, Navbar)
  ├── lib/                    # Utility functions, Supabase client setup, API helpers
  │   └── supabaseClient.ts
  ├── public/                 # Static assets
  ├── styles/                 # Global styles (if not using Tailwind exclusively in components)
  ├── next.config.js
  ├── tsconfig.json
  └── package.json
  ```

## 6. Key Features & Functionalities

### 6.1. Dashboard Overview

- **Summary Statistics:** Display key metrics at a glance (e.g., active users, pending bookings, current gym occupancy, total confirmed bookings today).
- **Quick Actions:** Links to User Management, Booking Management, Session Management, and Announcements.
- **Recent Booking Activities:** A feed of recent booking confirmations or cancellations.

### 6.2. User Management

- **View Users:** List all registered users (students, faculty, staff) with pagination, search, and filtering capabilities (e.g., by user type, account status - active/inactive).
- **User Details:** View essential details for a selected user (profile information, booking history summary).
- **Account Actions:**
  - Activate/Deactivate user accounts.
  - (Potentially) Edit user type if manual override is needed.

### 6.3. Booking Management

- **View Bookings:** List all gym session bookings with pagination, search, and filtering (e.g., by date, user, status - pending, confirmed, cancelled, completed, waitlisted).
- **Booking Details:** View full details of a specific booking (user info, session time, status, booking ID).
- **Booking Actions:**
  - **Approve/Decline:** For bookings requiring admin approval (if this workflow is implemented).
  - **Cancel Bookings:** Admin ability to cancel bookings with an optional reason.
- **Waitlist Management:**
  - View users on waitlists for fully booked sessions.
  - (Potentially) Manually confirm a user from the waitlist if a slot opens.
- **Ticket ID Validation:** Interface or tool to quickly validate same-day booking ticket IDs presented by users at the gym.

### 6.4. Session Management (Gym Occupancy Control)

- **Real-time Occupancy View:** Display the current gym occupancy count (updated via mobile app check-ins/outs or manual admin input).
- **Manual Occupancy Update:** Allow admins to manually increment/decrement the current gym occupancy count.
- **Set Max Occupancy:** Configure the maximum allowable gym capacity.
- **Session Status:** (Optional) View or manage status of specific time slots (e.g., open, full, closed for maintenance).

### 6.5. Announcements (Notifications & Alerts Management)

- **Create Announcement:** Interface for admins to compose and send announcements/alerts.
  - Target audience: All users, specific user groups (e.g., all students).
  - Type: General info, urgent alert (e.g., gym closure).
- **View Sent Announcements:** A log or list of previously sent announcements with details (date, content, target).
- **Schedule Announcements:** (Optional) Ability to schedule an announcement for a future date/time.

### 6.6. Analytics & Reporting (Core Focus)

- **Booking Analytics:**
  - Track number of bookings over time (daily, weekly, monthly).
  - Peak booking hours/days.
  - Cancellation rates and reasons (if captured).
  - Waitlist conversion rates (if applicable).
- **Session Attendance:**
  - Track actual check-ins vs. confirmed bookings.
  - No-show rates.
- **User Activity (Related to Bookings):**
  - Number of active users making bookings.
  - Frequency of bookings per user.
- **Data Visualization:** Simple charts and graphs for the above metrics (e.g., line charts for trends, bar charts for comparisons).

### 6.7. Admin Account Management & Security (Simplified)

- **Admin Login:** Secure login page for administrators.
- **Admin Profile:** Manage admin user profiles (e.g., password changes).

## 7. UI/UX Guidelines

- **Clarity & Simplicity:** Prioritize ease of use. Information should be presented clearly and actions should be intuitive.
- **Efficiency:** Design workflows to minimize clicks and data entry for common tasks.
- **Consistency:** Maintain a consistent design language (layout, typography, components, iconography) throughout the dashboard.
- **Responsiveness:** Ensure the dashboard is usable on various screen sizes, primarily desktop and tablet.
- **Feedback:** Provide clear visual feedback for actions (e.g., loading states, success/error messages).
- **Accessibility (A11y):** Adhere to basic web accessibility standards (e.g., keyboard navigation, sufficient color contrast, ARIA attributes where necessary).

### 7.1. Branding and Theming

- **Color Palette:**
  - Text: `#050316`
  - Background: `#fbfbfe`
  - Primary: `#2f27ce`
  - Secondary: `#dddbff`
  - Accent: `#443dff`
- **Typography:**
  - Headers: Clash Display
  - Body Text: Poppins
- **Iconography:**
  - Icon Set: Solar Icons (ensure a consistent style, e.g., Line, Bold, or Duotone, is chosen and used throughout)

## 8. Backend Integration (Supabase)

- **Supabase Client:** Utilize the `supabase-js` V2 library for all interactions with the Supabase backend. Initialize and manage the client appropriately within the Next.js application (e.g., in `lib/supabaseClient.ts`).
- **Admin Authentication:**
  - Implement a separate login flow for admin users. This might involve:
    - A dedicated admin user table or a role/claim on the existing `auth.users` table.
    - Enforcing RLS policies to ensure only authenticated admins can access/modify data via the dashboard.
- **Data Operations:** Perform CRUD operations on relevant Supabase tables (e.g., `users`, `bookings`, `exercises`, `workout_programs`, `gym_occupancy`).
- **RLS Policies:** Define and rigorously test Row Level Security policies in Supabase to ensure admins have the correct permissions for managing users, bookings, and gym sessions. Admin roles should have broader access than regular users but still be appropriately restricted to their designated functions.
- **API Routes (Next.js):** Use Next.js API routes for any server-side logic that shouldn't be exposed directly to the client, or for operations requiring elevated privileges (though Supabase RLS should be the primary security layer).
- **Real-time Updates:** (Optional) Leverage Supabase Realtime for features like live occupancy updates or new booking notifications on the admin dashboard, if beneficial.

## 9. Error Handling

- **User-Friendly Messages:** Display clear, concise, and actionable error messages to admin users. Avoid showing raw technical errors.
- **Graceful Degradation:** Ensure the application handles errors gracefully without crashing.
- **Logging:**
  - Implement client-side logging for UI errors.
  - Utilize Next.js API route logging for server-side issues.
  - Consider integrating a remote logging service (e.g., Sentry, Logtail) for production monitoring.
- **Input Validation:** Implement robust input validation on both client-side (forms) and server-side (API routes, if used) before sending data to Supabase.

## 10. Performance Optimization

- **Efficient Data Fetching:**
  - Use pagination for long lists.
  - Fetch only necessary data for each view.
  - Leverage SWR/React Query for caching and reducing redundant requests.
- **Code Splitting:** Next.js handles this automatically by page, but be mindful of large component imports.
- **Image Optimization:** Use Next.js Image component (`next/image`) for optimized image loading.
- **Memoization:** Use `React.memo` for components and `useMemo`/`useCallback` for functions/values where appropriate to prevent unnecessary re-renders.
- **Bundle Size Analysis:** Periodically analyze bundle size to identify and optimize large dependencies.

## 11. Security

- **Authentication:** Secure admin authentication using Supabase Auth. Enforce strong password policies. Consider Multi-Factor Authentication (MFA) if Supabase/project supports it easily for admins.
- **Authorization:** Strictly enforce authorization using Supabase RLS based on admin roles/claims. Ensure admins can only perform actions and access data they are permitted to.
- **Input Sanitization & Validation:** Protect against XSS and other injection attacks by validating all inputs.
- **CSRF Protection:** Next.js has some built-in CSRF protection, but be aware of best practices.
- **HTTPS:** Ensure all communication is over HTTPS (handled by Vercel/hosting).
- **Dependency Management:** Keep all dependencies (Next.js, React, Supabase client, UI libraries, etc.) up-to-date and regularly scan for vulnerabilities.
- **Environment Variables:** Store all sensitive keys (Supabase URL, Anon Key, Service Role Key if used carefully on server-side) in environment variables (`.env.local`). Do not commit these to version control. The `NEXT_PUBLIC_` prefix is needed for client-side accessible env vars.

## 12. Testing

- **Unit Tests (Jest/React Testing Library):** Test individual components, utility functions, and hooks. Mock Supabase client interactions.
- **Integration Tests (React Testing Library):** Test interactions between multiple components and page-level functionality.
- **End-to-End Tests (Cypress/Playwright):** Test critical user flows (e.g., login, managing bookings, updating content).
- **API Route Tests:** If using Next.js API routes extensively, test them independently.
- **Coverage:** Aim for good test coverage, especially for core administrative functions and security-sensitive areas.

## 13. Deployment

- **Platform:** Vercel is highly recommended for Next.js applications due to its seamless integration and DX.
- **Environments:** Set up distinct environments (e.g., development, staging, production) with separate Supabase projects or configurations if feasible.
- **Environment Variables:** Configure environment variables for each environment on the hosting platform.
- **Build Process:** Utilize Next.js build optimizations.
- **Monitoring:** Set up basic uptime and performance monitoring.

## 14. Future Considerations (Optional)

- **Advanced Content Management (Exercises, Workout Programs).**
- **Detailed Audit Logs for all admin actions.**
- **Advanced Analytics & Custom Reporting Engine.**
- **Direct Communication Tools (Chat with users).**
- **Integration with other University Systems.**
- **Mobile-responsive Admin Interface (for on-the-go admin tasks).**
- **Theme Customization (Light/Dark mode).**
- **Role-based access control for different types of admin staff.**

This PRD provides a foundational guide for the development of the HeronFit Admin Dashboard, focusing on core gym management functionalities. It should be treated as a living document and updated as the project evolves.
