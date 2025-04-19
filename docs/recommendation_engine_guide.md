# HeronFit Recommendation Engine Development Guide

**Version:** 1.0
**Date:** April 19, 2025

## 1. Overview

This document outlines the development plan and guidelines for the HeronFit recommendation engine, a separate backend service designed to provide personalized workout and exercise suggestions to users based on their history and exercise characteristics.

This service adheres to the principles outlined in the main HeronFit Comprehensive AI Development Guidelines (Section 11), emphasizing a backend-focused approach for recommendation logic.

## 2. Architecture

- **Service Type:** Standalone Backend Service (Python with Flask/FastAPI recommended).
- **Deployment:** Containerized (Docker) deployment to a cloud platform or potentially Supabase Edge Functions _only if logic remains very simple_.
- **Communication:** Provides a RESTful API endpoint for the HeronFit Flutter application to consume.
- **Database:** Securely connects to the existing HeronFit Supabase PostgreSQL database.

## 3. Core Requirements (Based on Project Charter & Guidelines)

- Implement both **Content-Based Filtering** and **Collaborative Filtering**.
- Develop a **Hybrid Approach** combining the strengths of both methods.
- Provide recommendations for individual exercises and potentially full workout programs.
- Integrate with user profile data (goals, fitness level - if available) to enhance recommendations, especially for beginners.
- Allow for future enhancements like user feedback loops.

## 4. Technology Stack

- **Language:** Python 3.x
- **Web Framework:** Flask or FastAPI
- **Data Manipulation:** Pandas
- **Machine Learning:** Scikit-learn (for TF-IDF, Cosine Similarity, SVD, etc.)
- **Database Client:** `supabase-py`
- **Environment Variables:** `python-dotenv`

## 5. Data Requirements

The service needs secure read access to the following Supabase tables:

- `users`: User IDs, potentially profile information (goals, fitness level).
- `workouts`: User's workout sessions (linking user to workout instances).
- `workout_exercises`: Links workouts to specific exercises performed.
- `exercise_sets`: Details of sets performed for each exercise in a workout (reps, weight, duration).
- `exercises`: Master list of exercises, including properties like:
  - `id`
  - `name`
  - `muscle_group`
  - `equipment_required`
  - `type` (e.g., cardio, strength)
  - `difficulty`
  - (Ensure these properties are populated, potentially leveraging `free-exercise-db` data).

**Security:** Use the Supabase **Service Role Key** for backend access, stored securely in environment variables (`.env`). **Do not expose this key client-side.**

## 6. Implementation Steps

1.  **Project Setup:**
    - Initialize Python project (virtual environment, install dependencies).
    - Set up Flask/FastAPI application structure.
    - Configure Supabase client using environment variables.
2.  **Data Fetching Module:**
    - Create functions to securely fetch and potentially preprocess data from Supabase tables (user history, exercise details).
    - Use Pandas DataFrames for efficient manipulation.
3.  **Content-Based Filtering Module:**
    - **Feature Extraction:** Represent exercises based on their properties (e.g., using TF-IDF on text descriptions or one-hot encoding categorical features like muscle group/equipment).
    - **User Profile:** Build a profile of user preferences based on the features of exercises they've completed frequently/recently.
    - **Similarity Calculation:** Calculate similarity (e.g., cosine similarity) between unseen exercises and the user's profile.
    - **Recommendation:** Rank exercises based on similarity scores.
4.  **Collaborative Filtering Module:**
    - **User-Item Matrix:** Construct a matrix representing user interactions with exercises (e.g., frequency, duration, rating if available). Handle sparsity.
    - **Algorithm Choice:**
      - **Memory-Based:** Implement User-Based or Item-Based KNN. Calculate similarities between users or items.
      - **Model-Based:** Implement Matrix Factorization (e.g., SVD using `scikit-learn` or libraries like `surprise`).
    - **Prediction/Recommendation:** Generate recommendations based on predicted ratings or nearest neighbors.
5.  **Hybrid Approach Module:**
    - Combine results from content-based and collaborative filtering.
    - Strategies: Weighted scoring, switching (use one method to pre-filter), feature combination.
6.  **API Endpoint:**
    - Create a REST API endpoint (e.g., `POST /recommendations` or `GET /recommendations/{user_id}`).
    - Input: User ID.
    - Output: JSON list of recommended exercise IDs or workout plan IDs.
    - Handle request validation and error responses.
7.  **Testing:**
    - Implement unit tests for individual modules (data fetching, filtering logic).
    - Consider integration tests for the API endpoint.
8.  **Deployment:**
    - Containerize the application using Docker.
    - Deploy to a suitable cloud platform (e.g., Heroku, Google Cloud Run, AWS Fargate) or investigate Supabase Edge Functions if feasible.

## 7. Flutter Integration (Reminder)

- The Flutter app will:
  - Make an HTTP request to the deployed recommendation API endpoint, passing the user ID.
  - Receive a list of recommended exercise/workout IDs.
  - Fetch the full details for these IDs from Supabase using its standard client.
  - Display the recommendations in the UI.

## 8. Future Considerations

- Incorporating explicit user feedback (ratings, like/dislike).
- Handling cold-start problem (new users/new exercises).
- Re-training models periodically.
- A/B testing different algorithms.
- Recommending full workout plans.
