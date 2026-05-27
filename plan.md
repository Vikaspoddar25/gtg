# GTG — Implementation Plan

## 1. Project Overview

**GTG** is a cross-platform Flutter application targeting Web, Android, and iOS.  
The UI is driven by a Figma design file `wzigfuOA1J8AF0Mya8A1jr`.  
State is managed with **Provider** (can be upgraded to Riverpod or BLoC if complexity warrants).

Figma URL: https://www.figma.com/design/wzigfuOA1J8AF0Mya8A1jr/GTG?node-id=0-1&m=dev

---

## 2. Architecture

```
lib/
├── main.dart                  # Entry point; MaterialApp.router + MultiProvider
├── utils/
│   └── router.dart            # GoRouter — all named routes live here
├── theme/
│   ├── app_colors.dart        # Design token: colours
│   ├── app_tokens.dart        # Design token: spacing + typography
│   └── app_theme.dart         # Light/dark ThemeData
├── screens/                   # Full-page route destinations
├── widgets/                   # Reusable UI components
├── models/                    # Plain Dart data classes (Equatable)
├── providers/                 # ChangeNotifier classes per feature
└── services/                  # API calls, local storage, etc.
```

### State Management: Provider
- Chosen for its simplicity and official Flutter support.
- Each feature gets its own `ChangeNotifier` registered in `main.dart`.
- Can be swapped for Riverpod or BLoC if requirements grow.

---

## 3. Figma Layer Map

All frames from Figma file `wzigfuOA1J8AF0Mya8A1jr`:

### Auth & Onboarding

| Node ID | Frame Name | Screen | Status |
|---------|-----------|--------|--------|
| `87:26` | iPhone 14 & 15 Pro Max - 6 | Splash / Welcome Back | ✅ Built (`splash_screen.dart`) |
| `58:35` | iPhone 14 & 15 Pro Max - 4 | Phone Input | ✅ Built (`phone_input_screen.dart`) |
| `72:150` | iPhone 14 & 15 Pro Max - 5 | OTP Verification | ✅ Built (`otp_screen.dart`) |
| `87:104` | iPhone 14 & 15 Pro Max - 7 | Auth Success (Verified) | ✅ Built (`verified_screen.dart`) |
| `92:7` | iPhone 14 & 15 Pro Max - 8 | "Now you are Good To Go" | ✅ Built (`good_to_go_screen.dart`) |
| `290:326` | iPhone 14 & 15 Pro Max - 22 | No Internet / Error | ✅ Built (`no_internet_screen.dart`) |
| `115:76` | iPhone 14 & 15 Pro Max - 10 | Location Permission | ✅ Built (`location_permission_screen.dart`) |

### Home & Discovery

| Node ID | Frame Name | Screen | Status |
|---------|-----------|--------|--------|
| `117:105` | iPhone 14 & 15 Pro Max - 11 | Home / Discovery | ✅ Built (`home_screen.dart`) |

### Profile & Settings

| Node ID | Frame Name | Screen | Status |
|---------|-----------|--------|--------|
| `214:4` | iPhone 14 & 15 Pro Max - 13 | Settings / Profile | 🔲 Not started |
| `879:293` | iPhone 14 & 15 Pro Max - 42 | Settings / Profile (variant) | 🔲 Not started |
| `279:84` | iPhone 14 & 15 Pro Max - 19 | Edit Profile | 🔲 Not started |
| `293:352` | iPhone 14 & 15 Pro Max - 23 | Notifications (empty state) | 🔲 Not started |
| `293:610` | iPhone 14 & 15 Pro Max - 24 | Notifications (variant) | 🔲 Not started |

### Venue Detail

| Node ID | Frame Name | Screen | Status |
|---------|-----------|--------|--------|
| `349:144` | iPhone 14 & 15 Pro Max - 27 | Venue Detail | 🔲 Not started |
| `360:382` | iPhone 14 & 15 Pro Max - 28 | Payment / Pricing | 🔲 Not started |
| `360:452` | iPhone 14 & 15 Pro Max - 29 | Venue Detail (variant) | 🔲 Not started |
| `369:914` | iPhone 14 & 15 Pro Max - 30 | Venue Detail (variant) | 🔲 Not started |
| `369:968` | iPhone 14 & 15 Pro Max - 31 | Search / Find | ✅ Built (`search_screen.dart`) |
| `369:1143` | iPhone 14 & 15 Pro Max - 32 | Venue Detail (way01) | 🔲 Not started |

### Route / Trip

| Node ID | Frame Name | Screen | Status |
|---------|-----------|--------|--------|
| `389:121` | iPhone 14 & 15 Pro Max - 33 | Route Overview | 🔲 Not started |
| `389:589` | iPhone 14 & 15 Pro Max - 34 | Route with Stops (3 stops) | 🔲 Not started |
| `389:761` | iPhone 14 & 15 Pro Max - 35 | Route with Stops (variant) | 🔲 Not started |
| `389:861` | iPhone 14 & 15 Pro Max - 36 | Route with Stops (variant) | 🔲 Not started |
| `389:965` | iPhone 14 & 15 Pro Max - 37 | Route (variant) | 🔲 Not started |
| `389:1069` | iPhone 14 & 15 Pro Max - 38 | Route (variant) | 🔲 Not started |
| `389:1173` | iPhone 14 & 15 Pro Max - 39 | Route (variant) | 🔲 Not started |
| `389:1277` | iPhone 14 & 15 Pro Max - 40 | Route Single Stop | 🔲 Not started |
| `389:1369` | iPhone 14 & 15 Pro Max - 41 | Route with "Stop Here" CTA | 🔲 Not started |

