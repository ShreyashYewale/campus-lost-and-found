# Campus Lost & Found - Frontend

A cross-platform Flutter application for discovering and connecting lost and found items on campus.

## Features

- ✅ Cross-platform support (iOS, Android, Web)
- ✅ Google authentication
- ✅ Post lost/found items with photos
- ✅ Search and filter items by category and location
- ✅ Automatic matching between lost and found items
- ✅ Real-time notifications
- ✅ ML-powered image matching (in development)

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **API:** GraphQL (via http + custom client)
- **Auth:** Google Sign-In, Firebase Auth
- **Storage:** SharedPreferences (local), Firebase (cloud)
- **Notifications:** Firebase Messaging + Flutter Local Notifications
- **Routing:** GoRouter
- **Image Handling:** Image Picker, Camera

## Project Structure (Cross-Platform Best Practices)

```
lib/
├── main.dart                 # Entry point
├── config/                   # App configuration
│   ├── app_config.dart      # Environment-specific config
│   └── app_theme.dart       # Shared UI theme
├── core/                     # Business logic & data
│   ├── models/              # Data models
│   ├── services/            # API, Auth services
│   └── utils/               # Shared utilities
├── ui/                       # User interface
│   ├── app.dart            # App widget & routing
│   ├── screens/            # Feature screens
│   │   ├── auth/           # Authentication
│   │   └── items/          # Item management
│   ├── widgets/            # Reusable UI components
│   └── responsive/         # Responsive layout utilities
└── generated/              # Generated files (build_runner)
```

## Cross-Platform Principles

### 1. **Unified Codebase**
- Single Flutter codebase compiles to iOS, Android, and Web
- No platform-specific code in main logic (services, models)
- UI adapts automatically via Material3 design system

### 2. **Responsive Design**
- Adaptive layouts for mobile (portrait/landscape) and tablet/web
- Breakpoints: Mobile (<600dp), Tablet (600-840dp), Desktop (>840dp)
- Flexible widgets and MediaQuery usage

### 3. **Platform-Specific Considerations**
- **Auth:** Google Sign-In works across all platforms
- **Image Handling:** Image Picker handles platform differences
- **Notifications:** Firebase Messaging with platform-specific setup
- **Storage:** SharedPreferences for local data (cross-platform)

### 4. **Consistent State Management**
- Provider pattern ensures same state across all platforms
- Services are platform-agnostic
- ChangeNotifier for reactive updates

### 5. **Configuration Management**
- Environment variables via `.env` file
- Environment-specific configs (dev, staging, prod)
- Feature flags for gradual rollout

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- IDE: VS Code, Android Studio, or Xcode

### 1. Install Dependencies

```bash
# From frontend directory
flutter pub get
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# - API_BASE_URL (backend GraphQL endpoint)
# - Google Client IDs for each platform
```

### 3. Set Up Google Sign-In

**Web:**
- Create OAuth 2.0 Web Application credentials in Google Cloud Console
- Update `web/index.html` with client ID

**iOS:**
- Create OAuth 2.0 iOS Application credentials
- Add GoogleService-Info.plist to Runner project

**Android:**
- Create OAuth 2.0 Android Application credentials
- SHA1 fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

### 4. Run the App

```bash
# Development (hot reload enabled)
flutter run

# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android

# Release build
flutter build web
flutter build apk
flutter build ios
```

## Development Workflow

### Adding a New Feature

1. **Create Model** → `lib/core/models/`
2. **Create Service** → `lib/core/services/`
3. **Create Screen** → `lib/ui/screens/`
4. **Wire in Router** → `lib/ui/app.dart`
5. **Add Tests** → `test/`

### State Management Pattern

```dart
// Service (core/services/)
class MyService extends ChangeNotifier {
  // Business logic
  notifyListeners();
}

// Widget (ui/screens/)
final myService = Provider.of<MyService>(context);
final state = myService.state;
```

### API Integration Pattern

```dart
// Service
Future<T> fetchData() {
  return apiService.query(gql_query, variables: {...});
}

// Screen
FutureBuilder(
  future: service.fetchData(),
  builder: (context, snapshot) => ...
)
```

## API Integration

The app communicates with the backend via GraphQL. All queries are centralized:

```dart
// Example query in service
const query = '''
  query GetItems(\$filter: ItemFilter) {
    items(filter: \$filter) {
      id
      title
      category
      status
    }
  }
''';

final result = await apiService.query(query, variables: {...});
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/services/auth_service_test.dart
```

## Build & Deploy

### Web
```bash
flutter build web --release
# Deploy to Firebase Hosting or any static host
```

### Mobile
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

## Performance Tips

- Use `const` constructors where possible
- Implement `shouldRebuild` in Providers
- Use `ListView.builder` for long lists
- Cache images with `cached_network_image`
- Profile with DevTools: `flutter pub global activate devtools`

## Troubleshooting

### Hot reload not working
```bash
flutter clean
flutter pub get
flutter run
```

### Web won't load
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Build issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter doctor
```

## Contributing

1. Create a feature branch from `front-end`
2. Follow the project structure
3. Run `flutter analyze` and `flutter test`
4. Commit with descriptive messages
5. Open a pull request

## License

MIT License - See LICENSE file

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)
