Campus Lost & Found

A single platform for reporting and reclaiming lost items on campus, replacing the scattered WhatsApp groups where most posts never reach the owner. Users post a lost or found item with a photo, category, and location. The app automatically checks for matches between lost and found posts in the same category and area, notifies both parties, and supports a claim-and-approval workflow until the item is marked resolved.

Built as a CPAD course project.

Team: Shreyash Yewale (2025CA93029), Priyanka Salunke (2025CA93019) License: MIT

Features
Post a lost or found item with photo, category, and location
Browse and search all items; filter by category and location
Automatic matching between lost and found items
Claim an item, with approval from the person who posted it
Notifications on a possible match or a new claim
Mark items as resolved
Google login for authentication
Tech Stack
Layer	Technology	Notes
Frontend	Flutter (Web + one mobile platform)	UI only — talks to the backend over GraphQL
Backend	KeystoneJS (Node.js, GraphQL)	Schema, auth, matching logic, image storage
Database	PostgreSQL	Run locally via Docker
Version control	GitHub (CPAD org)	Feature branches + PR review

Important: Flutter is the frontend only. It has no server or database of its own. It sends GraphQL queries over HTTP to Keystone, which reads and writes Postgres and returns JSON that Flutter renders.

Repository Structure
campus-lost-and-found/
├── backend/          # KeystoneJS + Postgres
│   ├── schema.ts     # The four lists: User, Item, Claim, Notification
│   ├── keystone.ts   # Config: db connection, image storage, CORS
│   ├── auth.ts       # Authentication setup (from the Keystone starter)
│   ├── .env          # Local secrets — NOT committed
│   ├── .env.example  # Template with blank values — committed
│   └── ...
├── frontend/         # Flutter app (added in a later phase)
├── docs/             # Design notes, schema diagrams
└── README.md
Data Model

Four lists, all related:

User — name, email, googleId; owns items, claims, and notifications.
Item — title, description, type (lost/found), category, location, photo, status (open/claimed/resolved). category and location are select fields, not free text — this is deliberate, because reliable automatic matching needs fixed values rather than arbitrary strings.
Claim — links a User to an Item they want to claim, with a status (pending/approved/rejected).
Notification — a message to a User about a match or claim event, with a read flag.
Prerequisites

Before you start, make sure you have:

Node.js (LTS) and npm
Docker Desktop — used to run Postgres (see the note below about the office laptop)
Git with SSH set up for your GitHub account
Flutter SDK (only needed once we start the frontend phase)
Getting Started
1. Clone the repo
bash
git clone <repo-ssh-url>
cd campus-lost-and-found

Right after cloning, set your commit identity locally for this repo (we don't use a global git identity — see the SSH note at the end):

bash
git config user.name "Your Name"
git config user.email "your@email.com"
2. Start Postgres with Docker

We run Postgres in a Docker container so it's isolated and identical for both of us.

Port note — read this. The default Postgres port 5432 may already be taken on your machine by another local Postgres service. To avoid a conflict we map the container to host port 5433 instead. If you ever see P1000: Authentication failed, a port clash is the most likely cause — check with netstat -ano | findstr :5432 and confirm nothing else is squatting on the port you expect.

Create and start the container:

bash
docker run --name lostfound-db -e POSTGRES_PASSWORD=lostfound123 -p 5433:5432 -d postgres

What this does:

--name lostfound-db — names the container
-e POSTGRES_PASSWORD=lostfound123 — sets the postgres user password
-p 5433:5432 — maps host port 5433 to the container's internal 5432
-d postgres — runs the official Postgres image in the background

Create the database inside the container:

bash
docker exec -it lostfound-db psql -U postgres -c "CREATE DATABASE lostfound;"

Everyday Docker commands:

bash
docker stop lostfound-db     # pause when done for the day
docker start lostfound-db    # resume
docker rm -f lostfound-db    # delete entirely and start fresh

Note: By default, deleting the container also deletes its data. That's fine for this assignment. If we want data to survive deletion later, we'll add a Docker volume.

3. Configure environment variables

In backend/, create a .env file (copy from .env.example):

DATABASE_URL=postgres://postgres:lostfound123@localhost:5433/lostfound
SESSION_SECRET=replace-with-a-long-random-string-at-least-32-chars

Make sure the port matches what you used in the Docker command (5433).

Never commit .env. It holds the DB password and session secret. It's already in .gitignore. Only .env.example (with blank values) is committed.

4. Install dependencies and run the backend
bash
cd backend
npm install
npm run dev

On first run, Keystone will synchronize the schema with the database. When you see:

✅ GraphQL API ready
✅ Admin UI ready

...the backend is up.

5. Open the admin UI

Go to http://localhost:3000. On first load it asks you to create an initial user. After that you'll see the dashboard with User, Item, Claim, and Notification.

Quick test that everything works:

Create an Item — type lost, category electronics, location library
Create another Item — type found, category electronics, location library
Confirm both save correctly
The GraphQL playground is at http://localhost:3000/api/graphql.
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
- **Deployment:** Local builds and manual deployment to target hosts

---

## 📁 Project Structure

```
campus-lost-and-found/
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
- **Deployment:** Manual deployment from local build
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

# 3. Commit changes
git add VERSION frontend/pubspec.yaml
git commit -m "chore: bump version to 1.1.0"

# 4. Tag release
git tag -a v1.1.0 -m "Release version 1.1.0: New search filters"
git push origin v1.1.0
```

---

## 🚀 Local Deployment Workflow

This project uses a simple local-first workflow for builds and releases.

### Manual deployment flow
1. Work locally in your feature branch
2. Run tests and analyzer locally
3. Build the frontend for web or mobile
4. Serve locally or deploy manually to your target environment
5. Create a version tag when you are ready to release

### Local branch strategy
```
main
├─ feature/*
├─ bugfix/*
├─ hotfix/*
└─ release/*
```

### Local environment configuration
**Development:**
```
API_BASE_URL=http://localhost:4000/graphql
DEBUG_MODE=true
```

**Staging:**
```
API_BASE_URL=https://staging-api.campuslostfound.com/graphql
DEBUG_MODE=false
```

**Production:**
```
API_BASE_URL=https://api.campuslostfound.com/graphql
DEBUG_MODE=false
```

### Manual release checklist
- Update the version file
- Update the Flutter app version
- Run `flutter test`
- Run `flutter analyze`
- Build the release bundle
- Tag the release locally if needed

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
- [Environment Setup](config/) - Configuration files
- [Deployment Guide](DEPLOYMENT.md) - Local deployment workflow

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
- ✅ Set up a structured local deployment workflow
- ✅ Use semantic versioning
- ✅ Prepare for multiple environments
- ⏳ Integrate ML capabilities
- ⏳ Connect GraphQL backend

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| Platforms | 3 (iOS, Android, Web) |
| Dart Lines of Code | ~2,000+ |
| Screens | 5 |
| Manual deployment workflows | 1 |
| Environments | 3 |
| Version Scheme | SemVer 2.0.0 |

---

**Last Updated:** 2026-08-15  
**Current Version:** 1.0.0  
**Status:** 🚧 In Development (55% complete)  
**Next Milestone:** Backend API Integration (Target: 2026-08-22)
