# MedVault App Blueprint

## Overview

MedVault is a Flutter application designed for medical students to track their study habits, review topics using spaced repetition, and manage their digital study materials. The app features a modern, glassmorphism-inspired UI with a focus on a clean and intuitive user experience.

## Style, Design, and Features

### Version 1.0

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

**Request:** Run the project.

**Steps:**

1.  **Update `lib/main.dart`:** Replace the content of the main Dart file with the new UI and logic.
2.  **Add Dependencies:** Add `hive_flutter` and `flutter_riverpod` to `pubspec.yaml`.
3.  **Fix Analysis Issues:** Correct errors in `test/widget_test.dart` and `lib/main.dart`.
4.  **Run the App:** Execute `flutter run` to launch the application.