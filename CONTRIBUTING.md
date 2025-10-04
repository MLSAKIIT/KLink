# Contributing to KLink

Thank you for your interest in contributing to KLink! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Publishing others' private information
- Other unprofessional conduct

## Getting Started

### Prerequisites

- Git
- Node.js (v16+)
- Flutter SDK (^3.9.2)
- PostgreSQL or Supabase account
- Code editor (VS Code recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/MLSAKIIT/KLink.git
cd KLink-newver
```

3. Add upstream remote:
```bash
git remote add upstream https://github.com/MLSAKIIT/KLink.git
```

4. Create a new branch:
```bash
git checkout -b feature/your-feature-name
```

### Setup Development Environment

#### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your credentials
npx prisma generate
npx prisma db push
npm run dev
```

#### Frontend Setup
```bash
cd frontend
flutter pub get
# Update API configuration in lib/config/api_config.dart
flutter run
```

## Development Workflow

### Branch Naming Convention

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Adding tests
- `chore/description` - Maintenance tasks

Examples:
- `feature/create-post-ui`
- `fix/login-error-handling`
- `docs/api-documentation`

### Making Changes

1. Keep your fork synced with upstream:
```bash
git fetch upstream
git rebase upstream/main
```

2. Make your changes in your feature branch
3. Test your changes thoroughly
4. Commit your changes (see commit guidelines)
5. Push to your fork:
```bash
git push origin feature/your-feature-name
```

## Pull Request Process

### Before Submitting

- [ ] Code follows project coding standards
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commits follow commit guidelines
- [ ] No console.log or debug statements (except error logging)
- [ ] Code is properly formatted

### Submitting a Pull Request

1. Go to the original repository on GitHub
2. Click "New Pull Request"
3. Select your fork and branch
4. Fill in the PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How to test these changes

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
```

5. Submit the pull request

### Review Process

- Maintainers will review your PR
- Address any requested changes
- Once approved, your PR will be merged

## Coding Standards

### Flutter/Dart

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep functions small and focused
- Use const constructors where possible
- Format code: `flutter format .`
- Analyze code: `flutter analyze`

Example:
```dart
// Good
Future<void> loadUserPosts() async {
  setState(() => _isLoading = true);
  try {
    final posts = await _postService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    _showError('Failed to load posts');
  }
}

// Avoid
Future<void> loadPosts() async {
  // Too generic name, unclear what posts
}
```

### JavaScript/Node.js

- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use async/await over callbacks
- Handle errors properly
- Use descriptive variable names
- Keep functions pure when possible

Example:
```javascript
// Good
const createPost = async (req, res) => {
    try {
        const { content, imageUrl } = req.body;
        const post = await prisma.post.create({
            data: { content, imageUrl, userId: req.user.id }
        });
        res.status(201).json({ post });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create post' });
    }
};

// Avoid
const createPost = (req, res) => {
    // Callback-based, no error handling
};
```

### General Guidelines

- Write self-documenting code
- Add comments for complex logic only
- Remove debug statements before committing
- No commented-out code
- Use meaningful commit messages

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting)
- `refactor` - Code refactoring
- `test` - Adding/updating tests
- `chore` - Maintenance tasks

### Examples

```bash
feat(auth): add Google OAuth integration

- Implement OAuth flow with Supabase
- Add deep link handling for callbacks
- Update auth provider with OAuth state

Closes #123
```

```bash
fix(posts): resolve like button state issue

Fixed issue where like button wouldn't update after unliking a post.
Updated the state management to properly reflect changes.

Fixes #456
```

```bash
docs(api): update authentication endpoints

Added documentation for OAuth endpoints and updated response examples.
```

### Commit Best Practices

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- Capitalize first letter of subject
- No period at the end of subject
- Keep subject line under 50 characters
- Wrap body at 72 characters
- Reference issues in footer

## Project Structure

### Frontend (Flutter)
```
frontend/lib/
├── config/           # App configuration
├── models/           # Data models
├── providers/        # State management (Provider)
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   ├── home/        # Home feed
│   ├── profile/     # Profile screens
│   └── search/      # Search screen
├── services/         # API services
│   ├── auth_service.dart
│   ├── post_service.dart
│   ├── comment_service.dart
│   └── follow_service.dart
└── widgets/          # Reusable widgets
    ├── post_card.dart
    └── user_card.dart
```

### Backend (Express.js)
```
backend/src/
├── controllers/      # Route handlers
│   ├── auth.controller.js
│   ├── post.controller.js
│   ├── comment.controller.js
│   └── follow.controller.js
├── middleware/       # Express middleware
│   ├── auth.middleware.js
│   ├── validation.middleware.js
│   └── ratelimit.middleware.js
├── routes/           # API routes
└── config/           # Configuration files
```

## Testing

### Frontend Testing

Run tests:
```bash
flutter test
```

Widget tests:
```dart
testWidgets('Login button submits form', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byKey(Key('loginButton')));
  await tester.pump();
  // Assertions
});
```

### Backend Testing

Run tests:
```bash
npm test
```

Unit tests:
```javascript
describe('Auth Controller', () => {
  it('should register a new user', async () => {
    // Test implementation
  });
});
```

## Documentation

### Code Documentation

- Add JSDoc comments for functions
- Document complex algorithms
- Explain non-obvious code decisions
- Update README when adding features

### API Documentation

- Document all endpoints
- Include request/response examples
- List all query parameters
- Note authentication requirements

## Priority Features to Contribute

### High Priority
1. Create post UI (modal/screen)
2. Comments screen with UI
3. Edit profile screen
4. User search backend endpoint
5. Image upload functionality

### Medium Priority
6. Post details screen
7. Pagination for posts
8. Delete confirmation dialogs
9. Profile navigation from post cards
10. Error retry mechanisms

### Low Priority
11. Share functionality
12. Notifications system
13. Direct messaging
14. Post reporting
15. Admin panel

## Getting Help

- Create an issue for bugs or questions
- Join project discussions
- Contact maintainers

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to KLink! Your efforts help make this project better for everyone.
