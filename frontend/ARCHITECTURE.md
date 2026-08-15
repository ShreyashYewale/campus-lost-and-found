# Frontend Architecture - Cross-Platform Design

## Overview

The Campus Lost & Found frontend uses a **single Flutter codebase** that compiles to:
- 📱 iOS (native)
- 📱 Android (native)  
- 🌐 Web (HTML/CSS/JS)

This document explains the architectural decisions that enable this cross-platform approach.

## Core Principles

### 1. **Platform Abstraction Layer**

Instead of platform-specific code scattered throughout, we create service abstractions:

```
UI Layer (Screens)
      ↓
Service Layer (Business Logic)
      ↓
Platform-Agnostic Core Services
      ↓
Native APIs (handled by Flutter plugins)
```

**Example:** Image Picker
- **UI:** User taps "Pick Photo" button (same on all platforms)
- **Service:** `ImageService` wraps `image_picker` plugin
- **Platform:** Plugin handles iOS/Android/Web differences internally

### 2. **Responsive UI Patterns**

The UI adapts to different screen sizes and orientations:

```dart
// Pseudo-code
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    if (size.width < 600) {
      return MobileLayout();      // Phone portrait
    } else if (size.width < 840) {
      return TabletLayout();      // Tablet/iPad
    } else {
      return DesktopLayout();     // Web/Desktop
    }
  }
}
```

### 3. **Unified State Management**

Using Provider, state flows the same way across all platforms:

```
User Interaction
      ↓
Widget calls Service method
      ↓
Service updates state (notifyListeners)
      ↓
UI rebuilds (same code, different screen)
```

## Architecture Layers

### Layer 1: Data Models (Immutable)
```
lib/core/models/
├── item.dart
├── user.dart
└── notification.dart
```

- Pure data classes with serialization (toJson/fromJson)
- No business logic
- Same models used across all platforms

### Layer 2: Services (Business Logic)
```
lib/core/services/
├── api_service.dart      # GraphQL client
├── auth_service.dart     # User authentication
├── item_service.dart     # Item CRUD operations
└── notification_service.dart  # Push notifications
```

**Characteristics:**
- Platform-independent logic
- Handle API calls, data processing, caching
- Notify UI of state changes via ChangeNotifier
- Testable without UI

### Layer 3: UI (Presentation)
```
lib/ui/
├── screens/
│   ├── home_screen.dart
│   └── items/
│       ├── post_item_screen.dart
│       └── search_items_screen.dart
├── widgets/
│   ├── item_card.dart
│   ├── custom_button.dart
│   └── responsive_scaffold.dart
└── responsive/
    └── breakpoints.dart
```

**Characteristics:**
- Adaptive layouts (mobile/tablet/web)
- Consumes services via Provider
- Minimal logic (just UI logic)
- Reusable components

## Platform-Specific Handling

### Image Handling Example

**Problem:** iOS, Android, and Web handle image picking differently

**Solution:** Abstract with a Service

```dart
// lib/core/services/image_service.dart
class ImageService {
  Future<String> pickImageFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    return file?.path ?? '';
  }
  
  Future<String> takePhotoWithCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    return file?.path ?? '';
  }
}

// lib/ui/screens/items/post_item_screen.dart (same code for all platforms)
class PostItemScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final imageService = Provider.of<ImageService>(context);
    
    return ElevatedButton(
      onPressed: () async {
        final imagePath = await imageService.pickImageFromGallery();
        // Use imagePath...
      },
      child: Text('Pick Photo'),
    );
  }
}
```

**Result:** Same UI code, but image picking works natively on iOS, Android, and Web!

### Authentication Example

```dart
// lib/core/services/auth_service.dart
class AuthService extends ChangeNotifier {
  Future<bool> googleSignIn(String idToken) async {
    // Same logic for iOS, Android, Web
    // Flutter's google_sign_in plugin handles platform differences
    final result = await GoogleSignIn().signIn();
    return result != null;
  }
}
```

## Responsive Layout Strategy

### Breakpoints
```dart
class Breakpoints {
  static const mobile = 600;     // < 600dp
  static const tablet = 840;     // 600-840dp
  static const desktop = 1200;   // > 840dp
}
```

### Example: Responsive Post Item Form

