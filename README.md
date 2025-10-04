# KLink

A modern social media platform built with Flutter and Express.js, designed for the KIIT community.

To be eligible for MLSA X HACKTOBERFEST: 
And register here: https://register.mlsakiit.com/
Star this repo: https://github.com/keploy/keploy

## Overview

KLink is a full-stack social media application featuring user authentication, posts, comments, and a follow system. Built with Flutter for the frontend and Express.js with PostgreSQL for the backend, it provides a seamless social networking experience.

## Features

### Core Functionality
- **Authentication System**
  - Email/password registration and login (restricted to @kiit.ac.in domain)
  - Google OAuth integration
  - Session management with JWT tokens
  - Deep link handling for OAuth callbacks

- **Posts & Interactions**
  - View post feed
  - Like/unlike posts
  - Delete own posts
  - Pull-to-refresh functionality

- **Social Features**
  - Follow/unfollow users
  - View user profiles with statistics
  - Followers and following counts
  - User-specific post feeds

- **Modern UI/UX**
  - Dark theme design
  - Bottom navigation (Home, Search, Profile)
  - Loading states and error handling
  - Responsive layouts

## Tech Stack

### Frontend
- **Framework:** Flutter (^3.9.2)
- **State Management:** Provider
- **Authentication:** Supabase Flutter SDK
- **HTTP Client:** http package
- **Deep Linking:** app_links package
- **Local Storage:** shared_preferences

### Backend
- **Framework:** Express.js
- **Database:** PostgreSQL (Supabase)
- **ORM:** Prisma
- **Authentication:** Supabase Auth
- **Security:** Helmet.js, CORS, Rate Limiting
- **Validation:** Joi

## Project Structure

```
KLink/
├── frontend/              # Flutter mobile application
│   ├── lib/
│   │   ├── config/       # Configuration files
│   │   ├── models/       # Data models
│   │   ├── providers/    # State management
│   │   ├── screens/      # UI screens
│   │   ├── services/     # API services
│   │   └── widgets/      # Reusable widgets
│   └── android/ios/web/  # Platform-specific code
│
├── backend/              # Express.js API server
│   ├── src/
│   │   ├── controllers/  # Request handlers
│   │   ├── middleware/   # Express middleware
│   │   ├── routes/       # API routes
│   │   └── config/       # Configuration
│   ├── prisma/           # Database schema
│   └── database/         # SQL scripts
│
└── docs/                 # Documentation (if needed)
```

## Quick Start

### Prerequisites
- Flutter SDK (^3.9.2)
- Node.js (v16+)
- PostgreSQL (or Supabase account)
- Android Studio / Xcode (for mobile development)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables (copy `.env.example` to `.env`):
```env
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
DATABASE_URL=your_database_url
DIRECT_URL=your_direct_url
ALLOWED_EMAIL_DOMAIN=@kiit.ac.in
```

4. Setup database:
```bash
npx prisma generate
npx prisma db push
```

5. Start the server:
```bash
npm run dev
```

Server will run on `http://localhost:3000` (or `http://0.0.0.0:3000` for network access)

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API configuration in `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

4. Update Supabase configuration in `lib/config/supabase_config.dart`

5. Run the app:
```bash
flutter run
```

## API Documentation

### Base URL
```
http://localhost:3000/api
```

### Authentication Endpoints
- `POST /auth/signup` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/google` - Google OAuth
- `POST /auth/logout` - Logout user
- `GET /auth/me` - Get current user
- `PUT /auth/profile` - Update profile

### Posts Endpoints
- `GET /posts/` - Get all posts
- `GET /posts/:id` - Get post by ID
- `GET /posts/user/:userId` - Get user's posts
- `POST /posts/` - Create post
- `PUT /posts/:id` - Update post
- `DELETE /posts/:id` - Delete post
- `POST /posts/:id/like` - Like post
- `DELETE /posts/:id/like` - Unlike post

### Comments Endpoints
- `GET /comments/post/:postId` - Get comments
- `POST /comments/` - Create comment
- `DELETE /comments/:id` - Delete comment

### Follow Endpoints
- `POST /follow/:userId` - Follow user
- `DELETE /follow/:userId` - Unfollow user
- `GET /follow/followers/:userId` - Get followers
- `GET /follow/following/:userId` - Get following
- `GET /follow/check/:userId` - Check if following

For detailed API documentation, see [backend/README.md](backend/README.md)

## Database Schema

### Core Models
- **Users** - User accounts with profiles
- **Posts** - User-generated content
- **Comments** - Post comments
- **Follows** - User follow relationships
- **Likes** - Post likes

See `backend/prisma/schema.prisma` for complete schema.

## Security

- Email domain validation (@kiit.ac.in only)
- JWT token authentication
- Rate limiting on all endpoints
- CORS configuration
- Helmet.js security headers
- Input validation with Joi
- PgBouncer connection pooling
- Orphaned record cleanup

## Current Limitations

### Critical
- No create post UI (backend ready)
- Comments backend ready, no UI
- Search not implemented
- Edit profile UI missing
- No image upload functionality

### Future Enhancements
- User search functionality
- Image/video upload
- Real-time notifications
- Direct messaging
- Post reporting system
- Email verification
- Password reset
- Hashtags and mentions
- Feed algorithm

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

## Development Team

Built for the KIIT community by developers passionate about social networking.

## License

This project is private and intended for educational purposes.

## Support

For issues, questions, or suggestions:
- Create an issue in the repository
- Contact the development team

## Acknowledgments

- Flutter team for the amazing framework
- Supabase for authentication and database services
- Express.js community
- All contributors and testers

---

**Note:** This is an active development project. Features and documentation are continuously being updated.

**Current Version:** 1.0.0  
**Last Updated:** October 4, 2025
