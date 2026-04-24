# MedVault App

MedVault is an offline-first Flutter app for medical students to manage spaced-repetition study topics, track study habits, and organize local study files.

## Architecture Overview

The app follows a lightweight feature-layered architecture:

- **Views (`lib/views`)**: Flutter UI screens and widgets.
- **ViewModels (`lib/viewmodels`)**: Riverpod notifiers containing business logic and state transitions.
- **Models (`lib/models`)**: Domain entities and Hive adapters for persistence.
- **Services (`lib/Services`)**: Cross-cutting utilities such as backups.
- **Theme (`lib/theme`)**: Shared color system and theme primitives.

Core stack:

- **Flutter** for UI
- **flutter_riverpod** for state management
- **Hive + hive_flutter** for local persistence
- **file_picker + open_filex** for vault file import/open

## App Flow

### 1) App bootstrap (`lib/main.dart`)

On startup, the app:

1. Initializes Hive.
2. Registers adapters (`Topic`, `Habit`, `VaultFile`, `RevisionAttachment`, `Color`).
3. Opens boxes (`topicsBox`, `habitsBox`, `vaultBox`, `attachmentsBox`, `metaBox`).
4. Seeds default habits if needed.
5. Starts the app inside `ProviderScope`.

The first route is selected using `metaBox['onboarding_complete']`:

- `false`/unset → `OnboardingScreen`
- `true` → `MainShell`

### 2) Main navigation

`MainShell` uses a bottom navigation layout with 3 sections:

- **Today**: Dashboard with due/upcoming topics + daily habits.
- **Review**: Review queue for due topics.
- **Vault**: Local file manager for study materials.

## Feature Modules

### Topics & Spaced Repetition

- `TopicNotifier` manages topic CRUD, sorting, due/upcoming filters, and review completion.
- Review scheduling uses fixed intervals: **1, 5, 14, 28 days**.
- Completing a review can append cycle notes and advances the next review date.

Primary files:

- `lib/models/topic_model.dart`
- `lib/viewmodels/topic_provider.dart`
- `lib/views/review_queue_screen.dart`
- `lib/views/review_screen.dart`
- `lib/views/topic_detail_screen.dart`

### Habits

- `HabitNotifier` manages habit toggles, creation/deletion, and daily reset logic.
- Daily reset metadata is persisted in `metaBox` via `__last_reset__`.

Primary files:

- `lib/models/habit_model.dart`
- `lib/viewmodels/habit_provider.dart`

### Vault

- `VaultNotifier` manages persisted file metadata.
- `MedVaultScreen` supports category filtering, file selection with `file_picker`, and launch via `open_filex`.
- Missing-file handling allows quick removal from vault state.

Primary files:

- `lib/models/vault_file_model.dart`
- `lib/viewmodels/vault_provider.dart`
- `lib/views/medvault_screen.dart`

### Onboarding

- Multi-page onboarding captures user name and sets onboarding completion in `metaBox`.

Primary file:

- `lib/views/onboarding_screen.dart`

## Data Persistence

Hive boxes used:

- `topicsBox` → `Topic`
- `habitsBox` → `Habit`
- `vaultBox` → `VaultFile`
- `attachmentsBox` → `RevisionAttachment`
- `metaBox` → app/user metadata (onboarding flag, username, reset key)

## Backup

`BackupService.autoBackup()` serializes topics, habits, and vault records to JSON and writes:

- `<app-documents>/rethink_backup.json`

File:

- `lib/Services/backup_service.dart`

## Repository Structure

```text
lib/
  main.dart
  models/
  viewmodels/
  views/
  theme/
  Services/
android/
web/
```

## Run Locally

```bash
flutter pub get
flutter run
```

## Notes

- This project is designed for local-first usage.
- Current visual language is dark-theme + glassmorphism-inspired UI.
