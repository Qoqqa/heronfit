---
trigger: always_on
---

# HeronFit: AI Development Guidelines (Essentials)

**Document Version:** 2.1 (Condensed)
**Date:** May 25, 2025

## 1. Introduction & Project Core

This document provides essential guidelines for **AI-assisted development** of the **HeronFit Flutter mobile app** for the University of Makati gym.
**Goal:** Streamline gym operations via booking, real-time occupancy, and workout tracking.
**Tech Stack:** Flutter, Dart, **Riverpod**, **Supabase**.
**Full Context:** For all detailed requirements, flows (especially booking), and specific feature breakdowns, refer to `docs/heronfit_app_prd.md`.

## 2. Core Principles

Prioritize:
* **Maintainability:** Clean, documented, modular code.
* **Reusability:** Composable widgets/functions.
* **Modularity:** Features-first structure, low coupling.
* **Modifiability:** Scalable architecture for future changes.

## 3. Architecture & Structure

Follow a **features-first** project structure: `lib/core/` (cross-cutting), `lib/widgets/` (generic UI), `lib/features/<feature_name>/` (controllers, models, views, widgets, services). See `docs/heronfit_app_prd.md` for full structure.

## 4. State Management (Riverpod)

* **Standardize on Riverpod** for all app state. Avoid `setState` for app state.
* Define providers in `controllers/` within features.
* Use `FutureProvider`/`StreamProvider` for async operations; leverage `AsyncValue`.
* Ensure **immutability** for all state.
* **Crucial:** **DO NOT use `build_runner` or any code generation tools** (e.g., `freezed`, `json_serializable`, Riverpod codegen). Implement `copyWith`, `fromJson`/`toJson` manually for data models.

## 5. Coding Standards & UI/UX

* **Dart Style Guide** and `analysis_options.yaml` lint rules.
* **Naming:** `UpperCamelCase` (classes), `lowerCamelCase` (variables/functions), `lowercase_with_underscores` (files).
* **`final` and `const`** usage encouraged.
* **Null Safety:** Full utilization.
* **UI/UX:** Adhere strictly to **Figma design system**. Use `lib/core/theme/theme.dart`. Implement clear loading/error states.

## 6. Backend Integration (Supabase)

* Use `Supabase.instance.client`.
* Implement authentication via Supabase Auth.
* Interact with PostgreSQL via `supabase_flutter`. Define data models.
* Utilize **Supabase Realtime** for live updates (e.g., gym occupancy).
* Implement and test **Row Level Security (RLS)** rigorously.
* Use `.env` for secrets; **NEVER commit `.env` files.**

## 7. Error Handling & Performance

* **Error Handling:** Robust `try-catch` for async calls. Display user-friendly error messages (dialogs, SnackBars).
* **Performance:** Minimize widget rebuilds (`const`, judicious Riverpod usage). Implement pagination for lists. Use `cached_network_image`. Avoid blocking UI thread. Profile with Flutter DevTools.

## 8. Feature Implementation Focus

Refer to `docs/heronfit_app_prd.md` for complete details, especially the **refined booking system flow**.

* **Booking System:** Follow the **streamlined, single-session ticket flow** precisely:
    1.  **Activate Your Gym Pass:** Mandatory Ticket ID validation (existence, active, user-linked).
    2.  **Select Your Session:** Calendar, time slots, capacity, **"Join Waitlist"** for full slots.
    3.  **Review Your Booking:** Final confirmation.
    4.  **Booking Finalization:** Backend updates.
    5.  **Session Confirmed!** (Modal).
    6.  **Your Booking Details:** Comprehensive summary; **no "Download Receipt" button.**
    * Location: **University of Makati HPSB 11th Floor Gym**.
    * **Waitlist is mandatory.**

* **Other Key Features:** Workout Tracking Enhancements (exercise DB, GIFs, equipment filtering), Recommendation System (backend service integration), Profile (My Bookings, Workout History).

## 9. Testing & Security

* **Testing:** Unit, Widget, and Integration tests. Aim for good coverage.
* **Security:** Input validation, HTTPS for API calls, keep dependencies updated, strict RLS, secure secret management.

## 10. Version Control & Tooling

* **Git:** Gitflow branching.
* **Commits:** Frequent, clear, concise messages following [Conventional Commits](https://www.conventionalcommits.org).
* **Tools:** Git/GitHub, VS Code/Android Studio, Figma, Supabase, Plane.
