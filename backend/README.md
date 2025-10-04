# KLink Backend API

Backend API for KLink social media application built with Express.js, Prisma, and Supabase.

## Features

- User authentication with Supabase Auth (Email/Password + Google OAuth)
- Email domain restriction (@kiit.ac.in only)
- Posts CRUD with like/unlike functionality
- Comments system
- Follow/Unfollow system
- User profiles with statistics
- Orphaned record cleanup
- Rate limiting and security headers

## Tech Stack

- **Framework:** Express.js
- **Database:** PostgreSQL (Supabase)
- **ORM:** Prisma
- **Auth:** Supabase Auth
- **Validation:** Joi
- **Security:** Helmet.js, CORS, Rate limiting

## Setup

### Prerequisites
- Node.js (v16+)
- PostgreSQL database (Supabase)
- Supabase account

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables in `.env`:
```env
PORT=3000
NODE_ENV=development

SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

DATABASE_URL=your_database_url
DIRECT_URL=your_direct_url

ALLOWED_EMAIL_DOMAIN=@kiit.ac.in
```

3. Generate Prisma client:
```bash
npx prisma generate
```

4. Push database schema:
```bash
npx prisma db push
```

5. (Optional) Run database trigger for auto-cleanup:
```sql
-- Execute database/trigger_delete_user.sql in Supabase SQL Editor
```

### Development

```bash
npm run dev
```

### Production

```bash
npm start
```

Server will run on `http://0.0.0.0:3000` (accessible from network)

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user (requires @kiit.ac.in email)
- `POST /api/auth/login` - Login user
- `POST /api/auth/google` - Google OAuth authentication
- `POST /api/auth/logout` - Logout user (requires auth)
- `GET /api/auth/me` - Get current user (requires auth)
- `PUT /api/auth/profile` - Update user profile (requires auth)
- `GET /api/auth/users/:id` - Get user by ID (requires auth)

### Posts
- `GET /api/posts/` - Get all posts (optional auth)
- `GET /api/posts/:id` - Get post by ID (optional auth)
- `GET /api/posts/user/:userId` - Get user's posts (optional auth)
- `POST /api/posts/` - Create post (requires auth)
- `PUT /api/posts/:id` - Update post (requires auth)
- `DELETE /api/posts/:id` - Delete post (requires auth)
- `POST /api/posts/:id/like` - Like post (requires auth)
- `DELETE /api/posts/:id/like` - Unlike post (requires auth)

### Comments
- `GET /api/comments/post/:postId` - Get comments for a post
- `POST /api/comments/` - Create comment (requires auth)
- `DELETE /api/comments/:id` - Delete comment (requires auth)

### Follow System
- `POST /api/follow/:userId` - Follow user (requires auth)
- `DELETE /api/follow/:userId` - Unfollow user (requires auth)
- `GET /api/follow/followers/:userId` - Get user's followers
- `GET /api/follow/following/:userId` - Get users followed by user
- `GET /api/follow/check/:userId` - Check if following user (requires auth)

### Users
- `GET /api/users/:id` - Get user by ID (requires auth)

## Database Schema

### Models
- **User** - User accounts with profile info
- **Post** - User posts with content and images
- **Comment** - Comments on posts
- **Follow** - Follow relationships between users
- **Like** - Post likes

See `prisma/schema.prisma` for complete schema definition.

## Security Features

- Helmet.js security headers
- Rate limiting (auth endpoints: 5 req/min, API: 100 req/min, create: 10 req/min)
- CORS configuration
- Input validation with Joi schemas
- JWT authentication via Supabase
- Email domain validation
- Orphaned record cleanup

## Middleware

- **auth.middleware.js** - JWT token validation
- **validation.middleware.js** - Request validation with Joi
- **ratelimit.middleware.js** - Rate limiting configuration

## Known Limitations

- No search endpoint implemented
- No image upload endpoint (Supabase Storage not integrated)
- No real-time features (websockets)
- No pagination on posts endpoint
- No email verification
- No password reset functionality

## Project Structure

```
backend/
├── src/
│   ├── controllers/    # Request handlers
│   ├── middleware/     # Express middleware
│   ├── routes/         # API routes
│   ├── config/         # Configuration files
│   └── server.js       # Express app
├── prisma/
│   └── schema.prisma   # Database schema
└── database/
    └── *.sql           # SQL scripts
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| PORT | Server port | No (default: 3000) |
| NODE_ENV | Environment | No (default: development) |
| SUPABASE_URL | Supabase project URL | Yes |
| SUPABASE_ANON_KEY | Supabase anonymous key | Yes |
| SUPABASE_SERVICE_ROLE_KEY | Supabase service role key | Yes |
| DATABASE_URL | PostgreSQL connection (with pgbouncer) | Yes |
| DIRECT_URL | PostgreSQL direct connection | Yes |
| ALLOWED_EMAIL_DOMAIN | Allowed email domain | No (default: @kiit.ac.in) |

## Health Check

```bash
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "OK",
  "timestamp": "2025-10-04T..."
}
```
