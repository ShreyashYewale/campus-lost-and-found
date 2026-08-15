# Contributing to Campus Lost & Found

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Commit Conventions](#commit-conventions)
5. [Code Style](#code-style)
6. [Testing](#testing)
7. [Pull Request Process](#pull-request-process)
8. [Deployment](#deployment)

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on code, not the person
- Help others learn
- Respect confidentiality

---

## 🚀 Getting Started

### 1. Fork & Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/campus-lost-and-found.git
cd campus-lost-and-found

# Add upstream remote
git remote add upstream https://github.com/CPAD-ORG/campus-lost-and-found.git
```

### 2. Create Feature Branch
```bash
# Update from upstream
git fetch upstream
git checkout -b develop origin/develop

# Create feature branch
git checkout -b feature/your-feature-name
```

### 3. Set Up Environment
```bash
cd frontend
flutter pub get
```

---

## 🔄 Development Workflow

### Feature Development
```bash
# Create branch from develop
git checkout develop
git pull upstream develop
git checkout -b feature/my-awesome-feature

# Make changes
flutter format lib/
flutter analyze
flutter test

# Commit with conventional messages
git add .
git commit -m "feat(search): Add category filter dropdown"
```

### Bug Fix
```bash
git checkout develop
git checkout -b bugfix/issue-number

# Fix and test
git commit -m "fix(auth): Handle Google sign-in timeout"
```

### Hotfix (for production issues)
```bash
git checkout master
git pull upstream master
git checkout -b hotfix/critical-issue

# Fix and test
git commit -m "fix(critical): Fix crash on item claim"
git push origin hotfix/critical-issue
# Create PR to master AND develop
```

---

## 📝 Commit Conventions

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `refactor` - Code refactoring
- `test` - Add or update tests
- `chore` - Dependencies, build config
- `perf` - Performance improvement
- `style` - Code formatting (no logic change)

### Scope
Component or area affected:
- `auth` - Authentication
- `search` - Search functionality
- `post` - Post item feature
- `ui` - UI components
- `api` - API integration
- `version` - Version/release related

### Subject
- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at end
- Max 50 characters

### Body
- Explain WHAT and WHY, not HOW
- Max 72 characters per line
- Separate from subject by blank line

### Footer
- Reference issues: `Closes #123`, `Fixes #456`
- Breaking changes: `BREAKING CHANGE: description`

### Examples
```
feat(search): Add category filter

Add dropdown to filter items by category.
Improves discoverability for users searching
for specific item types.

Closes #123
```

```
fix(auth): Handle expired token refresh

Automatically refresh token when expired
instead of redirecting to login. Improves
user experience for long sessions.

Fixes #456
```

```
docs(readme): Update setup instructions

Add Flutter version requirement and
installation troubleshooting steps.
```

---

## 🎨 Code Style

### Dart/Flutter Format
```bash
# Format all files
flutter format lib/

# Format specific file
flutter format lib/main.dart

# Check format without changes
flutter format --dry-run lib/
```

### Linting
```bash
# Run analyzer
flutter analyze

# Fix issues (if possible)
flutter fix
```

### Naming Conventions

**Files:**
- lowercase with underscores
- `home_screen.dart`, `auth_service.dart`

**Classes:**
- PascalCase
- `HomeScreen`, `AuthService`, `Item`

**Variables/Functions:**
- camelCase
- `userName`, `getItems()`, `_privateMethod()`

**Constants:**
- camelCase with 'k' prefix
- `kPrimaryColor`, `kDefaultPadding`

### Structure

**Widgets:**
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Lifecycle overrides first
  @override
  void initState() { }

  @override
  void dispose() { }

  @override
  Widget build(BuildContext context) { }

  // Helper methods
  void _handleAction() { }
}
```

**Services:**
```dart
class MyService extends ChangeNotifier {
  // Properties
  String _data = '';

  // Getters
  String get data => _data;

  // Constructor
  MyService();

  // Public methods
  Future<void> fetchData() async { }

  // Private methods
  void _processData() { }
}
```

---

## 🧪 Testing

### Write Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/screens/home_screen_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure
```dart
void main() {
  group('HomeScreen', () {
    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('navigate to search on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });
}
```

### Testing Checklist
- ✅ Unit tests for services
- ✅ Widget tests for UI
- ✅ Integration tests for flows
- ✅ 70%+ code coverage target

---

## 🔀 Pull Request Process

### Before Creating PR
1. Sync with upstream: `git pull upstream develop`
2. Run tests: `flutter test`
3. Format code: `flutter format lib/`
4. Analyze: `flutter analyze`
5. Build: `flutter build web`

### Create PR
1. Push to your fork: `git push origin feature/my-feature`
2. Create PR on GitHub
3. Fill out PR template completely

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] All tests passing

## Screenshots (if UI change)
Add screenshots showing before/after

## Checklist
- [ ] Code follows style guide
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests passing locally
- [ ] Branch is up to date with base
```

### Review Process
- Reviewer checks code quality
- Reviewer runs tests locally
- Reviewer checks functionality
- At least 1 approval required
- All conversations resolved
- Local validation checks passing

### Merging
- Squash and merge for feature branches
- Keep commit message (from PR title)
- Delete branch after merge

---

## 📦 Deployment

### Deployment Process

**Development (Auto)**
```bash
# Automatic when merged to develop
# Deployed to: http://localhost:8888
# Manual build: cd frontend && flutter build web
```

**Staging (Auto)**
```bash
# Automatic when merged to staging
# Deployed to: https://staging.campuslostfound.com
# Via: local build scripts and manual deploy commands
```

**Production (Manual)**
```bash
# 1. Merge to master with version bump
git checkout master
git pull upstream master

# 2. Update version
echo "MAJOR=1" > ../VERSION
echo "MINOR=1" > ../VERSION
echo "PATCH=0" >> ../VERSION
git add VERSION frontend/pubspec.yaml
git commit -m "chore: bump version to 1.1.0"

# 3. Tag release
git tag -a v1.1.0 -m "Release 1.1.0: Feature description"
git push upstream v1.1.0

# 4. Build and package the release manually
# 5. Manual promotion to production
```

---

## 🐛 Bug Reports

### Report Bug
1. Check if bug already exists in Issues
2. Use bug report template
3. Include:
   - Description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos
   - Environment (OS, Flutter version, etc.)
   - Device/browser info

### Example
```markdown
## Description
App crashes when claiming item without internet

## Steps to Reproduce
1. Disable internet connection
2. Open claimed item
3. Tap "Claim Item" button
4. Crash occurs

## Expected
Should show error message

## Actual
App crashes with no error

## Environment
- Flutter: 3.16.0
- OS: macOS 15.5
- Device: iPhone 14 simulator
```

---

## ✨ Feature Requests

### Submit Feature Idea
1. Check if feature already requested
2. Use feature request template
3. Include:
   - Clear description of feature
   - Why it's needed (problem it solves)
   - Proposed solution
   - Examples or mockups (if applicable)
   - Priority (nice-to-have, important, critical)

---

## 📚 Documentation

### Update Docs
- Keep README updated with setup changes
- Document complex logic
- Update API docs when changing endpoints
- Add inline comments for non-obvious code
- Update CHANGELOG

### Documentation Format
```dart
/// Brief description (single line)
///
/// Longer description if needed.
/// Can span multiple lines.
///
/// Example:
/// ```dart
/// final service = MyService();
/// await service.fetch();
/// ```
///
/// See also:
/// - [Related class]
/// - [Related method]
class MyClass {
  /// Describes what this method does.
  ///
  /// [parameter] - what this parameter does
  /// Returns: what is returned
  Future<List<Item>> fetchItems(String query) async {
    // Implementation
  }
}
```

---

## 🔐 Security

### Report Security Issue
- **DO NOT** open public issue
- Email: security@campuslostfound.com
- Include details but no public disclosure
- Allow time for patch before disclosure

---

## 🏆 Recognition

All contributors are recognized in:
- README.md contributors section
- Release notes for each version
- GitHub contributors graph

---

## ❓ Questions?

- Check [GitHub Discussions](../../discussions)
- Join team Slack channel
- Email: team@campuslostfound.com

---

## 📖 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Git Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Thank you for contributing to Campus Lost & Found! 🎉**
