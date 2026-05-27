# GTG — Master Development Plan

## Summary
GTG is a venue discovery + route planning Flutter web app targeting India & Dubai (10K–100K users). Solo developer leveraging AI. Firebase Blaze backend, Mapbox maps, Razorpay payments, real-time features (chat, live location, push notifications).

---

## Decisions Log
- **Backend**: Firebase Blaze (pay-as-you-go) — shared project with upcoming GTG Partner app
- **Database**: Cloud Firestore (NoSQL)
- **Auth**: Phone OTP + Email/Password + Google Sign-In + Apple Sign-In (Firebase Auth)
- **Hosting**: Firebase Hosting (free subdomain → custom domain later)
- **Maps**: Mapbox (Flutter `mapbox_maps_flutter` package)
- **Payments**: Razorpay (India first) → add Stripe for Dubai later
- **Chat**: User↔User (friends) + Customer support chat
- **Real-time**: Firestore real-time listeners + FCM push notifications + live location via Firestore
- **Analytics**: Firebase Analytics (Google Analytics)
- **Content moderation**: Manual (report button + admin review)
- **Venue data**: API seed (Google Places) + venue owner self-registration (Partner app)

---

## Current State (What's Built)

### ✅ Screens (UI only, no backend)
- Auth flow: SignIn, SignUp, PhoneInput, OTP, Verified, GoodToGo
- Splash, NoInternet, LocationPermission
- Home/Discovery, Search (range slider), GTG Flow (5-step wizard)
- Routes (3 states: edit/active/progress)
- Settings, NotificationSettings

### ✅ Architecture
- Provider state management (AuthProvider, GtgFlowProvider)
- GoRouter (14 flat routes, no ShellRoute)
- Theme tokens (colors, typography, spacing, shadows)
- 4 reusable widgets (AppPrimaryButton, GtgBottomNav, GtgSmallLogo, VenueCard)

### ❌ Gaps
- No backend/services layer
- No auth guards on routes
- No real data (all mock/hardcoded)
- Figma CDN image URLs expire
- Dark theme not implemented
- No ShellRoute for persistent nav
- No form validation
- Disconnected auth flows (email vs phone)
- No tests

---

## Implementation Phases

