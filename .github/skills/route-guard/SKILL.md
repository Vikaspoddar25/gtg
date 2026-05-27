---
description: "Skill: Add a new GoRouter route with auth guards and ShellRoute integration"
---

# Route Guard Skill

Add a new route to `lib/utils/router.dart` with proper auth guards and navigation integration.

## Inputs Required
- **Path** — e.g., `/venue-detail`
- **Route name** — e.g., `venueDetail` (camelCase)
- **Screen class** — e.g., `VenueDetailScreen`
- **Has bottom nav?** — Yes → ShellRoute, No → top-level
- **Is public?** — Yes → add to `_publicPaths`, No → default protected
- **Path parameters?** — e.g., `/venue-detail/:venueId`

## Steps

### 1. Create Screen File (if not exists)
Ensure the screen class exists in `lib/screens/`.

### 2. Add Route to router.dart

**For screens WITH bottom nav** (protected by default):
Add inside the `ShellRoute.routes` list in `lib/utils/router.dart`:
```dart
GoRoute(
  path: '/venue-detail/:venueId',
  name: 'venueDetail',
  builder: (context, state) {
    final venueId = state.pathParameters['venueId']!;
    return VenueDetailScreen(venueId: venueId);
  },
),
```

**For screens WITHOUT bottom nav** (full-page):
Add as a top-level `GoRoute` (outside ShellRoute):
```dart
GoRoute(
  path: '/venue-detail/:venueId',
  name: 'venueDetail',
  builder: (context, state) {
    final venueId = state.pathParameters['venueId']!;
    return VenueDetailScreen(venueId: venueId);
  },
),
```

**For PUBLIC screens** (no auth required):
Add the path to `_publicPaths`:
```dart
const _publicPaths = {
  '/signin',
  '/signup',
  // ... existing paths
  '/new-public-path',  // ← add here
};
```

### 3. Add Import
Add the screen import at the top of `router.dart`:
```dart
import 'package:gtg/screens/venue_detail_screen.dart';
```

### 4. Navigation Usage
From other screens, navigate using:
```dart
// Named route
context.goNamed('venueDetail', pathParameters: {'venueId': venue.id});

// Path-based
context.go('/venue-detail/${venue.id}');

// Push (adds to stack instead of replacing)
context.pushNamed('venueDetail', pathParameters: {'venueId': venue.id});
```

### 5. Verify
```bash
flutter analyze
```

## Current Route Structure
```
/ (GoRouter)
├── /signin          (public, no nav)
├── /signup           (public, no nav)
├── /phone-input      (public, no nav)
├── /otp              (public, no nav)
├── /verified         (public, no nav)
├── /good-to-go       (public, no nav)
├── /welcome-back     (public, no nav)
├── /no-internet      (public, no nav)
├── /location-permission (public, no nav)
└── ShellRoute (bottom nav)
    ├── /home
    ├── /search
    ├── /gtg-flow
    ├── /routes
    ├── /settings
    └── /notification-settings
```

## Quality Checklist
- [ ] Route path follows `/kebab-case` pattern
- [ ] Route name follows `camelCase` pattern
- [ ] Screen import added
- [ ] Path added to `_publicPaths` if public
- [ ] Path parameters extracted correctly from `state.pathParameters`
- [ ] Placed inside or outside `ShellRoute` correctly
- [ ] `flutter analyze` passes
