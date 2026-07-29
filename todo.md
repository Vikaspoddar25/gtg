# GTG — Todo List

Organized by phase. Each task maps to an **agent + skill** combination.
Use `@agent-name` with the relevant skill/workflow to complete each task.

---

## Phase 0 — Scaffold (DONE ✅)

- [x] Folder structure
- [x] Theme tokens (`app_colors.dart`, `app_tokens.dart`, `app_theme.dart`)
- [x] GoRouter setup with ShellRoute + auth guards
- [x] Provider wiring (`AuthProvider`, `GtgFlowProvider`)
- [x] Package dependencies (`pubspec.yaml`)
- [x] Firebase initialization (`firebase_options.dart`, `main.dart`)

---

## Phase 1 — Auth & Onboarding Screens (DONE ✅)

- [x] `87:26` — Splash / Welcome Back screen (`splash_screen.dart`)
- [x] `58:35` — Phone Input screen (`phone_input_screen.dart`)
- [x] `72:150` — OTP Verification screen (`otp_screen.dart`)
- [x] `87:104` — Auth Success / Verified screen (`verified_screen.dart`)
- [x] `92:7` — Good To Go screen (`good_to_go_screen.dart`)
- [x] `290:326` — No Internet / Error screen (`no_internet_screen.dart`)
- [x] `115:76` — Location Permission screen (`location_permission_screen.dart`)
- [x] Routes added in `router.dart`

---

## Phase 2 — Home & Discovery (DONE ✅)

- [x] `117:105` — Home / Discovery screen (`home_screen.dart`)
- [x] `369:968` — Search / Find screen (`search_screen.dart`)
- [x] Routes added in `router.dart`

---

## Phase A — Firebase Setup & Infrastructure

**Agent**: `@firebase-backend` | **Skills**: `firebase-service`, `route-guard`

- [x] Verify Firebase project config — `gtg-now` configured in `firebase_options.dart`
- [x] Deploy Firestore security rules — comprehensive rules in `firestore.rules`
- [ ] Configure Firebase Auth providers (Phone OTP, Email/Password, Google, Apple) — **MANUAL: Firebase Console**
- [x] Set up Firebase Storage bucket + storage security rules — `storage.rules` created
- [x] Set up Firebase Hosting site — `firebase.json` configured with CDN headers
- [ ] Configure Firebase Cloud Messaging for web push — **MANUAL: Firebase Console**

---

## Phase B — Authentication

**Agent**: `@firebase-backend`, `@state-management` | **Skills**: `firebase-service`, `provider-wiring`

- [x] Implement `AuthService` — `signInWithEmail()`, `signUpWithEmail()`, `signInWithPhone()`, `verifyOtp()`, `signInWithGoogle()`, `signInWithApple()`, `signOut()`
- [x] Refactor `AuthProvider` to use `AuthService` (replace mocks)
- [x] Add form validation to `SignInScreen` and `SignUpScreen` (email format, password 8+ chars)
- [x] Add phone number validation to `PhoneInputScreen`
- [x] Wire `AuthProvider.isAuthenticated` to GoRouter redirect
- [x] Create `User` model in `lib/models/user.dart` matching `plan-database.md` schema
- [x] Create `UserService` — profile CRUD handled by `DatabaseService`
- [ ] Test auth flows (sign in, sign up, phone OTP, sign out)

---

## Phase C — Data Models & Services

**Agent**: `@state-management`, `@firebase-backend` | **Skills**: `model-creation`, `firebase-service`, `provider-wiring`

- [x] Verify `Venue` model — complete with Equatable, Firestore serialization
- [x] Verify `Route` model — complete (`GtgRoute`)
- [x] Verify `Review` model — complete
- [x] Verify `ChatRoom` + `ChatMessage` models — complete
- [x] Verify `Notification` model — complete (`AppNotification`)
- [x] Verify `Payment` model — complete
- [x] Verify `Report` model — complete
- [x] Create `VenueService` — all CRUD + streams in `DatabaseService`
- [x] Create `RouteService` — CRUD + streams in `DatabaseService`
- [x] Create `NotificationService` — in `DatabaseService`
- [x] Create `ChatService` — rooms + messages + real-time in `DatabaseService`
- [x] Create `VenueProvider` and wire to `DatabaseService`
- [x] Create `RouteProvider` and wire to `DatabaseService`
- [x] Create `UserProvider` and wire to `DatabaseService`
- [x] Create `NotificationProvider` and wire to `DatabaseService`
- [x] Create `ChatProvider` and wire to `DatabaseService`
- [x] Register all new providers in `main.dart` `MultiProvider`

---

## Phase D — Venue Discovery & Search

**Agent**: `@flutter-ui`, `@firebase-backend` | **Skills**: `figma-to-flutter`, `firebase-service`

- [x] Integrate Mapbox map (`mapbox_maps_flutter`) into `HomeScreen` — mobile only; web uses a static placeholder (`MiniMapView`) until Mapbox's web SDK is stable
- [ ] Show venue markers on map from Firestore data
- [x] Build `VenueDetailScreen` — carousel, about, venue info grid, location map, add-to-route CTA
- [ ] Build `PaymentScreen` from Figma node `360:382`
- [ ] Build venue detail variants (nodes `360:452`, `369:914`, `369:1143`)
- [x] Implement venue search with filters — real Search screen (search bar, recent searches, results) wired to `VenueProvider.searchVenues`
- [x] Replace `mockVenues` with Firestore real-time data on `HomeScreen`
- [ ] Seed initial venue data (manual Firestore import or Cloud Function)

---

## Phase E — Route Planning

**Agent**: `@flutter-ui`, `@firebase-backend` | **Skills**: `figma-to-flutter`, `firebase-service`

