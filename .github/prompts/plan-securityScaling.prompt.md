# GTG — Security & Scaling Plan

## OWASP Top 10 — Applied to Flutter Web + Firebase

### 1. Broken Access Control
**Risk**: Users accessing other users' data, admin functions, or premium features without authorization.

**Mitigations**:
- Firestore Security Rules enforce per-document access control
- `request.auth.uid == resource.data.userId` pattern on all user-owned collections
- GoRouter redirect guard: unauthenticated → `/signin`
- Admin operations only via Cloud Functions with admin SDK (bypasses security rules server-side)
- Never trust client-side role checks — verify in security rules

**Firestore Security Rules** (deploy via `firestore.rules`):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: read/write own document only
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Venues: anyone authenticated can read active venues
    match /venues/{venueId} {
      allow read: if request.auth != null && resource.data.isActive == true;
      allow write: if request.auth != null && resource.data.ownerId == request.auth.uid;
    }

    // Reviews: subcollection of venues
    match /venues/{venueId}/reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    // Routes: creator + shared users can read
    match /routes/{routeId} {
      allow read: if request.auth != null
        && (resource.data.userId == request.auth.uid
            || request.auth.uid in resource.data.sharedWith);
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    // Chat rooms: only participants
    match /chatRooms/{roomId} {
      allow read, write: if request.auth != null
        && request.auth.uid in resource.data.participants;

      match /messages/{messageId} {
        allow read: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(roomId)).data.participants;
        allow create: if request.auth != null
          && request.resource.data.senderId == request.auth.uid;
      }
    }

    // Notifications: user's own subcollection
    match /users/{userId}/notifications/{notifId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Payments: read own, create via Cloud Function only
    match /payments/{paymentId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Only Cloud Functions (admin SDK) can write
    }

    // Reports: anyone can create, only admin reads
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read, update: if false; // Admin via Cloud Function only
    }

    // Config: anyone can read
    match /config/{configId} {
      allow read: if true;
      allow write: if false; // Admin only via Cloud Function
    }

    // Live locations: route participants only
    match /liveLocations/{sessionId} {
      allow read: if request.auth != null; // Filtered by routeId client-side
      allow write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 2. Cryptographic Failures
**Risk**: Sensitive data exposed in transit or at rest.

**Mitigations**:
- Firebase Hosting enforces HTTPS (auto SSL)
- Firestore encrypts data at rest (Google-managed encryption)
- Never store passwords — Firebase Auth handles hashing
- Razorpay API secret key stored in Cloud Function environment variables (NEVER client-side)
- Mapbox access token: use public/restricted token (scope to specific URLs)

### 3. Injection
**Risk**: XSS, NoSQL injection via user inputs.

**Mitigations**:
- Firestore is not SQL — traditional SQL injection doesn't apply
- **Firestore security rules validate data types**:
  ```
  allow create: if request.resource.data.comment is string
    && request.resource.data.comment.size() <= 1000
    && request.resource.data.rating is number
    && request.resource.data.rating >= 1
    && request.resource.data.rating <= 5;
  ```
- Flutter's widget tree naturally escapes HTML (no innerHTML equivalent)
- Sanitize user-generated content before display (strip HTML tags from text fields)
- Use `Uri.encodeComponent()` for any URL parameters

### 4. Insecure Design
**Risk**: Business logic flaws.

**Mitigations**:
- Payment order creation via Cloud Function (not client-side)
- Payment verification via server-side signature check
- Rate limit OTP: Firebase Auth default is 10 SMS/IP/hour (configurable)
- Referral code validation server-side (Cloud Function)
- Venue rating calculated server-side (Cloud Function trigger on review write)

### 5. Security Misconfiguration
**Risk**: Open Firestore, debug mode in production, default configs.

**Mitigations**:
- NEVER use `allow read, write: if true;` in production Firestore rules
- Remove `flutter run` debug banner in release
- Set `kReleaseMode` checks for debug logging
- Firebase App Check — verify requests come from legitimate app instances
- Lock down Firebase Console access (use IAM roles)

### 6. Vulnerable Components
**Risk**: Outdated packages with known vulnerabilities.

**Mitigations**:
- Run `flutter pub outdated` monthly
- Use `dependabot` or `renovate` for automated dependency updates
- Pin major versions in `pubspec.yaml` (use `^` for minor/patch)
- Review Firebase SDK changelogs before upgrading

### 7. Auth Failures
**Risk**: Brute force, credential stuffing, session hijacking.

**Mitigations**:
- Firebase Auth handles session management (JWT tokens, auto-refresh)
- Phone OTP rate limiting (Firebase built-in)
- Email enumeration protection: enable in Firebase Console
- Password requirements: enforce minimum 8 characters in client-side validation AND Cloud Function
- Google/Apple Sign-In: OAuth 2.0 handled by providers
- Session timeout: Firebase Auth tokens expire after 1 hour, auto-refresh if active

### 8. Data Integrity Failures
**Risk**: Unsigned or unverified data updates.

**Mitigations**:
- Razorpay webhook signature verification in Cloud Function
- Firestore security rules validate data structure on writes
- Cloud Function verifies payment status with Razorpay API before updating booking status

### 9. Logging & Monitoring
**Risk**: Attacks go undetected.

**Mitigations**:
- Firebase Analytics for user behavior
- Cloud Function logs for server-side operations
- Firebase Alerts for billing spikes
- Set up budget alerts: $10, $25, $50
- Log failed auth attempts (Firebase Auth already logs these)
- Monitor Firestore usage in Firebase Console

### 10. Server-Side Request Forgery (SSRF)
**Risk**: Server making requests to internal resources.

**Mitigations**:
- Cloud Functions don't accept arbitrary URLs from client
- Validate and whitelist external API endpoints (Razorpay, Mapbox, Google Places)
- Don't proxy arbitrary client requests through Cloud Functions

---

## Firebase App Check

Enable App Check to prevent API abuse:

1. Register app with reCAPTCHA Enterprise (web)
2. Enable App Check in Firebase Console
3. Enforce on Firestore, Storage, Cloud Functions
4. Blocks requests not from legitimate app instances

```dart
// main.dart
await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaEnterpriseProvider('RECAPTCHA_SITE_KEY'),
);
```

---

## API Key Security

| Key | Storage | Exposure |
|-----|---------|----------|
| Firebase config (apiKey, authDomain, etc.) | `firebase_options.dart` (client) | Public — this is by design, secured by security rules + App Check |
| Mapbox public token | `main.dart` or env config | Public — restricted by domain/bundle ID in Mapbox dashboard |
| Razorpay Key ID (public) | Client-side `PaymentScreen` | Public — only used to initialize checkout |
| Razorpay Key Secret | Cloud Function env variable | NEVER in client code |
| Google Places API Key | Cloud Function env variable | Server-side only, restricted by IP |
| FCM Server Key | Cloud Function env variable | Server-side only |

---

## Rate Limiting

| Action | Limit | Implementation |
|--------|-------|----------------|
| Phone OTP | 10 per IP per hour | Firebase Auth built-in |
| Login attempts | 100 per IP per hour | Firebase Auth built-in |
| Review creation | 1 per venue per user per 24h | Firestore security rule |
| Report creation | 5 per user per hour | Cloud Function rate limiter |
| Chat messages | 60 per user per minute | Cloud Function rate limiter |
| Payment creation | 10 per user per hour | Cloud Function rate limiter |

---

## Scaling Architecture

### Current (0–10K users)
```
Flutter Web App
    ↓ HTTPS
Firebase Hosting (CDN)
    ↓
Firebase Auth → Firestore → Cloud Functions
                              ↓
                         Razorpay API
                         Mapbox API
                         Google Places API
```
- All services auto-scale
- Single Firestore database
- Cloud Functions scale 0→1000 instances

### Growth (10K–100K users)
- Same architecture — Firebase handles this scale
- Add Firestore composite indexes for query performance
- Use distributed counters for high-write fields
- Enable Firestore bundles for public data caching
- CDN serves static assets efficiently
- Monitor costs, optimize read-heavy queries

### Enterprise (100K+ users)
- Consider Firestore multi-region for disaster recovery
- Add Cloud CDN for API responses
- Use BigQuery export for analytics (don't query Firestore for analytics)
- Consider microservices for complex business logic (Cloud Run)
- Add Redis (Memorystore) for caching hot data
- Load testing with `k6` or `artillery`

---

## Web-Specific Security Headers

Configure in `firebase.json`:

```json
{
  "hosting": {
    "headers": [
      {
        "source": "**",
        "headers": [
          { "key": "X-Content-Type-Options", "value": "nosniff" },
          { "key": "X-Frame-Options", "value": "DENY" },
          { "key": "X-XSS-Protection", "value": "1; mode=block" },
          { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
          { "key": "Permissions-Policy", "value": "geolocation=(self), camera=(), microphone=()" },
          {
            "key": "Content-Security-Policy",
            "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://apis.google.com https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://*.googleapis.com https://*.firebaseio.com https://*.firebase.com wss://*.firebaseio.com https://api.mapbox.com https://api.razorpay.com; frame-src https://accounts.google.com https://api.razorpay.com"
          }
        ]
      }
    ]
  }
}
```

---

## Data Privacy & GDPR

1. **Account deletion**: Implement via Cloud Function — deletes:
   - Firebase Auth account
   - Firestore `users/{uid}` document
   - All subcollections (notifications, etc.)
   - Firebase Storage files (profile photos)
   - Anonymize reviews/chat messages (replace userId with "deleted")

2. **Data export**: Let users download their data (GDPR right)
   - Cloud Function collects user data from all collections → generates JSON → sends download link

3. **Consent**: Cookie consent banner for web (use `cookie_consent` or custom)

4. **Privacy Policy**: Must disclose:
   - What data is collected
   - How it's used
   - Third-party services (Firebase, Mapbox, Razorpay, Google)
   - Data retention periods
   - How to request deletion

---

## Incident Response

1. **Data breach detected**:
   - Rotate all API keys immediately
   - Review Firestore security rules for gaps
   - Notify affected users (if personal data exposed)
   - Report to relevant authority (CERT-In for India, DPA for Dubai)

2. **DDoS / abuse**:
   - Firebase App Check blocks non-app traffic
   - Firebase Auth rate limits prevent brute force
   - Set budget alerts to detect unusual spikes
   - Enable Cloud Armor (if using Cloud Run)

3. **Payment fraud**:
   - Server-side payment verification (signature check)
   - Monitor for unusual payment patterns
   - Razorpay dashboard has fraud detection built-in
