# GTG — Copilot Instructions

## Project
**GTG** — A venue discovery + route planning Flutter web app targeting India & Dubai.

## Tech Stack
- **Framework**: Flutter 3.x, Dart 3.11+
- **State Management**: Provider (ChangeNotifier) — one per feature
- **Navigation**: GoRouter with ShellRoute (persistent bottom nav) + auth guards
- **Backend**: Firebase Blaze (pay-as-you-go)
  - Firebase Auth (Phone OTP, Email/Password, Google, Apple)
  - Cloud Firestore (NoSQL, region: `asia-south1`)
  - Firebase Storage (user uploads, venue images)
  - Firebase Cloud Messaging (push notifications)
  - Firebase Hosting (`gtg-app.web.app`)
  - Firebase Analytics
- **Maps**: Mapbox (`mapbox_maps_flutter`)
- **Payments**: Razorpay (India) — server-side order creation only
- **Related App**: GTG Partner (venue owner app) — shares same Firebase project

## Architecture
```
lib/
├── main.dart              # Entry point, MultiProvider, MaterialApp.router
├── firebase_options.dart  # FlutterFire generated config
├── screens/               # Full-page route destinations (one file per screen)
├── widgets/               # Reusable UI components
├── models/                # Dart data classes (Equatable, Firestore serialization)
├── providers/             # ChangeNotifier classes (one per feature)
├── services/              # Firebase/API service wrappers
├── theme/                 # Design tokens (colors, typography, spacing, ThemeData)
└── utils/                 # Router, helpers, constants, validators
```

## Design System
- **Colors**: `lib/theme/app_colors.dart` — `AppColors.primary`, `.textPrimary`, `.surface`, etc.
- **Tokens**: `lib/theme/app_tokens.dart` — spacing, typography, borders, shadows
- **Theme**: `lib/theme/app_theme.dart` — `AppTheme.light`, `AppTheme.dark`
- **Figma file**: `wzigfuOA1J8AF0Mya8A1jr`
- Never hardcode colors or spacing — always use design tokens

## Reusable Widgets
- `AppPrimaryButton` — primary CTA button
- `GtgBottomNav` — bottom navigation bar (used in ShellRoute)
- `GtgSmallLogo` — GTG logo
- `VenueCard` — venue list item card

## Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Methods/variables**: `camelCase`
- **Routes**: path `/kebab-case`, name `camelCase`
- **Firestore collections**: `camelCase` (e.g., `chatRooms`)

## Key Patterns
- **Services** accept optional `FirebaseFirestore` parameter for testability
- **Providers** expose `isLoading`, `error`, `hasError`, and data getters
- **Models** use Equatable, have `fromFirestore`/`toFirestore` + `fromJson`/`toJson` + `copyWith`
- **Routes** use GoRouter redirect for auth guards; public paths listed in `_publicPaths`
- **Firestore writes** always set `updatedAt: FieldValue.serverTimestamp()`

## Security Rules
- Follow patterns in `plan-security-scaling.md`
- User documents: owner read/write only
- Venues: authenticated read, owner write
- Never expose API keys or secrets in client code
- Payment orders created server-side via Cloud Functions only

## Plans & References
- `plan-master-development.md` — phases, decisions, current state
- `plan-database.md` — all Firestore collection schemas
- `plan-security-scaling.md` — OWASP mitigations, security rules
- `plan-launch-strategy.md` — deployment checklist, hosting config
- `todo.md` — current task list

## Testing
- Unit tests: services and models (use `fake_cloud_firestore`)
- Widget tests: critical flows (auth, venue detail, payment)
- Run: `flutter test`
- Verify: `flutter analyze` (zero issues before any commit)
