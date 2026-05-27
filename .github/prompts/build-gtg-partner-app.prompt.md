# GTG Partner — Complete App Build from Video Reference

You are building **GTG Partner** — a partner/venue-owner facing Flutter app from scratch. This app allows venue owners to register, manage their venues, view analytics, respond to reviews, and manage bookings. All data written by GTG Partner feeds into the **GTG** consumer app for display.

---

## PROJECT CONTEXT

### What is GTG Partner?
- A Flutter app for **venue owners/partners** (restaurants, cafes, bars, clubs, activities)
- Partners register their venues, upload photos, set pricing, manage hours, respond to reviews
- Uses the **same Firebase project** as GTG consumer app (`gtg-app`)
- Data written here (venues, offers, responses) is read by the GTG consumer app
- Think of it like: **GTG = Zomato/Yelp for users** | **GTG Partner = Zomato Partner/Yelp for Business**

### Relationship to GTG Consumer App
- **Shared Firebase project**: Same Firestore database, same Auth (but partner role), same Storage
- **Shared collections**: `venues`, `reviews`, `chatRooms`, `payments`, `bookings`
- **Partner-specific collections**: `partners`, `analytics`, `offers`, `staffMembers`
- Partners write to `venues` collection → GTG app reads and displays to users
- Users write reviews → Partners read and respond via GTG Partner
- Users make bookings/payments → Partners see and manage them

---

## VIDEO REFERENCE

There is a reference video that shows the app flow and UI. The video has been extracted into frames at:
```
docs/video/frames/frame_0001.jpg through frame_0075.jpg
```
The original video is at: `docs/video/GTG Video.mp4`

**IMPORTANT**: Analyze ALL 75 frames sequentially to understand:
1. The complete app flow (onboarding → dashboard → features)
2. UI design language, colors, typography, spacing
3. Navigation patterns and screen transitions
4. Every feature shown in the video

---

## STEP 0 — SETUP AGENTS, SKILLS & WORKFLOWS FIRST

Before building anything, generate the complete AI development environment. Create all of these:

### Agents — `.github/agents/AGENTS.md`

#### `flutter-ui` Agent
- Build pixel-perfect Flutter screens from video frame references
- Use design tokens, reuse widgets, follow patterns
- Tools: File read/write, image viewing, terminal (flutter analyze)

#### `firebase-backend` Agent
- Implement Firebase services, security rules, Cloud Functions
- Follow shared database schema (compatible with GTG consumer app)
- Tools: File read/write, terminal (firebase deploy, flutter test)

#### `state-management` Agent
- Create/update Providers, models, and service integrations
- Tools: File read/write, Dart MCP tools

#### `testing` Agent
- Write unit tests, widget tests, integration tests
- Tools: File read/write, terminal (flutter test)

#### `devops` Agent
- Build, deploy, CI/CD, Firebase Hosting
- Tools: Terminal, file read/write

### Skills — `.github/skills/`

#### `video-frame-to-flutter/SKILL.md`
- Analyze video frame images to extract UI design
- Map visual elements to Flutter widgets
- Identify colors, spacing, typography from frames
- Generate responsive Flutter screen code

#### `firebase-service/SKILL.md`
- Create service files with Firestore CRUD
- Real-time listeners, batch writes
- Compatible with shared GTG database schema

#### `model-creation/SKILL.md`
- Create Dart models matching Firestore schemas
- Equatable, fromJson/toJson, fromFirestore/toFirestore

#### `provider-wiring/SKILL.md`
- ChangeNotifier with loading/error/data states
- Wire to services, register in MultiProvider

#### `partner-feature/SKILL.md`
- Build partner-specific features (venue management, analytics, staff)
- Ensure data compatibility with GTG consumer app reads

### Copilot Instructions — `.github/copilot-instructions.md`
- Project: GTG Partner — Flutter venue management app for partners
- Stack: Flutter, Dart, Firebase (shared project with GTG), Provider, GoRouter
- Shared Firebase: Same project as GTG consumer app
- Architecture: screens, widgets, models, providers, services, theme, utils
- Naming: snake_case files, PascalCase classes, camelCase methods

---

## STEP 1 — PROJECT INITIALIZATION

```bash
flutter create gtg_partner --org com.gtg --platforms web,android,ios
cd gtg_partner
```

