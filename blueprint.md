# MedVault App Blueprint

## Overview

MedVault is a Flutter application designed for medical students to track their study habits, review topics using spaced repetition, and manage their digital study materials. The app features a modern, glassmorphism-inspired UI with a focus on a clean and intuitive user experience.

## Style, Design, and Features

### Version 1.0

*   **Application ID:** `com.rethink.app`
*   **UI/UX:**
    *   **Theme:** Dark theme with a custom color palette (teal, purple, amber).
    *   **Glassmorphism:** Used for cards and other UI elements to create a sense of depth.
    *   **Navigation:** Bottom navigation bar with three main screens: Dashboard, Review, and Vault.
    *   **Typography:** Roboto font family.
*   **Screens:**
    *   **Dashboard:** Displays daily habits, study statistics, and a list of topics to revise.
    *   **Review:** A spaced repetition screen with flashcards for reviewing topics.
    *   **Vault:** A file manager for organizing and accessing study materials.
*   **State Management:** Riverpod for managing application state.
*   **Database:** Hive for local data storage.

## Current Plan

**Request:** Change default id to com.rethink.app.

**Steps:**

1.  **Update `android/app/build.gradle.kts`:** Changed `namespace` and `applicationId` to `com.rethink.app`.
2.  **Update Package Structure:** Updated `MainActivity.kt` package name and moved it to `android/app/src/main/kotlin/com/rethink/app/`.
3.  **Stability Checks:** Run `flutter analyze` and `flutter test`.