- [ ] Integrate Mapbox Directions API for route calculation
- [ ] Build `RouteOverviewScreen` from Figma node `389:121` — map + route polyline + stops
- [x] Build `RouteStopsScreen` — ordered stop list with reorder/remove/regenerate, wired to real `RouteProvider` data
- [ ] Build route variants (nodes `389:761`, `389:861`, `389:965`, `389:1069`, `389:1173`, `389:1277`, `389:1369`)
- [x] Wire GTG Flow wizard → route generation (friends, budget, modes, hours, range → filter venues → route)
- [x] Implement route CRUD in `RouteProvider` (add/remove/reorder/regenerate stop, activate, complete)
- [x] Save/load routes from Firestore `routes` collection

---

## Phase F — Profile & Settings

**Agent**: `@flutter-ui`, `@firebase-backend` | **Skills**: `figma-to-flutter`, `firebase-service`

- [x] Build `EditProfileScreen` — name/mobile/email, change mobile number, delete account
- [ ] Build `ProfileScreen` from Figma node `214:4` (and variant `879:293`)
- [ ] Build `NotificationsScreen` from Figma node `293:352` (and variant `293:610`)
- [x] Wire `SettingsScreen` to real user data from Firestore
- [ ] Implement profile photo upload to Firebase Storage
- [ ] Set up FCM push notifications (web + mobile)
- [ ] Implement notification preferences (push toggle, WhatsApp external link)
- [x] Implement Refer & Earn feature (referral code + WhatsApp share link)

---

## Phase G — Chat & Real-time

**Agent**: `@flutter-ui`, `@firebase-backend` | **Skills**: `figma-to-flutter`, `firebase-service`

- [ ] Build `ChatListScreen` — list of conversations from Firestore `chatRooms`
- [ ] Build `ChatScreen` — real-time message UI with Firestore snapshots
- [ ] Implement user-to-user chat (direct messages between friends)
- [ ] Implement customer support chat type (route to admin/Partner app)
- [ ] FCM push for new messages when app is backgrounded
- [ ] Live location sharing — write/read user location to/from Firestore in real-time

---

## Phase H — Payments

**Agent**: `@firebase-backend` | **Skills**: `firebase-service`

- [ ] Add `razorpay_flutter` package to `pubspec.yaml`
- [ ] Create Razorpay account, get API keys
- [ ] Build `PaymentScreen` — venue pricing, booking summary, pay button
- [ ] Create Cloud Function for server-side Razorpay order creation
- [ ] Implement payment success/failure callbacks in app
- [ ] Store payment records in Firestore `payments` collection
- [ ] Implement booking confirmation flow (payment → booking → confirmation screen)

---

## Phase I — Polish & Testing

**Agent**: `@flutter-ui`, `@testing` | **Skills**: various

- [ ] Replace all Figma CDN image URLs with local assets or Firebase Storage URLs
- [ ] Add loading skeletons (`shimmer` package) on all data-driven screens
- [ ] Add error state widgets on all screens (retry button, error message)
- [ ] Add empty state widgets (no venues found, no routes, no messages)
- [ ] Implement dark theme (`AppTheme.dark` in `app_theme.dart`)
- [ ] Add form validation on all input screens
- [ ] Write unit tests for all models (fromJson, toJson, equality)
- [ ] Write unit tests for all services (using `fake_cloud_firestore`)
- [ ] Write widget tests for auth flow (sign in → home)
- [ ] Write widget tests for venue detail screen
- [ ] Write widget tests for payment flow
- [ ] Cross-browser testing (Chrome, Safari, Firefox)
- [ ] Mobile responsive testing (iOS Safari, Android Chrome)

---

## Phase J — Platform Configuration

### Android
- [ ] Replace default app icon (`android/app/src/main/res/`)
- [ ] Configure splash screen
- [ ] Set `minSdkVersion` and `targetSdkVersion` in `android/app/build.gradle.kts`
- [ ] Add required permissions to `AndroidManifest.xml`
- [ ] Test on emulator (API 26+) and physical device

### iOS
- [ ] Replace default app icon (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
- [ ] Configure launch screen (`ios/Runner/Base.lproj/LaunchScreen.storyboard`)
- [ ] Add required keys to `ios/Runner/Info.plist`
- [ ] Test on iOS Simulator and physical device (iOS 14+)

### Web
- [ ] Update `web/index.html` meta tags (title, description, theme-color)
- [ ] Update `web/manifest.json` (name, icons, background_color)
- [ ] Verify CORS headers if calling external APIs
- [ ] Check service worker / offline behaviour
- [ ] Test on Chrome, Firefox, and Safari

---

## Phase K — Deploy

**Agent**: `@devops` | **Workflow**: `workflow-deploy.prompt.md`

- [ ] Production Firestore security rules audit (verify all rules)
- [ ] Verify no secrets in client code
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all tests pass
- [ ] `flutter build web --release`
- [ ] `firebase deploy --only hosting` (to `gtg-now.web.app`)
- [ ] Set up Firebase Analytics dashboards
- [ ] Configure error reporting (Firebase Crashlytics or custom)
- [ ] Submit to Google Search Console
- [ ] Update `plan-launch-strategy.md` checklist
- [ ] Set up CI/CD (GitHub Actions or Codemagic)
- [ ] Release builds: APK, iOS, Web
- [ ] Deploy and submit to stores

---

## Ongoing

- [ ] Localisation (l10n) — add ARB files if multi-language support needed
- [ ] Accessibility audit (semantic labels, contrast ratios, touch target sizes)
- [ ] Performance profiling (`flutter run --profile`)
- [ ] Dependency updates (`flutter pub upgrade`)