### pubspec.yaml dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  # State management
  provider: ^6.1.2
  # Navigation
  go_router: ^14.6.1
  # Firebase (SAME project as GTG consumer app)
  firebase_core: ^4.7.0
  firebase_auth: ^6.4.0
  cloud_firestore: ^6.3.0
  firebase_storage: ^13.3.0
  firebase_messaging: ^16.2.0
  firebase_analytics: ^12.3.0
  # UI utilities
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  fl_chart: ^0.69.0          # For analytics charts
  image_picker: ^1.2.1       # For venue photo uploads
  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.7
  url_launcher: ^6.3.2
  connectivity_plus: ^7.1.1
  uuid: ^4.5.3
```

### Firebase Configuration
- Run `flutterfire configure` connecting to the **existing** `gtg-app` Firebase project
- This ensures shared database, auth, and storage
- Partners authenticate with same Firebase Auth but have `role: "partner"` in their user document

---

## STEP 2 — ARCHITECTURE

```
lib/
├── main.dart
├── firebase_options.dart
├── utils/
│   └── router.dart                # GoRouter with auth guards
├── theme/
│   ├── app_colors.dart            # Design tokens from video
│   ├── app_tokens.dart            # Spacing, typography
│   └── app_theme.dart             # ThemeData
├── screens/
│   ├── auth/
│   │   ├── sign_in_screen.dart
│   │   ├── sign_up_screen.dart
│   │   ├── phone_input_screen.dart
│   │   └── otp_screen.dart
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   └── business_setup_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── analytics_screen.dart
│   ├── venues/
│   │   ├── venue_list_screen.dart
│   │   ├── venue_detail_screen.dart
│   │   ├── venue_edit_screen.dart
│   │   └── venue_add_screen.dart
│   ├── bookings/
│   │   ├── bookings_list_screen.dart
│   │   └── booking_detail_screen.dart
│   ├── reviews/
│   │   ├── reviews_list_screen.dart
│   │   └── review_respond_screen.dart
│   ├── chat/
│   │   ├── chat_list_screen.dart
│   │   └── chat_screen.dart
│   ├── offers/
│   │   ├── offers_list_screen.dart
│   │   └── offer_create_screen.dart
│   ├── staff/
│   │   ├── staff_list_screen.dart
│   │   └── staff_add_screen.dart
│   ├── earnings/
│   │   └── earnings_screen.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   └── profile_screen.dart
│   └── notifications/
│       └── notifications_screen.dart
├── widgets/
│   ├── app_primary_button.dart
│   ├── partner_bottom_nav.dart
│   ├── stat_card.dart
│   ├── venue_card.dart
│   ├── booking_card.dart
│   ├── review_card.dart
│   └── chart_widget.dart
├── models/
│   ├── partner.dart
│   ├── venue.dart
│   ├── booking.dart
│   ├── review.dart
│   ├── offer.dart
│   ├── staff_member.dart
│   ├── analytics_data.dart
│   ├── chat_room.dart
│   ├── chat_message.dart
│   └── notification.dart
├── providers/
│   ├── auth_provider.dart
│   ├── venue_provider.dart
│   ├── booking_provider.dart
│   ├── review_provider.dart
│   ├── offer_provider.dart
│   ├── analytics_provider.dart
│   ├── chat_provider.dart
│   ├── staff_provider.dart
│   └── notification_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── venue_service.dart
│   ├── booking_service.dart
│   ├── review_service.dart
│   ├── offer_service.dart
│   ├── analytics_service.dart
│   ├── chat_service.dart
│   ├── staff_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
└── utils/
    ├── constants.dart
    ├── validators.dart
    └── helpers.dart