```dart
class PostItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return _MobileLayout();      // Single column, full width
    } else {
      return _TabletDesktopLayout(); // Two columns, constrained width
    }
  }
  
  Widget _MobileLayout() => SingleChildScrollView(
    child: Column(children: [...]),
  );
  
  Widget _TabletDesktopLayout() => SizedBox(
    width: 800,
    child: Row(children: [
      Expanded(child: _FormColumn()),
      Expanded(child: _PreviewColumn()),
    ]),
  );
}
```

## Environment Configuration

Different configurations for different platforms/environments:

```yaml
# .env.development
API_BASE_URL=http://localhost:4000
ENABLE_DEBUG=true

# .env.production  
API_BASE_URL=https://api.campuslostfound.com
ENABLE_DEBUG=false
```

Each platform loads the appropriate config:

```dart
class AppConfig {
  static Future<void> initialize() async {
    final env = Platform.isWeb ? 'web' : 'mobile';
    await dotenv.load(fileName: '.env.$env');
  }
}
```

## Testing Strategy

### Unit Tests (Platform-Independent)
```dart
// Test business logic without UI
test('AuthService.googleSignIn', () async {
  final service = AuthService(mockApiService);
  expect(await service.googleSignIn(token), true);
});
```

### Widget Tests (Cross-Platform)
```dart
// Test UI components on different screen sizes
testWidgets('Responsive layout on mobile', (tester) async {
  addSize(tester, Size(400, 800)); // Mobile
  expect(find.byType(MobileLayout), findsOneWidget);
});

testWidgets('Responsive layout on web', (tester) async {
  addSize(tester, Size(1200, 900)); // Web
  expect(find.byType(TabletDesktopLayout), findsOneWidget);
});
```

### Integration Tests (Full App)
- Test complete user flows on actual devices/emulators
- Run on iOS, Android, and Web

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   UI Layer (Screens)                    │
│  HomeScreen, PostItemScreen, SearchItemsScreen          │
└────────────────────┬────────────────────────────────────┘
                     │ (calls methods)
┌────────────────────▼────────────────────────────────────┐
│              Service Layer (Business Logic)             │
│  AuthService, ItemService, ApiService                   │
└────────────────────┬────────────────────────────────────┘
                     │ (calls)
┌────────────────────▼────────────────────────────────────┐
│            Model Layer (Data Models)                    │
│  Item, User, Notification (immutable)                   │
└────────────────────┬────────────────────────────────────┘
                     │ (uses)
┌────────────────────▼────────────────────────────────────┐
│    Flutter Plugins (Platform-Specific Handling)         │
│  image_picker, google_sign_in, firebase_messaging      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│          Native APIs (iOS, Android, Web)               │
│  Camera, FileSystem, Network, Push Notifications       │
└─────────────────────────────────────────────────────────┘
```

## Performance Considerations

### Cross-Platform Optimization
1. **Code Sharing:** Single codebase = less duplication
2. **Build Size:** Only include necessary plugins
3. **Lazy Loading:** Load features on demand
4. **Caching:** Cache API responses and images
5. **Asset Management:** Optimize images for different DPIs

### Platform-Specific Optimizations
- **Web:** Use CDN for assets, enable gzip compression
- **Mobile:** Use ProGuard for Android, CocoaPods for iOS
- **All:** Profile with DevTools, optimize animations

## Deployment Strategy

### Local Development
```bash
flutter run -d chrome              # Web
flutter run -d emulator-5554       # Android
flutter run -d simulator           # iOS
```

### CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
- build web:    flutter build web --release
- build apk:    flutter build apk --release
- build ios:    flutter build ios --release
- deploy:       [platform-specific deployment]
```

Each platform deployment is independent but uses same codebase.

## Migration & Scaling

### Adding New Platform
1. Ensure all services are platform-agnostic
2. Add platform-specific plugins if needed
3. Test UI on new platform with different screen sizes
4. Update CI/CD pipeline

### Adding New Feature
1. Create data model in `core/models/`
2. Create service in `core/services/`
3. Create UI screens in `ui/screens/`
4. Wire in router in `ui/app.dart`
5. Works on all platforms automatically!

## Key Takeaways

✅ **Single Codebase** → iOS, Android, Web  
✅ **Unified State Management** → Provider pattern  
✅ **Responsive Design** → Adapts to screen size  
✅ **Platform Abstraction** → Services handle OS differences  
✅ **Testable Architecture** → Business logic independent of UI  
✅ **Scalable Structure** → Easy to add features/platforms  

This architecture demonstrates cross-platform development best practices, a key learning outcome for CPAD!
