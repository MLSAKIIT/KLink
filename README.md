# KLink

Text-only social app for KIIT University. Flutter client + Supabase backend (Postgres + Auth + RLS). This README focuses on the technical setup so contributors can run and iterate quickly.

## Tech Stack

- Flutter 3.8, Dart 3.8
- Supabase (Auth, Postgres, RLS, Realtime)
- Provider (state management, MVVM arch with ChangeNotifier)
- Google Fonts

## Project Layout

- lib/
  - View/ — UI screens
    - login_view.dart, register_view.dart, otp_verification_view.dart, home_view.dart
  - ViewModel/ — state + business logic
    - auth_view_model.dart, home_view_model.dart
  - Model/ — DTOs
    - auth_model.dart, home_model.dart
  - widgets/ — shared widgets
    - auth_bottom_bar.dart
- assets/
  - icon/, images/
- .env — Supabase credentials (not committed)

## Prerequisites

- Flutter SDK 3.8+
- A Supabase project
- Linux/macOS/Windows with Android/iOS tooling as needed

## Environment

Create a local .env in project root:

```
SUPABASE_URL=https://YOUR-PROJECT-REF.supabase.co
SUPABASE_KEY=YOUR-ANON-KEY
```

Load this in main.dart using your preferred env loader (e.g., flutter_dotenv) or hardcode for local dev only.

## Auth: Email OTP

KLink uses email OTP (no password). Users enter name + KIIT email, receive a 6‑digit code, and verify.

Supabase configuration:

- Authentication → Providers → Email:
  - Enable Email provider.
  - Set Custom SMTP (required for OTP emails).
  - Delivery method: One‑time password (OTP).

Free SMTP options:
- Dev only (no real delivery): Mailtrap Testing (host smtp.mailtrap.io, port 2525).
- Real delivery (free): Gmail SMTP with App Password (host smtp.gmail.com, port 587, username = your Gmail, password = app password).
- Brevo works too, but requires a verified sender/domain.

If you’re blocked by SMTP during development, temporarily disable “Confirm email” in the Email provider.

Client-side flow (already implemented):
- signInWithOtp/signUp with metadata { name }
- verifyOTP(type: OtpType.email) in OtpVerificationView
- On verified session, proceed to app (upsert profile if needed)

## Running the app

- Install deps:
  - Linux/macOS/Windows: `flutter pub get`
- Run:
  - Android: `flutter run -d android`
  - iOS (macOS): `flutter run -d ios`
- If assets don’t show:
  - `flutter clean && flutter pub get`

## Coding guidelines

- State: Provider + ChangeNotifier (MVVM-ish)
- Keep views dumb; put logic in ViewModels
- Use GoogleFonts.inter consistently
- Lints: flutter_lints
- Write small widgets and reuse them in widgets/

## Contributing

- Fork → branch → PR
- Keep PRs focused and small
- Include screenshots/GIFs for UI changes
- Put any DB changes in a single migration file or include SQL snippets in the PR description
- Open issues for discussions around schema, RLS, or auth flows

## Roadmap (tech)

- Posts feed + pagination
- Create/delete posts, optimistic UI
- Profile editing and avatar (storage)
- Follow/unfollow + feed from follow graph
- Realtime updates (channels on posts)
- Error/reporting and logging

---
Questions? Open an issue with logs (Supabase Auth/DB logs help a lot for auth/RLS problems).