### Phase A — Firebase Setup & Core Infrastructure (Days 1-2)
1. Create Firebase project `gtg-app` on Firebase console
2. Enable Blaze plan
3. Add Firebase to Flutter: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_analytics`
4. Run `flutterfire configure` for web platform
5. Set up Firebase Auth providers: Email/Password, Phone, Google, Apple
6. Create Firestore database (production mode) in `asia-south1` (Mumbai)
7. Deploy initial Firestore security rules (see security-plan.md)
8. Set up Firebase Hosting site
9. Replace `go_router` flat routes with `ShellRoute` for persistent bottom nav
10. Add route guards (redirect unauthenticated users to `/signin`)

### Phase B — Authentication & User Management (Days 2-4)
1. Create `AuthService` in `lib/services/auth_service.dart` wrapping Firebase Auth
2. Implement: `signInWithEmail()`, `signUpWithEmail()`, `signInWithPhone()`, `verifyOtp()`, `signInWithGoogle()`, `signInWithApple()`, `signOut()`
3. Refactor `AuthProvider` to use `AuthService` instead of mocks
4. Unify sign-in and phone-input flows (let user choose method)
5. Create `User` model → store profile in Firestore `users` collection on first login
6. Add form validation (email format, password strength 8+ chars, phone format)
7. Wire `AuthProvider.isAuthenticated` to GoRouter redirect for protected routes

### Phase C — Data Models & Firestore Integration (Days 4-6)
1. Define Firestore collections (see database-plan.md for schema)
2. Create models: `User`, `Venue`, `VenueCategory`, `Route`, `Stop`, `Notification`, `ChatMessage`, `ChatRoom`, `Review`, `Report`
3. Create services: `VenueService`, `RouteService`, `UserService`, `NotificationService`, `ChatService`
4. Create providers: `VenueProvider`, `RouteProvider`, `UserProvider`, `NotificationProvider`, `ChatProvider`
5. Replace `mockVenues` with Firestore reads
6. Implement Firestore real-time listeners for venues, notifications, chat

### Phase D — Venue Discovery & Search (Days 6-8)
1. Integrate Mapbox (`mapbox_maps_flutter`) into HomeScreen
2. Replace static map background with interactive Mapbox map
3. Show venue markers on map from Firestore data
4. Implement venue search with Firestore queries (by name, category, location radius)
5. Build `VenueDetailScreen` — photos, info, reviews, pricing, "navigate" CTA
6. Seed initial venue data via Cloud Function or manual Firestore import
7. Implement venue filtering (category, price range, rating, distance)

### Phase E — Route Planning (Days 8-10)
1. Integrate Mapbox Directions API for route calculation
2. Build `RouteOverviewScreen` — map with route polyline + stop markers
3. Build `RouteStopsScreen` — ordered list of stops with ETA
4. Wire GTG Flow wizard output → route generation (friends count, budget, modes, hours, range → filter venues → generate route)
5. Save routes to Firestore `routes` collection
6. Implement route variants (edit stops, reorder, remove)

### Phase F — Profile, Settings & Notifications (Days 10-11)
1. Build `EditProfileScreen` — name, photo, bio (upload to Firebase Storage)
2. Wire `SettingsScreen` to real user data from Firestore
3. Set up Firebase Cloud Messaging (FCM) for push notifications
4. Build `NotificationsScreen` — list from Firestore `notifications` collection
5. Implement notification preferences (WhatsApp toggle = external link, Push = FCM topic subscription)
6. Add "Refer & Earn" feature (generate shareable link with user referral code)

### Phase G — Chat & Real-time (Days 11-13)
1. Build chat UI: `ChatListScreen` (conversations) + `ChatScreen` (messages)
2. Implement Firestore-based chat (collection: `chatRooms` → subcollection: `messages`)
3. Real-time message streaming with Firestore snapshots
4. FCM push for new messages when app is backgrounded
5. Live location sharing: write user location to Firestore, read friends' locations in real-time
6. Support chat: create `support` chat room type, route to admin in Partner app

### Phase H — Payments (Days 13-14)
1. Add `razorpay_flutter` package
2. Create Razorpay account, get API keys
3. Build `PaymentScreen` — show venue pricing, booking summary
4. Server-side order creation via Cloud Function (NEVER create orders client-side)
5. Handle payment success/failure callbacks
6. Store payment records in Firestore `payments` collection
7. Implement booking confirmation flow

### Phase I — Polish, Assets & Testing (Days 14-16)
1. Replace all Figma CDN URLs with local assets or Firebase Storage URLs
2. Add loading skeletons (`shimmer` package) on all data-driven screens
3. Add error states and empty states on all screens
4. Implement dark theme
5. Add form validation everywhere
6. Write unit tests for services and models
7. Write widget tests for critical flows (auth, venue detail, payment)
8. Cross-browser testing (Chrome, Safari, Firefox)
9. Mobile responsive testing

### Phase J — Launch (Days 16-17)
1. `flutter build web --release`
2. `firebase deploy --only hosting`
3. Set up Firebase Analytics dashboards
4. Configure error reporting (Firebase Crashlytics for mobile, or custom for web)
5. Submit to Google Search Console
6. Verify security rules are production-ready
7. See launch-strategy-plan.md for full launch checklist

---

## Key Dependencies to Add

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | File/image uploads |
| `firebase_messaging` | Push notifications |
| `firebase_analytics` | Analytics |
| `mapbox_maps_flutter` | Maps |
| `razorpay_flutter` | Payments (India) |
| `google_sign_in` | Google auth |
| `sign_in_with_apple` | Apple auth |
| `image_picker` | Profile photo upload |
| `geolocator` | Device location |
| `geocoding` | Address ↔ coordinates |
| `url_launcher` | External links (WhatsApp, etc.) |
| `flutter_local_notifications` | Local notification display |
| `connectivity_plus` | Network status detection |

---

## File Structure (New/Modified)

```
lib/
├── main.dart                          # Add Firebase.initializeApp, new providers
├── models/
│   ├── user.dart                      # NEW
│   ├── venue.dart                     # MODIFY (add Firestore serialization)
│   ├── route_model.dart               # NEW
│   ├── stop.dart                      # NEW
│   ├── notification.dart              # NEW
│   ├── chat_room.dart                 # NEW
│   ├── chat_message.dart              # NEW
│   ├── review.dart                    # NEW
│   ├── report.dart                    # NEW
│   └── payment.dart                   # NEW
├── services/
│   ├── auth_service.dart              # NEW
│   ├── venue_service.dart             # NEW
│   ├── route_service.dart             # NEW
│   ├── user_service.dart              # NEW
│   ├── notification_service.dart      # NEW
│   ├── chat_service.dart              # NEW
│   ├── payment_service.dart           # NEW
│   └── location_service.dart          # NEW
├── providers/
│   ├── auth_provider.dart             # MODIFY (use AuthService)
│   ├── venue_provider.dart            # NEW
│   ├── route_provider.dart            # NEW
│   ├── user_provider.dart             # NEW
│   ├── notification_provider.dart     # NEW
│   ├── chat_provider.dart             # NEW
│   └── gtg_flow_provider.dart         # MODIFY (wire to route generation)
├── screens/
│   ├── venue_detail_screen.dart       # NEW
│   ├── edit_profile_screen.dart       # NEW
│   ├── notifications_screen.dart      # NEW
│   ├── payment_screen.dart            # NEW
│   ├── chat_list_screen.dart          # NEW
│   ├── chat_screen.dart               # NEW
│   ├── route_overview_screen.dart     # NEW
│   └── route_stops_screen.dart        # NEW
├── utils/
│   └── router.dart                    # MODIFY (ShellRoute + guards)
└── widgets/
    ├── loading_skeleton.dart          # NEW
    ├── error_state.dart               # NEW
    ├── empty_state.dart               # NEW
    └── map_widget.dart                # NEW
```
