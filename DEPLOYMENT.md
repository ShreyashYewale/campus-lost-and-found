# Deployment Guide

Complete guide for deploying Campus Lost & Found to development, staging, and production environments.

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Web Deployment](#web-deployment)
4. [Mobile Deployment](#mobile-deployment)
5. [Environment Management](#environment-management)
6. [Versioning](#versioning)
7. [Rollback](#rollback)
8. [Monitoring](#monitoring)

---

## 🌍 Overview

### Deployment Architecture

```
Branch         Environment    URL                         Deploy Trigger
─────────────────────────────────────────────────────────────────────
develop   →    Development   http://localhost:8888        Manual build
          ↓    (Local)       (or dev.campus...)           flutter build web
          
staging   →    Staging       https://staging-api.xxx      Auto (GitHub Actions)
          ↓                                               flutter-web.yml on push
          
master    →    Production    https://api.campuslostfound  Manual tag release
               (Live)        .com                         v1.1.0 → GitHub Actions
                                                          with approval
```

### Environment Differences

| Aspect | Dev | Staging | Production |
|--------|-----|---------|------------|
| API URL | localhost:4000 | staging-api.xxx | api.xxx |
| Debug | Enabled | Disabled | Disabled |
| Analytics | Disabled | Enabled | Enabled |
| ML Features | Enabled | Enabled | Enabled |
| Error Reporting | Console | Firebase | Firebase |
| Log Level | DEBUG | INFO | WARNING |
| Rate Limiting | None | Basic | Strict |
| Cache | Disabled | 1 hour | 24 hours |

---

## 📋 Prerequisites

### Tools Required
```bash
# Flutter (3.16+)
flutter --version
# Flutter 3.16.0 • channel stable

# Dart
dart --version
# Dart SDK version: 3.14.0

# Firebase CLI (for web deployment)
firebase --version
# firebase-tools/13.0.0

# Git
git --version
# git version 2.x.x
```

### Accounts Required
- **GitHub:** Access to repository
- **Firebase:** Project for web hosting
  - `campus-lost-found-dev` (dev)
  - `campus-lost-found-staging` (staging)
  - `campus-lost-found-prod` (production)
- **Apple:** Developer account (for iOS)
- **Google Play:** Developer account (for Android)

### Environment Setup

#### Install Firebase CLI
```bash
npm install -g firebase-tools

# Or with Homebrew
brew install firebase-cli

# Verify installation
firebase --version

# Login to Firebase
firebase login
```

#### Configure Firebase Projects
```bash
# List available projects
firebase projects:list

# Create aliases for each environment
firebase use --add
# Select project: campus-lost-found-dev
# Alias: dev
# Repeat for staging and prod
```

---

## 🌐 Web Deployment

### Local Development Deployment

**Build and serve locally:**
```bash
cd frontend

# Clean build
flutter clean
flutter pub get

# Build web (debug)
flutter run -d chrome

# Or build web (release)
flutter build web --release

# Serve locally on port 8888
cd build/web
python3 -m http.server 8888

# Access at http://localhost:8888
```

### Firebase Web Deployment

#### 1. Build Web Release
```bash
cd frontend

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for web (release)
flutter build web --release
```

**Output:** `frontend/build/web/`

#### 2. Deploy to Development
```bash
# Ensure you're using dev alias
firebase use dev

# Deploy to Firebase Hosting (dev channel)
firebase deploy --only hosting:campus-lost-found-dev

# Or auto-deploy via GitHub Actions
# (automatic on push to develop branch)
```

#### 3. Deploy to Staging
```bash
# Use staging alias
firebase use staging

# Deploy to Firebase
firebase deploy --only hosting:campus-lost-found-staging

# Via GitHub Actions:
# - Merge PR to staging branch
# - CI/CD runs automatically
# - Deployment visible in Actions tab
```

#### 4. Deploy to Production
```bash
# Production requires approval!

# Option 1: Via GitHub Actions (Recommended)
# 1. Merge to master with version bump
# 2. Create release tag: git tag v1.1.0
# 3. Push tag: git push upstream v1.1.0
# 4. GitHub Actions triggers workflow
# 5. Workflow awaits approval
# 6. Approve in Actions tab
# 7. Automatic deployment to production

# Option 2: Manual deployment
firebase use prod
firebase deploy --only hosting:campus-lost-found-prod

# Create release
git tag -a v1.1.0 -m "Release 1.1.0"
git push upstream v1.1.0
```

#### Verify Deployment
```bash
# Check deployment status
firebase hosting:channel:list

# View deployment history
firebase hosting:releases:list

# Test the deployment
curl https://staging.campuslostfound.com
curl https://campuslostfound.com
```

---

## 📱 Mobile Deployment

### Android Deployment

#### Prerequisites
- Android SDK 21+
- Keystore file for signing
- Play Store developer account

#### Build APK
```bash
cd frontend

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Deploy to Play Store
```bash
# Via GitHub Actions (automatic on v*.* tags)
# Workflow: .github/workflows/flutter-mobile.yml

# Manual deployment:
# 1. Upload to Google Play Console
# 2. Configure release notes
# 3. Set beta/production track
# 4. Review and publish
```

#### Configuration
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

### iOS Deployment

#### Prerequisites
- Xcode 14+
- Apple Developer account
- iOS provisioning profiles
- App Store Connect access

#### Build iOS App
```bash
cd frontend

# Build iOS (release)
flutter build ios --release

# Build IPA
flutter build ipa --release
# Output: build/ios/ipa/campus_lost_and_found.ipa
```

#### Deploy to App Store
```bash
# Via GitHub Actions (automatic on v*.* tags)
# Requires: APPLE_KEY_ID, APPLE_ISSUER_ID, APPLE_KEY_CONTENT

# Manual deployment:
# 1. Upload IPA to App Store Connect
# 2. Configure app information
# 3. Set release notes
# 4. Add review notes
# 5. Submit for review
```

---

## ⚙️ Environment Management

### Environment Configuration

#### Development (.env.dev)
```env
API_BASE_URL=http://localhost:4000/graphql
FIREBASE_ANALYTICS=false
DEBUG_MODE=true
ML_ENABLED=true
LOG_LEVEL=DEBUG
```

#### Staging (.env.staging)
```env
API_BASE_URL=https://staging-api.campuslostfound.com/graphql
FIREBASE_ANALYTICS=true
DEBUG_MODE=false
ML_ENABLED=true
LOG_LEVEL=INFO
```

#### Production (.env.prod)
```env
API_BASE_URL=https://api.campuslostfound.com/graphql
FIREBASE_ANALYTICS=true
DEBUG_MODE=false
ML_ENABLED=true
LOG_LEVEL=WARNING
```

### GitHub Secrets

Required secrets for CI/CD:

```bash
# Firebase Service Accounts
FIREBASE_SERVICE_ACCOUNT_DEV      # Base64 encoded JSON
FIREBASE_SERVICE_ACCOUNT_STAGING  # Base64 encoded JSON
FIREBASE_SERVICE_ACCOUNT_PROD     # Base64 encoded JSON (protected)

# Apple (iOS deployment)
APPLE_KEY_ID
APPLE_ISSUER_ID
APPLE_KEY_CONTENT

# Google Play (Android deployment)
PLAY_STORE_SERVICE_ACCOUNT        # Base64 encoded JSON

# Notifications
SLACK_WEBHOOK                      # Slack deployment alerts
```

#### Add Secrets
```bash
# Set secret via GitHub CLI
gh secret set FIREBASE_SERVICE_ACCOUNT_DEV < firebase-key.json

# Or via GitHub UI
# 1. Go to Settings → Secrets and variables → Actions
# 2. Click "New repository secret"
# 3. Enter name and value
# 4. Click "Add secret"
```

---

## 📦 Versioning & Releases

### Semantic Versioning

Format: `MAJOR.MINOR.PATCH+BUILD`

### Release Process

#### 1. Prepare Release
```bash
# Ensure on develop/staging
git checkout develop
git pull upstream develop

# Update version numbers
# Edit VERSION file:
MAJOR=1
MINOR=1
PATCH=0
BUILD=2

# Edit frontend/pubspec.yaml:
version: 1.1.0+2

# Commit version bump
git add VERSION frontend/pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
```

#### 2. Create Release Branch
```bash
# Create release branch
git checkout -b release/1.1.0

# Make any final fixes/docs updates
# Commit as normal

# Create PR to master
git push origin release/1.1.0
```

#### 3. Tag Release
```bash
# Merge to master
# Then tag:
git checkout master
git pull upstream master

git tag -a v1.1.0 -m "Release version 1.1.0

Features:
- Add category filter
- Improve search performance
- Fix claim notification bug

Closes #123, #124, #125"

git push upstream v1.1.0
```

#### 4. GitHub Actions Workflow
```
Tag v1.1.0 pushed
  ↓
Flutter Mobile CI/CD triggered
  ↓
Tests & Analysis
  ↓
Build Android & iOS
  ↓
Create GitHub Release
  ↓
Upload artifacts
  ↓
Wait for manual approval
  ↓
Deploy to Play Store/App Store
```

#### 5. Create Release Notes
```bash
# GitHub creates draft release automatically
# Edit release notes:
# 1. Go to Releases → Draft
# 2. Edit description with changelog
# 3. Publish release
```

### Changelog Format
```markdown
## [1.1.0] - 2026-08-22

### Added
- Category filter in search screen
- Item detail view improvements
- New claim notification system

### Fixed
- Google Sign-In timeout issue
- Crash on item claim without internet
- Form validation edge cases

### Changed
- Improved search performance
- Updated Material Design components
- Better error messages

### Deprecated
- Old search API endpoint (use new endpoint)

### Removed
- Legacy analytics tracking

### Security
- Updated dependencies for security patches
- Improved token refresh mechanism
```

---

## 🔄 Rollback

### Rollback Strategy

#### Rollback Development
```bash
# If latest dev build has issues:
git checkout develop
git log --oneline

# Reset to previous good commit
git reset --hard <commit-hash>
git push origin develop -f

# Rebuild and redeploy
flutter build web --release
firebase deploy --only hosting:campus-lost-found-dev
```

#### Rollback Staging
```bash
# Via GitHub Actions:
# 1. Go to Actions tab
# 2. Find previous successful deployment
# 3. Click "Re-run" button

# Or manual rollback:
git checkout staging
git reset --hard v1.0.0
git push origin staging -f
firebase deploy --only hosting:campus-lost-found-staging
```

#### Rollback Production (Emergency Only!)
```bash
# CRITICAL: Use only for severe bugs

# Method 1: Via Firebase Console
firebase hosting:channels:deploy <previous-commit-hash>

# Method 2: Via Git rollback
git checkout master
git reset --hard v1.0.0  # Previous stable version
firebase deploy --only hosting:campus-lost-found-prod

# Create incident post-mortem
# Identify root cause
# Implement fix on develop
# Merge to master
# Deploy new release
```

---

## 📊 Monitoring

### Deployment Health

#### Firebase Hosting Metrics
```bash
# View realtime traffic
firebase hosting:channel:list

# Check performance
firebase hosting:releases:list

# View logs
firebase functions:log
```

#### Error Tracking
- Firebase Crashlytics (automatic)
- Cloud Logging (via Google Cloud Console)
- Custom analytics (configured)

#### Monitoring Dashboard
```
https://console.firebase.google.com/
  ├── Hosting
  │   ├── Analytics
  │   ├── Performance
  │   └── Traffic
  ├── Crashlytics
  ├── Performance Monitoring
  └── Cloud Logging
```

### Alert Configuration

#### Firebase Alerts
```bash
# Set up alerts in Firebase Console:
1. Go to Hosting
2. Click "Setup alerts"
3. Configure:
   - Error rate threshold
   - Deployment frequency
   - Performance metrics
4. Add notification channels (email, Slack)
```

#### Slack Integration
```bash
# Configure in .github/workflows/flutter-web.yml:

- name: Notify Slack
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Deployment successful to ${{ matrix.environment }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Campus Lost & Found Deployed*\nVersion: ${{ github.ref_name }}\nEnvironment: ${{ matrix.environment }}"
            }
          }
        ]
      }
```

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] Code reviewed and approved
- [ ] All tests passing
- [ ] No linting errors
- [ ] Version numbers updated
- [ ] Changelog updated
- [ ] Feature documented
- [ ] Branch up to date

### During Deployment
- [ ] Build completes without errors
- [ ] Artifacts generated correctly
- [ ] Tests pass during CI/CD
- [ ] No secrets in logs
- [ ] Deployment proceeds

### Post-Deployment
- [ ] Application loads without errors
- [ ] All features working
- [ ] No console errors
- [ ] Analytics events firing
- [ ] Notifications working
- [ ] Performance acceptable
- [ ] Team notified

---

## 🆘 Troubleshooting

### Build Failures

**Error:** `build/web not found`
```bash
# Solution:
flutter clean
flutter pub get
flutter build web --release
```

**Error:** `Firebase authentication failed`
```bash
# Solution:
firebase logout
firebase login
firebase use prod
```

### Deployment Issues

**Error:** `Deployment timeout`
```bash
# Solution:
# Check internet connection
# Check firebase quota
# Retry deployment
firebase deploy --only hosting:prod --debug
```

**Error:** `App crashes on production`
```bash
# Solution:
# Check Crashlytics for error details
# Review recent changes
# Rollback to previous version
# Fix issue on develop branch
# Re-deploy
```

---

## 📚 Additional Resources

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Flutter Deployment](https://flutter.dev/docs/deployment/web)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Semantic Versioning](https://semver.org/)

---

**Last Updated:** 2026-08-15  
**Version:** 1.0.0
