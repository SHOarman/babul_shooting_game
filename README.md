# 🎮 Babul Shooting Game (Bubble Shooter)

An engaging, arcade-style Bubble Shooter game built with **Flutter**, featuring **Clean Architecture**, **GetX State Management**, **Firebase Authentication**, **Cloud Firestore Real-Time Database**, and **Offline-First Persistence**.

---

## 📥 APK & Screenshots Download
You can download the compiled APK file and view gameplay screenshots directly from Google Drive:
👉 **[Google Drive - Screenshots & APK Download](https://drive.google.com/drive/folders/1GYxdBcUmobduntBMxKb3wDcPkg4d-Qv7?usp=sharing)**

---

## 🛠️ Tech Stack & Requirements

| Component | Version / Specification |
| :--- | :--- |
| **Framework** | Flutter `3.38.1` (Channel stable) |
| **Dart SDK** | `^3.10.0` |
| **State Management & Routing** | GetX `^4.7.3` |
| **Authentication** | Firebase Auth `^7.0.1` + Google Sign-In `^6.2.2` |
| **Cloud Database** | Cloud Firestore `^7.1.0` |
| **Local Storage** | SharedPreferences `^2.2.2` |
| **Audio Engine** | Audioplayers `^6.1.0` |
| **Email Service** | Mailer `^7.2.0` (SMTP OTP) |
| **Target Platforms** | Android (minSdk 21+, targetSdk 34+), iOS |
| **Java JDK** | OpenJDK 17 |

---

## ✨ Key Features (A to Z)

### 1. 🔐 Authentication & Security
- **Email & Password Registration:** Real account registration backed by Firebase Auth.
- **Email OTP Verification:** Automated 6-digit verification code sent directly to user's real email inbox using SMTP.
- **Google Sign-In:** 1-tap fast login using Google Play Services OAuth.
- **Forgot Password / Reset:** Direct Firebase password reset link sent via email.
- **Session Persistence:** Remembers user logins automatically so users don't have to re-enter credentials every time.

### 2. 🎯 Gameplay Mechanics
- **Physics-Based Aiming Line:** Custom painter (`AimLinePainter`) draws dynamic bounce trajectories showing real reflection off walls.
- **Honeycomb Hexagonal Grid:** Classic staggered hexagonal bubble grid (`BubbleHoneycombGrid`) for realistic bubble stacking.
- **Match-3 & Mega Combo System:** Depth-First / BFS clustering algorithm that detects and pops 3 or more matching bubbles, with bonus points for 4x+ combos.
- **Floating Island / Orphan Bubble Detachment:** Bubbles disconnected from the top anchor row automatically drop and award bonus points.
- **Adjustable Bubble Speed:** Smooth animation at 20.0 speed with 8ms frame intervals for snappy, responsive arcade shooting.
- **Danger Line Warning:** Level is failed if bubbles cross the lower danger line.
- **Move Limit Strategy:** Levels have strategic move limits encouraging skillful trick shots.

### 3. ☁️ Cloud Sync & Data Persistence
- **Offline-First Storage:** Instant local reads/writes using `SharedPreferences` so game never lags on poor internet.
- **Cloud Firestore Backup:** High scores, stars earned (1-3 stars), and unlocked levels are automatically synced to `users/{uid}` in Cloud Firestore.
- **Smart Two-Way Sync:** Automatically downloads and merges the highest stars and unlocked levels across logins and different devices.
- **Instant Win Dialog:** UI never waits on network promises; Level Complete dialog triggers in 0ms while Firestore saves smoothly in the background.

### 4. 👤 Profile & Dashboard
- **Profile Header:** Displays Player Name, Avatar, Email, and Tap-to-Copy Player ID.
- **Stats Dashboard:** Live stats showing total stars, highest unlocked level, and overall progress percentage.
- **Nickname Editor:** In-app nickname update dialog with instant cloud update.
- **Settings & Audio Controls:** Switch toggle for sound effects (pop, bounce, win, combo, game over).

---

## 📂 Project Architecture (Clean Architecture)

The project strictly follows **Clean Architecture** principles separated into distinct feature layers:

```
f:\popupgame\
│
├── android/                        # Android native configurations & Gradle scripts
├── assets/                         # Audio sound files (.mp3), images, and fonts
│   ├── audio/                      # Game sound effects (pop, win, bounce, lose)
│   └── images/                     # Game graphics and icons
│
├── lib/
│   ├── main.dart                   # Application entry point with InitialBindings
│   │
│   ├── core/                       # Core system, routing, services & utilities
│   │   ├── di/
│   │   │   └── injection.dart      # Global Dependency Injection (Get.lazyPut bindings)
│   │   ├── routing/
│   │   │   ├── app_pages.dart      # GetX Route definitions & transitions
│   │   │   └── app_routes.dart     # Route constant names
│   │   ├── services/
│   │   │   ├── app_colors.dart     # Palette & UI theme styling constants
│   │   │   ├── email_otp_service.dart # SMTP real email OTP delivery
│   │   │   └── sound_service.dart  # Audio playback engine for SFX
│   │   └── widgets/                # Reusable common UI widgets
│   │
│   └── features/                   # Independent feature modules
│       │
│       ├── auth/                   # Authentication Module
│       │   ├── data/
│       │   │   ├── datasources/    # Firebase Auth & Google Sign-In data source
│       │   │   ├── models/         # User data model
│       │   │   └── repositories/   # Auth repository implementation
│       │   └── presentation/
│       │       ├── controllers/    # AuthController (state & validation logic)
│       │       ├── login_page.dart # Sign-In Screen
│       │       ├── reg_page.dart   # Registration Screen
│       │       ├── verify_email_page.dart # OTP Verification Screen
│       │       ├── forgot_password_page.dart
│       │       └── welcome_page.dart
│       │
│       ├── game/                   # Core Gameplay Module
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── game_local_datasource.dart   # SharedPreferences storage
│       │   │   │   └── game_remote_datasource.dart  # Cloud Firestore storage
│       │   │   ├── models/         # LevelProgressModel
│       │   │   └── repositories/   # GameRepositoryImpl (two-way sync)
│       │   ├── domain/
│       │   │   ├── entities/       # LevelProgressEntity
│       │   │   ├── repositories/   # Abstract GameRepository interface
│       │   │   └── usecases/       # GetLevelProgressUseCase, SaveLevelResultUseCase
│       │   └── presentation/
│       │       ├── controllers/    # GameController (physics, shooting, grid state)
│       │       ├── widgets/
│       │       │   ├── aim_line_painter.dart        # Trajectory raycaster
│       │       │   ├── bubble_honeycomb_grid.dart   # Hexagonal grid renderer
│       │       │   ├── bubble_widget.dart           # Bubble graphics & shaders
│       │       │   ├── dashed_danger_line.dart      # Lower boundary line
│       │       │   ├── game_header.dart             # Level, pause, and back buttons
│       │       │   ├── game_stats_bar.dart          # Moves counter, stars, score bar
│       │       │   └── shooter_bubble_widget.dart   # Bottom bubble launcher
│       │       └── game_page.dart  # Game view wrapper
│       │
│       ├── home/                   # Main Home & Level Selection Module
│       │   └── presentation/
│       │       ├── controllers/    # HomeController (level progress reactive state)
│       │       ├── babulgame_page.dart # Active Game Screen with lifecycle handling
│       │       ├── home_page.dart  # Level selection road map
│       │       └── widgets/
│       │           ├── custom_lavel_box.dart        # 1-10 level selection buttons
│       │           └── drawer/                      # Modular profile drawer components
│       │               ├── drawer_header_profile.dart
│       │               ├── drawer_stats_dashboard.dart
│       │               ├── drawer_settings_section.dart
│       │               ├── drawer_logout_button.dart
│       │               └── drawer_dialogs.dart
│       │
│       └── splash/                 # Splash module with animated logo
│           └── presentation/
│               └── splash_page.dart
│
├── pubspec.yaml                    # Flutter packages & asset configuration
└── README.md                       # Complete documentation
```

---

## 🚀 How to Setup & Run (Step by Step)

### 1. Prerequisites
Ensure you have installed:
- **Flutter SDK:** Version `3.38.1` or newer ([flutter.dev](https://flutter.dev))
- **Android Studio / VS Code** with Flutter extensions
- **Java JDK:** Version 17

Check your environment:
```bash
flutter doctor
```

### 2. Clone or Extract the Project
```bash
git clone <repository-url>
cd popupgame
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Setup Firebase Configuration
1. Place your `google-services.json` file inside `android/app/`.
2. Ensure Firebase Authentication (Email/Password & Google) and Cloud Firestore are enabled in your [Firebase Console](https://console.firebase.google.com/).

### 5. Run the Application
Connect your Android device via USB (or start an emulator) and execute:
```bash
flutter run
```

---

## 📦 How to Build Optimized Release APK (Low MB)

The standard universal APK bundles native binaries for 3 different CPU architectures, making it ~49 MB. 

To build a **single, lightweight APK (~24 MB)** specifically for modern Android smartphones:

```bash
flutter build apk --target-platform android-arm64 --release
```

The output file will be generated at:
`build\app\outputs\flutter-apk\app-release.apk`

---

## 📋 Packages & Why They Are Used

| Package | Purpose in this Game |
| :--- | :--- |
| `get` | High-performance reactive state management (`Rx`, `Obx`), dependency injection (`Get.lazyPut`), and context-less navigation/dialogs. |
| `firebase_core` | Initializes Google Firebase native SDK on Android/iOS. |
| `firebase_auth` | User account creation, email login, session management, and password reset. |
| `google_sign_in` | Native Google Sign-In button handling for 1-click player onboarding. |
| `cloud_firestore` | Stores players' stars, high scores, and unlocked levels permanently in the cloud. |
| `shared_preferences` | Key-value local storage ensuring instant UI loading without waiting for internet. |
| `audioplayers` | Low-latency audio playback for pop, win, bounce, and combo sound effects. |
| `mailer` | Sends real 6-digit verification OTP codes to player emails via SMTP. |
| `flutter_dotenv` | Loads environment configuration and credentials safely. |
| `cupertino_icons` | High-quality vector iconography. |

---

## 📄 License
This project is developed for entertainment and educational purposes. All assets and code are free to use and customize.
