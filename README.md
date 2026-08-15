# Campus Lost & Found 🎓🔍

A cross-platform mobile and web application for discovering and connecting lost and found items on campus.

**Version:** 1.0.0 | **Status:** Development 🚀

---

## 📋 Project Overview

### Problem
Lost and found items at campus are currently scattered across multiple WhatsApp groups and bulletin boards, making it nearly impossible for owners to find their belongings.

### Solution
A centralized platform where:
- Users post **lost** or **found** items with photo, category, location, and description
- The system automatically matches lost/found items in the same category and location
- Finders and losers are notified of potential matches
- Claims can be approved/rejected with verification
- Items are marked as resolved once returned

### Technology Stack
- **Frontend:** Flutter (iOS, Android, Web) - Single codebase for all platforms
- **Backend:** KeystoneJS (Node.js, GraphQL) with PostgreSQL
- **ML:** Python microservice for image matching
- **Auth:** Google Sign-In
- **Notifications:** Firebase Cloud Messaging
- **Deployment:** Firebase Hosting (Web), App Store/Play Store (Mobile)

---

## 📁 Project Structure

```
campus-lost-and-found/
├── .github/
│   └── workflows/
│       ├── flutter-web.yml          # Web CI/CD pipeline
│       └── flutter-mobile.yml       # Mobile CI/CD pipeline
├── config/
│   ├── .env.dev                    # Development environment
│   ├── .env.staging                # Staging environment
│   └── .env.prod                   # Production environment
├── frontend/
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── config/                 # Configuration files
│   │   ├── core/                   # Business logic & services
│   │   ├── ui/                     # User interface screens
│   │   └── generated/              # Generated files
│   ├── web/                        # Web platform files
│   ├── pubspec.yaml                # Flutter dependencies
│   ├── ARCHITECTURE.md             # Cross-platform design docs
│   └── README.md                   # Frontend setup guide
├── backend/                        # (Coming soon)
│   ├── src/
│   ├── schema/
│   ├── migrations/
│   └── package.json
├── ml-service/                     # (Coming soon)
│   ├── models/
│   ├── inference.py
│   └── requirements.txt
├── VERSION                         # Semantic versioning
└── README.md                       # This file
```

---

## 🌍 Environments

The application supports three deployment environments:

### Development (`develop` branch)
- **URL:** http://localhost:8888 (local)
- **API:** `http://localhost:4000/graphql`
- **Features:** Debug mode, analytics disabled, ML enabled
- **Deployment:** Manual `flutter build web`
- **Audience:** Team members, internal testing

### Staging (`staging` branch)
- **URL:** https://staging.campuslostfound.com
- **API:** `https://staging-api.campuslostfound.com/graphql`
- **Features:** Debug disabled, analytics enabled, ML enabled
- **Deployment:** Automatic on push (GitHub Actions)
- **Audience:** QA team, stakeholder testing

### Production (`master` branch)
- **URL:** https://campuslostfound.com
- **API:** `https://api.campuslostfound.com/graphql`
- **Features:** Debug disabled, analytics enabled, ML enabled
- **Deployment:** Manual on version tag release
- **Audience:** End users
- **Requirements:** PR review, tests passing, approval required

---

## 📦 Semantic Versioning

The project follows **Semantic Versioning 2.0.0** format: `MAJOR.MINOR.PATCH+BUILD`

### Version Components
- **MAJOR:** Breaking changes (e.g., API changes, major features)
- **MINOR:** New features that are backward compatible
- **PATCH:** Bug fixes and minor improvements
- **BUILD:** Build number (incremented for each release)

### Current Version
- **Version File:** `VERSION`
- **PubSpec:** `frontend/pubspec.yaml` (`version: 1.0.0+1`)

### Example Release
```bash
# 1. Update VERSION file
MAJOR=1
MINOR=1
PATCH=0
BUILD=2

# 2. Update frontend/pubspec.yaml
version: 1.1.0+2

# 3. Commit & push
git add VERSION frontend/pubspec.yaml
git commit -m "chore: bump version to 1.1.0"

# 4. Tag release
git tag -a v1.1.0 -m "Release version 1.1.0: New search filters"
git push origin v1.1.0

# 5. Trigger mobile builds automatically
```

---

## 🚀 CI/CD Pipeline

### GitHub Actions Workflows

#### 1. **Flutter Web CI/CD** (`.github/workflows/flutter-web.yml`)
Triggers on pushes/PRs to `develop`, `staging`, `master` branches

**Stages:**
- ✅ **Analyze** - Flutter analyze, linting
- ✅ **Test** - Run unit and widget tests
- ✅ **Build** - Compile for web
- 📤 **Deploy Dev** - Firebase to dev channel (from `develop`)
- 📤 **Deploy Staging** - Firebase to staging channel (from `staging`)
- 📤 **Deploy Production** - Firebase to prod (from `master`, requires approval)

#### 2. **Flutter Mobile CI/CD** (`.github/workflows/flutter-mobile.yml`)
Triggers on pushes to `master` and version tags

**Stages:**
- ✅ **Analyze & Test** - Code quality checks
- 🤖 **Build Android** - APK + App Bundle
- 🍎 **Build iOS** - iOS app archive
- 📦 **Create Release** - GitHub Release with artifacts (on tags)
- 📱 **Upload to Stores** - (Manual trigger to Play Store/App Store)

### Branch Strategy
```
master (v1.x.x tags)
  ↑
  └─ Pull Request (code review, tests pass, deploy approval)
     ↓
staging (continuous testing)
  ↑
  └─ Pull Request (from develop, auto-deploys)
     ↓
develop (continuous integration)
  ↑
  └─ Feature branches (feature/*, bugfix/*, refactor/*)
```