---

## 4. Roadmap

### Phase 0 — Scaffold (DONE ✅)
- [x] Folder structure (`screens/`, `widgets/`, `models/`, `theme/`, `services/`, `utils/`, `providers/`)
- [x] Theme tokens (colours, typography, spacing)
- [x] GoRouter setup with initial routes
- [x] Provider wiring in `main.dart` (`AuthProvider`)
- [x] Package dependencies added (`provider`, `go_router`, `flutter_svg`, `cached_network_image`, `shimmer`, `intl`, `equatable`)

### Phase 1 — Auth & Onboarding Screens (DONE ✅)
- [x] `87:26` — Splash screen (`splash_screen.dart`)
- [x] `58:35` — Phone Input screen (`phone_input_screen.dart`)
- [x] `72:150` — OTP Verification screen (`otp_screen.dart`)
- [x] `87:104` — Auth Success / Verified screen (`verified_screen.dart`)
- [x] `92:7` — "Now you are Good To Go" screen (`good_to_go_screen.dart`)
- [x] `290:326` — No Internet / Error screen (`no_internet_screen.dart`)
- [x] `115:76` — Location Permission screen (`location_permission_screen.dart`)

### Phase 2 — Home & Discovery (DONE ✅)
- [x] `117:105` — Home / Discovery screen (`home_screen.dart`)
- [x] `369:968` — Search / Find screen (`search_screen.dart`)

### Phase 3 — Profile & Settings
- [ ] `214:4` — Settings / Profile screen → `profile_screen.dart`
- [ ] `879:293` — Settings / Profile variant (handle in same file or separate)
- [ ] `279:84` — Edit Profile screen → `edit_profile_screen.dart`
- [ ] `293:352` — Notifications empty state → `notifications_screen.dart`
- [ ] `293:610` — Notifications variant (handle in same file)

### Phase 4 — Venue Detail & Payment
- [ ] `349:144` — Venue Detail screen → `venue_detail_screen.dart`
- [ ] `360:382` — Payment / Pricing screen → `payment_screen.dart`
- [ ] `360:452` / `369:914` / `369:1143` — Venue Detail variants (states within `venue_detail_screen.dart`)

### Phase 5 — Route / Trip Flow
- [ ] `389:121` — Route Overview screen → `route_overview_screen.dart`
- [ ] `389:589` — Route with Stops → `route_stops_screen.dart`
- [ ] `389:761` / `389:861` / `389:965` / `389:1069` / `389:1173` — Route variants (states within route screens)
- [ ] `389:1277` — Route Single Stop variant
- [ ] `389:1369` — Route with "Stop Here" CTA variant

### Phase 6 — Feature Implementation
- [ ] Define all data models in `lib/models/` (Venue, Route, Stop, User, Notification)
- [ ] Implement service layer (`lib/services/`) — REST or GraphQL
- [ ] Wire state: create `ChangeNotifier` classes per feature
- [ ] Add routes to `router.dart` for all new screens

### Phase 7 — Responsiveness
- [ ] Use `LayoutBuilder` / `MediaQuery` breakpoints:
  - Mobile: `< 600 dp`
  - Tablet: `600–1 279 dp`
  - Desktop/Web: `≥ 1 280 dp`
- [ ] `AppSpacing.pagePadding(context)` already adapts horizontal margins
- [ ] Test on Chrome (web), Android emulator, iOS simulator

### Phase 8 — Platform Configuration
| Platform | Tasks |
|----------|-------|
| Android | App icon, splash screen, permissions, `minSdkVersion` |
| iOS | App icon, splash screen, `Info.plist` permissions |
| Web | `index.html` meta tags, PWA manifest, CORS headers |

### Phase 9 — Quality & Release
- [ ] Unit tests for models and services
- [ ] Widget tests for key UI components
- [ ] Integration tests (golden tests for responsive layouts)
- [ ] CI/CD pipeline (GitHub Actions or Codemagic)
- [ ] Release builds: `flutter build apk`, `flutter build ios`, `flutter build web`

---

## 5. Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `go_router` | Declarative, URL-based navigation |
| `flutter_svg` | SVG assets from Figma |
| `cached_network_image` | Efficient image loading |
| `shimmer` | Loading skeleton UI |
| `intl` | Localisation & date formatting |
| `equatable` | Value equality for data models |

---

## 6. Responsive Breakpoints

```dart
// Inside any widget:
final width = MediaQuery.sizeOf(context).width;
final isMobile  = width < 600;
final isTablet  = width >= 600 && width < 1280;
final isDesktop = width >= 1280;
```

---

## 7. Design Token Update Process
1. Use Figma file `wzigfuOA1J8AF0Mya8A1jr` with node IDs from the layer map above.
2. Run `get_design_context` → extract colours, fonts, spacing.
3. Update `lib/theme/app_colors.dart` and `lib/theme/app_tokens.dart`.
4. Run `flutter run -d chrome` to validate visually.
