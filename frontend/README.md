# KLink Frontend

Flutter-based mobile application for KLink social media platform.

## Features

- **Authentication**
  - Email/password registration and login (@kiit.ac.in domain validation)
  - Google OAuth integration
  - Session management with deep link handling
  
- **Posts**
  - View post feed
  - Like/unlike posts
  - Delete own posts
  - Pull-to-refresh

- **Social Features**
  - Follow/unfollow users
  - View user profiles
  - Followers/following counts

- **UI/UX**
  - Dark theme
  - Bottom navigation (Home, Search, Profile)
  - Loading states and error handling

## Setup

### Prerequisites
- Flutter SDK (^3.9.2)
- Android Studio / Xcode (for mobile development)
- Supabase account

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Configure Supabase credentials in `lib/config/supabase_config.dart`

3. Update API base URL in `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

4. Run the app:
```bash
flutter run
```

### Generate App Icons

```bash
dart run flutter_launcher_icons
```

## Configuration

### Deep Links
- **Scheme:** `com.klink.frontend://login-callback`
- Used for Google OAuth redirects

### API Configuration
Update `lib/config/api_config.dart` based on your environment:
- Android Emulator: `http://10.0.2.2:3000/api`
- iOS Simulator: `http://localhost:3000/api`
- Physical Device: `http://YOUR_COMPUTER_IP:3000/api`

## Architecture

- **State Management:** Provider
- **HTTP Client:** http package
- **Auth:** Supabase Flutter SDK
- **Deep Linking:** app_links package
- **Local Storage:** shared_preferences

## Project Structure

```
lib/
├── config/           # Configuration files
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API services
└── widgets/          # Reusable widgets
```

## Known Limitations

- No create post UI (backend ready)
- Comments UI not implemented
- Search not functional (no backend endpoint)
- Edit profile UI missing
- No image upload functionality

## Getting Started with Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