```

---

## STEP 3 — SHARED DATABASE SCHEMA (ADDITIONS FOR PARTNER)

These collections are **added** to the existing GTG Firestore. The GTG consumer app already uses `users`, `venues`, `reviews`, `routes`, `chatRooms`.

### `partners` collection
```
/partners/{partnerId}
{
  uid: string,                    // Firebase Auth UID (same as users collection)
  businessName: string,
  businessEmail: string,
  businessPhone: string,
  gstNumber: string | null,      // For India
  tradeLicense: string | null,   // For Dubai
  role: "owner" | "manager" | "staff",
  venueIds: [string],            // Venues they manage
  isVerified: boolean,           // Admin approval
  isActive: boolean,
  bankDetails: {
    accountName: string,
    accountNumber: string,
    ifscCode: string | null,     // India
    iban: string | null,         // Dubai
    bankName: string
  },
  documents: {
    idProof: string | null,      // Storage URL
    businessProof: string | null // Storage URL
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `bookings` collection (NEW — shared with GTG app)
```
/bookings/{bookingId}
{
  id: string,
  userId: string,                 // GTG app user who booked
  venueId: string,
  partnerId: string,              // Venue owner
  date: timestamp,
  timeSlot: string,               // "18:00-20:00"
  partySize: number,
  status: "pending" | "confirmed" | "cancelled" | "completed" | "no-show",
  specialRequests: string | null,
  totalAmount: number,
  paymentId: string | null,       // Reference to payments collection
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `offers` collection (NEW)
```
/offers/{offerId}
{
  id: string,
  venueId: string,
  partnerId: string,
  title: string,
  description: string,
  discountType: "percentage" | "flat" | "bogo",
  discountValue: number,
  minOrderAmount: number | null,
  validFrom: timestamp,
  validUntil: timestamp,
  maxRedemptions: number | null,
  currentRedemptions: number,
  isActive: boolean,
  createdAt: timestamp
}
```

### `staffMembers` collection (NEW)
```
/venues/{venueId}/staff/{staffId}
{
  uid: string | null,             // If they have an account
  name: string,
  phone: string,
  email: string | null,
  role: "manager" | "host" | "server",
  permissions: [string],          // ["manage_bookings", "respond_reviews", "edit_venue"]
  isActive: boolean,
  createdAt: timestamp
}
```

### `analytics` collection (NEW — aggregated daily)
```
/venues/{venueId}/analytics/{date}
{
  date: string,                   // "2026-05-07"
  views: number,                  // How many GTG users viewed this venue
  clicks: number,                 // Click-throughs to detail
  bookings: number,
  revenue: number,
  avgRating: number,
  newReviews: number,
  offerRedemptions: number
}
```

### Updates to existing `venues` collection
Add these fields (written by Partner app, read by GTG app):
```
{
  // ... existing fields ...
  offers: [string],               // Active offer IDs (denormalized for GTG app reads)
  nextAvailableSlot: string | null, // "Today 7:00 PM" (denormalized)
  bookingEnabled: boolean,
  instantBooking: boolean,        // No confirmation needed
  menuUrl: string | null,         // PDF or link
  specialAnnouncement: string | null
}
```

---

## STEP 4 — FIRESTORE SECURITY RULES (ADDITIONS)

Add to existing `firestore.rules`:
```
// Partners: read/write own partner document
match /partners/{partnerId} {
  allow read, write: if request.auth != null && request.auth.uid == partnerId;
}

// Bookings: partners can read bookings for their venues
match /bookings/{bookingId} {
  allow read: if request.auth != null
    && (resource.data.userId == request.auth.uid
        || resource.data.partnerId == request.auth.uid);
  allow create: if request.auth != null
    && request.resource.data.userId == request.auth.uid;
  allow update: if request.auth != null
    && (resource.data.partnerId == request.auth.uid
        || resource.data.userId == request.auth.uid);
}

// Offers: only venue owner can manage
match /offers/{offerId} {
  allow read: if request.auth != null;
  allow create, update, delete: if request.auth != null
    && request.resource.data.partnerId == request.auth.uid;
}

// Venue staff: only venue owner can manage
match /venues/{venueId}/staff/{staffId} {
  allow read, write: if request.auth != null
    && get(/databases/$(database)/documents/venues/$(venueId)).data.ownerId == request.auth.uid;
}

// Venue analytics: only venue owner can read
match /venues/{venueId}/analytics/{date} {
  allow read: if request.auth != null
    && get(/databases/$(database)/documents/venues/$(venueId)).data.ownerId == request.auth.uid;
  allow write: if false; // Only Cloud Functions write analytics
}

// Venues: partners can write their own venues
match /venues/{venueId} {
  allow read: if request.auth != null && resource.data.isActive == true;
  allow create: if request.auth != null;
  allow update, delete: if request.auth != null
    && resource.data.ownerId == request.auth.uid;
}

// Reviews: partners can add responses
match /venues/{venueId}/reviews/{reviewId} {
  allow read: if request.auth != null;
  allow update: if request.auth != null
    && get(/databases/$(database)/documents/venues/$(venueId)).data.ownerId == request.auth.uid
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['ownerResponse', 'ownerResponseAt']);
}
```

---

## STEP 5 — KEY FEATURES TO BUILD

### 5.1 Authentication & Onboarding
- Phone OTP sign-in (same Firebase Auth as GTG)
- Email/Password sign-in
- Partner registration flow: business details, documents upload, bank details
- Admin approval flow (partner `isVerified` flag)

### 5.2 Dashboard
- Overview stats: today's bookings, revenue, rating, views
- Quick actions: add venue, view bookings, check reviews
- Charts: weekly/monthly trends (using `fl_chart`)
- Notifications badge

### 5.3 Venue Management
- Add new venue (name, category, address, photos, hours, pricing, amenities)
- Edit existing venue details
- Upload venue photos (Firebase Storage)
- Set operating hours
- Toggle venue active/inactive
- Manage menu (upload PDF or link)

### 5.4 Booking Management
- View incoming bookings (pending, confirmed, completed)
- Confirm/reject bookings
- View booking details (user info, party size, time, special requests)
- Mark bookings as completed/no-show

### 5.5 Reviews & Ratings
- View all reviews for owned venues
- Respond to reviews (owner response)
- Report inappropriate reviews
- Filter by rating, date

### 5.6 Offers & Promotions
- Create new offers (percentage/flat/BOGO)
- Set validity period
- Track redemptions
- Activate/deactivate offers

### 5.7 Analytics
- Daily/weekly/monthly venue views, clicks, bookings
- Revenue tracking
- Rating trends
- Comparison across venues (if multiple)

### 5.8 Chat (Customer Support)
- Respond to user queries (from GTG app support chat)
- Chat with GTG platform support
- Real-time messaging via Firestore

### 5.9 Staff Management
- Add staff members
- Assign roles and permissions
- Remove/deactivate staff

### 5.10 Earnings & Payouts
- View total earnings
- Transaction history
- Payout status
- Bank details management

### 5.11 Settings & Profile
- Edit business profile
- Notification preferences
- Account settings
- Help & support

---

## STEP 6 — CLOUD FUNCTIONS (Shared with GTG)

Create these Cloud Functions that serve BOTH apps:

```javascript
// functions/src/index.ts

// 1. Analytics aggregation (runs daily via Cloud Scheduler)
// Counts views, clicks, bookings for each venue and writes to analytics subcollection

// 2. Booking notification
// When a booking is created, notify the partner via FCM

// 3. Review notification
// When a review is posted, notify the venue owner via FCM

// 4. Payment order creation (Razorpay)
// Server-side order creation — never client-side

// 5. Partner verification notification
// When admin approves partner, send notification

// 6. Denormalization fan-out
// When venue details change, update denormalized fields in bookings, routes, etc.
```

---

## STEP 7 — DATA FLOW BETWEEN APPS

```
┌──────────────────┐         ┌──────────────────┐
│   GTG Partner    │         │    GTG (User)     │
│   (This App)     │         │   (Consumer App)  │
└────────┬─────────┘         └────────┬──────────┘
         │                            │
         │  WRITES                    │  READS
         │  • venues                  │  • venues
         │  • offers                  │  • offers
         │  • owner responses         │  • reviews + responses
         │  • booking status          │  • booking confirmations
         │  • venue photos            │  • venue photos
         │  • staff                   │  • available slots
         │                            │
         │         READS              │  WRITES
         │  • bookings (from users)   │  • bookings
         │  • reviews (from users)    │  • reviews
         │  • user messages           │  • chat messages
         │  • analytics               │  • payments
         │  • payment records         │  • user location
         │                            │
         └────────────┬───────────────┘
                      │
              ┌───────▼───────┐
              │   Firebase     │
              │  (Shared)      │
              │  • Firestore   │
              │  • Auth        │
              │  • Storage     │
              │  • FCM         │
              │  • Functions   │
              └───────────────┘
```

---

## STEP 8 — TODO LIST FOR IMPLEMENTATION

Use this todo list to work through the build one task at a time using the agents and skills generated in Step 0.

### Phase 0 — Setup & Configuration
- [ ] Run `flutter create` and set up project structure
- [ ] Add all dependencies to pubspec.yaml
- [ ] Run `flutterfire configure` with existing gtg-app project
- [ ] Set up folder structure (lib/screens, widgets, models, etc.)
- [ ] Generate agents, skills, workflows (from Step 0 above)
- [ ] Create design tokens by analyzing video frames
- [ ] Set up GoRouter with auth guards
- [ ] Set up Provider (MultiProvider in main.dart)

### Phase 1 — Authentication & Onboarding
- [ ] Analyze video frames for auth screens (identify frame numbers)
- [ ] Build sign-in screen from video reference
- [ ] Build sign-up screen from video reference
- [ ] Build phone input + OTP screens
- [ ] Implement AuthService (phone OTP, email, Google)
- [ ] Build partner registration flow (business details form)
- [ ] Build document upload screen
- [ ] Build bank details screen
- [ ] Implement partner registration service
- [ ] Add auth guards and role-based routing

### Phase 2 — Dashboard
- [ ] Analyze video frames for dashboard design
- [ ] Build dashboard screen with stat cards
- [ ] Build analytics charts (fl_chart)
- [ ] Implement AnalyticsService
- [ ] Wire dashboard to real-time Firestore data
- [ ] Add quick action buttons

### Phase 3 — Venue Management
- [ ] Analyze video frames for venue screens
- [ ] Build venue list screen
- [ ] Build venue add screen (multi-step form)
- [ ] Build venue edit screen
- [ ] Build venue detail/preview screen
- [ ] Implement VenueService (CRUD + photo upload)
- [ ] Implement StorageService for image uploads
- [ ] Wire to VenueProvider
- [ ] Test venue creation flow

### Phase 4 — Booking Management
- [ ] Analyze video frames for booking screens
- [ ] Build bookings list screen (tabs: pending/confirmed/completed)
- [ ] Build booking detail screen
- [ ] Implement BookingService (read + status updates)
- [ ] Wire to BookingProvider with real-time listeners
- [ ] Add FCM notifications for new bookings

### Phase 5 — Reviews & Responses
- [ ] Build reviews list screen
- [ ] Build review response screen
- [ ] Implement ReviewService (read + respond)
- [ ] Wire to ReviewProvider
- [ ] Add notification for new reviews

### Phase 6 — Offers & Promotions
- [ ] Build offers list screen
- [ ] Build offer creation screen
- [ ] Implement OfferService (CRUD)
- [ ] Wire to OfferProvider
- [ ] Ensure offers are visible in GTG consumer app

### Phase 7 — Chat
- [ ] Build chat list screen
- [ ] Build chat screen with real-time messages
- [ ] Implement ChatService (shared with GTG app)
- [ ] Wire to ChatProvider

### Phase 8 — Staff Management
- [ ] Build staff list screen
- [ ] Build staff add/edit screen
- [ ] Implement StaffService
- [ ] Wire to StaffProvider

### Phase 9 — Earnings
- [ ] Build earnings overview screen
- [ ] Build transaction history screen
- [ ] Implement EarningsService
- [ ] Wire to Provider

### Phase 10 — Settings & Profile
- [ ] Build settings screen
- [ ] Build profile edit screen
- [ ] Build notification preferences screen
- [ ] Wire to services

### Phase 11 — Cloud Functions
- [ ] Set up Firebase Functions project
- [ ] Implement analytics aggregation function
- [ ] Implement booking notification function
- [ ] Implement review notification function
- [ ] Implement payment order creation function
- [ ] Implement denormalization fan-out function
- [ ] Deploy and test all functions

### Phase 12 — Firestore Security Rules
- [ ] Add partner-specific rules to firestore.rules
- [ ] Add booking rules
- [ ] Add offer rules
- [ ] Add staff rules
- [ ] Add analytics rules (read-only for partners)
- [ ] Test all rules with Firebase emulator

### Phase 13 — Polish & Testing
- [ ] Add loading states (shimmer)
- [ ] Add error states and empty states
- [ ] Add form validation everywhere
- [ ] Write unit tests for services
- [ ] Write widget tests for critical flows
- [ ] Responsive testing (mobile + tablet + desktop)

### Phase 14 — Deploy
- [ ] flutter build web --release
- [ ] firebase deploy --only hosting (separate hosting site: gtg-partner.web.app)
- [ ] Verify all features work in production
- [ ] Set up Firebase Analytics
- [ ] Security audit

---

## EXECUTION INSTRUCTIONS

When running this prompt in a new empty project window:

1. **First**: Execute Step 0 to generate all agents, skills, and workflows
2. **Then**: Follow the todo list phase by phase
3. **For each task**: Use the appropriate agent+skill combination
4. **Video frames**: Always reference `docs/video/frames/` for UI design (copy the frames folder to the new project first)
5. **Firebase**: Connect to the EXISTING `gtg-app` Firebase project (do NOT create a new one)
6. **Test frequently**: Run `flutter analyze` after each screen, `flutter test` after each service

### Pre-requisites before running:
- Copy `docs/video/` folder from GTG project to the new GTG Partner project root
- Have Firebase CLI installed (`npm install -g firebase-tools`)
- Be logged into Firebase (`firebase login`)
- Have Flutter SDK installed and in PATH
- Have access to the `gtg-app` Firebase project

### How to use agents for each task:
```
@flutter-ui Build the dashboard screen using video frames 15-20 as reference
@firebase-backend Implement the VenueService with CRUD operations
@state-management Create VenueProvider and wire to VenueService
@testing Write unit tests for VenueService
@devops Deploy to Firebase Hosting
```

Mark each todo item as complete after finishing. Move to the next item only after the current one passes `flutter analyze` without errors.
