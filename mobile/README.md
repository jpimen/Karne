# Karne Mobile

A mobile companion application for the Karne performance tracking system, built with Flutter.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (for emulators and native builds)
- A running instance of the [Karne Backend](../backend/README.md)

## Setup and Installation

### 1. Navigate to the Mobile Directory
```bash
cd mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Base URL
The app communicates with the backend. Ensure the API base URL is correctly configured in `lib/services/api_service.dart` or the relevant configuration file to point to your backend instance (e.g., `http://10.0.2.2:8000` for Android Emulator).

## Running the Application

### Using a Physical Device or Emulator
Ensure your device/emulator is connected and recognized:
```bash
flutter devices
```

Start the application:
```bash
flutter run
```

### Running on the Web
To run the application in a web browser:
```bash
flutter run -d chrome
```
This will launch the app in a Chrome window.

### Building for Production

#### Android
```bash
flutter build apk
```

#### iOS
```bash
flutter build ios
```

#### Web
```bash
flutter build web
```

## Features

- **Workout Logging**: Track your sets, reps, and volume.
- **Program Management**: View and select your training programs.
- **Authentication**: Secure login and profile management.
- **Image Upload**: Progress tracking through photos (via `image_picker`).

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **Dio**: Powerful HTTP client for API interaction
- **Shared Preferences**: Local data persistence for tokens and settings