### GitHub Secrets Required
**Firebase Hosting:**
```
FIREBASE_SERVICE_ACCOUNT_DEV      # Dev project key
FIREBASE_SERVICE_ACCOUNT_STAGING  # Staging project key
FIREBASE_SERVICE_ACCOUNT_PROD     # Production project key (protected)
```

**Notifications:**
```
SLACK_WEBHOOK  # For deployment status updates
```

**App Store (Optional):**
```
APPLE_KEY_ID
APPLE_ISSUER_ID
APPLE_KEY_CONTENT
```

**Google Play (Optional):**
```
PLAY_STORE_SERVICE_ACCOUNT
```

---

## 🛠️ Local Development Setup

### Prerequisites
- Flutter 3.16+ ([Install](https://flutter.dev/docs/get-started/install))
- Dart 3.0+ (comes with Flutter)
- Node.js 18+ (for backend - coming soon)
- PostgreSQL 14+ (for backend - coming soon)

### Frontend Setup

```bash
# Navigate to frontend
cd frontend

# Install dependencies
flutter pub get

# Run on web (development)
flutter run -d chrome

# Build for web (release)
flutter build web --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Environment Configuration

Development environment is pre-configured. For other environments:

```bash
# Copy appropriate config
cp ../config/.env.staging .env
# or
cp ../config/.env.prod .env

# Edit values as needed
nano .env
```

### Run with Different Configurations

```bash
# Development (default)
flutter run

# With specific build type
flutter run --release
flutter run --profile

# On different devices
flutter run -d chrome     # Web
flutter run -d emulator   # Android emulator
flutter run -d simulator  # iOS simulator
```

---

## 📊 Features & Roadmap

### ✅ Implemented (v1.0)
- Cross-platform UI (iOS, Android, Web)
- Home, Browse, Post, Detail screens
- Google Sign-In integration
- Form validation & submission
- Responsive design

### 🚀 In Progress
- Backend API (KeystoneJS)
- Database schema (PostgreSQL)
- ML image matching
- Notifications
- Deployment to Firebase

### 📋 Planned
- Offline support
- Advanced search filters
- User profiles
- Item history
- Claims management
- Review system

---

## 🤝 Contributing

### Code Style
```bash
# Format Dart code
flutter format lib/

# Run analyzer
flutter analyze

# Run tests
flutter test

# Build check
flutter build web
```

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code refactoring
- `test` - Test additions/updates
- `chore` - Dependency updates, config

**Example:**
```
feat(search): Add category filter

Add category dropdown filter to search screen.
Allows filtering items by category for better UX.

Closes #42
```

### Pull Request Process
1. Create branch: `git checkout -b feature/my-feature`
2. Make changes and commit
3. Push: `git push origin feature/my-feature`
4. Open PR to `develop` (or `staging` for hotfixes)
5. Ensure all checks pass
6. Request review from team
7. Merge after approval

---

## 🔒 Security

- 🔐 Never commit `.env` files with secrets
- 🔐 Use GitHub Secrets for sensitive data
- 🔐 Enable branch protection on `master` and `staging`
- 🔐 Require PR reviews before merge
- 🔐 Run CodeQL scans (GitHub Security)
- 🔐 Validate all user input
- 🔐 Use HTTPS for all API calls
- 🔐 Rotate secrets regularly

---

## 📱 Platform Support

| Platform | Status | Min Version | Notes |
|----------|--------|-------------|-------|
| iOS | ✅ Ready | 11.0 | Web build tested |
| Android | ✅ Ready | API 21 | Web build tested |
| Web | ✅ Active | Modern browsers | Chrome, Safari, Firefox |
| macOS | 📋 Planned | 10.13 | After mobile release |

---

## 📚 Documentation

- [Frontend Architecture](frontend/ARCHITECTURE.md) - Detailed design patterns
- [Frontend README](frontend/README.md) - Setup guide
- [GitHub Workflows](.github/workflows/) - CI/CD details
- [Environment Setup](config/) - Configuration files

**Coming soon:**
- Backend Setup Guide
- API Documentation
- Deployment Guide
- Database Schema

---

## 🧪 Testing

```bash
cd frontend

# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (if available)
flutter drive --target=test_driver/app.dart

# Coverage report
flutter test --coverage
```

---

## 📞 Support

- **Bug Reports:** Use [GitHub Issues](../../issues)
- **Questions:** Use [GitHub Discussions](../../discussions)
- **Security Issues:** Contact team privately

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

## 🎓 CPAD Course Assignment

**Course:** Cross-Platform Application Development (CPAD)  
**Institution:** [Your Institution]  
**Semester:** Fall 2024  

**Assignment Goals:**
- ✅ Build cross-platform app from single codebase
- ✅ Implement responsive UI design
- ✅ Set up CI/CD pipelines
- ✅ Use semantic versioning
- ✅ Deploy to multiple environments
- ⏳ Integrate ML capabilities
- ⏳ Connect GraphQL backend

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| Platforms | 3 (iOS, Android, Web) |
| Dart Lines of Code | ~2,000+ |
| Screens | 5 |
| CI/CD Workflows | 2 |
| Environments | 3 |
| Version Scheme | SemVer 2.0.0 |

---

**Last Updated:** 2026-08-15  
**Current Version:** 1.0.0  
**Status:** 🚧 In Development (55% complete)  
**Next Milestone:** Backend API Integration (Target: 2026-08-22)
