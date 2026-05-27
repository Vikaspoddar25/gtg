# GTG — Database Plan (Cloud Firestore)

## Overview
- **Database**: Cloud Firestore (NoSQL, document-oriented)
- **Region**: `asia-south1` (Mumbai) — closest to India users, reasonable latency for Dubai
- **Shared project**: Same Firebase project used by GTG user app + GTG Partner app
- **Billing**: Blaze plan (pay-as-you-go)

---

## Why Firestore (Not Alternatives)

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Firestore** | Real-time listeners, offline sync, scales automatically, integrated with Firebase Auth/FCM/Hosting, generous free tier (50K reads/20K writes/day) | NoSQL requires denormalization, complex queries limited, no JOINs | ✅ Best fit for real-time venue discovery + chat + live location |
| **Supabase (Postgres)** | SQL, relational, Row Level Security, open-source | Separate from Firebase ecosystem, another vendor to manage | ❌ Adds complexity when already using Firebase for auth/hosting |
| **Firebase Realtime DB** | Simpler, cheaper, faster for basic real-time | No complex queries, flat JSON structure, less scalable | ❌ Firestore is the modern replacement |
| **MongoDB Atlas** | Flexible, good for geospatial queries | Another service to manage, no Firebase integration | ❌ Unnecessary complexity |

---

## Collection Schema

### 1. `users`
**Path**: `/users/{userId}`

```
{
  uid: string,                    // Firebase Auth UID (document ID)
  displayName: string,
  email: string | null,
  phone: string | null,
  photoUrl: string | null,        // Firebase Storage URL
  bio: string | null,
  authProvider: "email" | "phone" | "google" | "apple",
  referralCode: string,           // Unique, auto-generated
  referredBy: string | null,      // Referral code of inviter
  notificationPrefs: {
    push: boolean,
    whatsapp: boolean
  },
  location: {                     // Last known location
    lat: number,
    lng: number,
    updatedAt: timestamp
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Indexes**: `referralCode` (unique), `email`
**Security**: Users can read/write only their own document. Partner app admins can read any user.

---

### 2. `venues`
**Path**: `/venues/{venueId}`

```
{
  id: string,                     // Auto-generated document ID
  name: string,
  description: string,
  category: string,               // "restaurant" | "cafe" | "bar" | "club" | "activity" | ...
  subcategory: string | null,
  status: "open" | "closed" | "busy",
  rating: number,                 // 0.0 - 5.0 (aggregated from reviews)
  reviewCount: number,
  avgPricePerPerson: number,      // In INR (convert for Dubai display)
  currency: "INR" | "AED",
  images: [string],               // Firebase Storage URLs
  coverImage: string,
  address: {
    line1: string,
    line2: string | null,
    city: string,                  // "Mumbai" | "Dubai" | etc.
    state: string | null,
    country: "IN" | "AE",
    pincode: string
  },
  location: GeoPoint,             // Firestore GeoPoint for geo-queries
  geohash: string,                // For geo-radius queries (use `geoflutterfire2`)
  contact: {
    phone: string | null,
    email: string | null,
    website: string | null
  },
  hours: {                        // Operating hours
    mon: { open: string, close: string } | null,
    tue: { open: string, close: string } | null,
    // ... etc
  },
  amenities: [string],            // ["wifi", "parking", "outdoor", "pet-friendly"]
  tags: [string],                 // For search/filter
  ownerId: string,                // Reference to Partner app user
  isVerified: boolean,            // Admin-verified venue
  isActive: boolean,              // Soft delete
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Indexes**:
- Composite: `city` + `category` + `rating` (descending)
- Composite: `city` + `avgPricePerPerson`
- `geohash` (for radius queries)
- `ownerId`
- `isActive` + `city`

**Security**: Anyone authenticated can read active venues. Only venue owner (via Partner app) or admin can write.

---

### 3. `reviews`
**Path**: `/venues/{venueId}/reviews/{reviewId}`

```
{
  id: string,
  userId: string,
  userName: string,               // Denormalized for read performance
  userPhotoUrl: string | null,    // Denormalized
  rating: number,                 // 1-5
  comment: string,
  images: [string] | null,
  isReported: boolean,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Security**: Auth users can create. Users can edit/delete own reviews. Admin can delete any.

---

### 4. `routes`
**Path**: `/routes/{routeId}`

```
{
  id: string,
  userId: string,                 // Creator
  name: string | null,            // Optional route name
  stops: [{
    venueId: string,
    venueName: string,            // Denormalized
    venueImage: string,           // Denormalized
    order: number,
    estimatedDuration: number,    // Minutes at this stop
    lat: number,
    lng: number
  }],
  preferences: {
    numberOfFriends: number,
    budgetPerPerson: number,
    selectedModes: [string],      // ["food", "drinks", "adventure", ...]
    hoursToSpend: number,
    rangeKm: number
  },
  totalDistance: number,           // Km
  totalDuration: number,          // Minutes
  status: "draft" | "active" | "completed" | "cancelled",
  sharedWith: [string],           // User IDs of friends
  polyline: string | null,        // Encoded polyline from Mapbox
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Indexes**: `userId` + `status`, `userId` + `createdAt`
**Security**: Creator + shared users can read. Only creator can write.

---

### 5. `chatRooms`
**Path**: `/chatRooms/{roomId}`

```
{
  id: string,
  type: "direct" | "group" | "support",
  participants: [string],         // User IDs
  participantNames: {             // Map for display
    [userId]: string
  },
  lastMessage: {
    text: string,
    senderId: string,
    sentAt: timestamp
  },
  unreadCount: {                  // Per-user unread counts
    [userId]: number
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Subcollection**: `/chatRooms/{roomId}/messages/{messageId}`

```
{
  id: string,
  senderId: string,
  senderName: string,             // Denormalized
  text: string,
  type: "text" | "image" | "location",
  imageUrl: string | null,
  location: GeoPoint | null,
  readBy: [string],               // User IDs who have read
  createdAt: timestamp
}
```

**Indexes**: `participants` (array-contains), `updatedAt` (descending)
**Security**: Only participants can read/write. Messages inherit room access.

---

### 6. `notifications`
**Path**: `/users/{userId}/notifications/{notificationId}`

```
{
  id: string,
  type: "chat" | "route" | "payment" | "system" | "promo",
  title: string,
  body: string,
  data: {                         // Payload for navigation
    screen: string,               // Route path to navigate to
    entityId: string | null       // venueId, routeId, chatRoomId, etc.
  },
  isRead: boolean,
  createdAt: timestamp
}
```

**Security**: User can only read/write own notifications.

---

### 7. `payments`
**Path**: `/payments/{paymentId}`

```
{
  id: string,
  userId: string,
  venueId: string,
  venueName: string,              // Denormalized
  amount: number,
  currency: "INR" | "AED",
  gateway: "razorpay" | "stripe",
  gatewayOrderId: string,         // Razorpay order_id
  gatewayPaymentId: string | null,// Razorpay payment_id (after success)
  gatewaySignature: string | null,// For verification
  status: "created" | "authorized" | "captured" | "failed" | "refunded",
  bookingDetails: {
    date: timestamp,
    time: string,
    guests: number,
    notes: string | null
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Security**: User can read own payments. Cloud Functions create/update payments (never client-side).

---

### 8. `reports`
**Path**: `/reports/{reportId}`

```
{
  id: string,
  reporterId: string,
  targetType: "venue" | "review" | "user" | "message",
  targetId: string,
  reason: string,
  description: string | null,
  status: "pending" | "reviewed" | "resolved" | "dismissed",
  reviewedBy: string | null,      // Admin user ID
  createdAt: timestamp,
  resolvedAt: timestamp | null
}
```

**Security**: Auth users can create. Only admins can read/update.

---

### 9. `liveLocations`
**Path**: `/liveLocations/{sessionId}`

```
{
  id: string,
  routeId: string,                // Associated route
  userId: string,
  displayName: string,
  lat: number,
  lng: number,
  heading: number | null,
  speed: number | null,
  updatedAt: timestamp,
  expiresAt: timestamp            // Auto-cleanup via TTL policy
}
```

**Security**: Only route participants can read/write.

---

### 10. `config` (App configuration)
**Path**: `/config/{configId}`

```
// /config/app
{
  maintenanceMode: boolean,
  minAppVersion: string,
  supportedCities: ["Mumbai", "Delhi", "Dubai", ...],
  razorpayKeyId: string,          // Public key only
  mapboxPublicToken: string,
  featureFlags: {
    chatEnabled: boolean,
    paymentsEnabled: boolean,
    liveLocationEnabled: boolean
  }
}
```

**Security**: Anyone can read. Only admins can write.

---

## Firestore Indexes (Composite)

Create these in `firestore.indexes.json`:

1. `venues`: `city` ASC + `category` ASC + `rating` DESC
2. `venues`: `city` ASC + `avgPricePerPerson` ASC
3. `venues`: `isActive` ASC + `city` ASC + `createdAt` DESC
4. `venues`: `ownerId` ASC + `createdAt` DESC
5. `routes`: `userId` ASC + `createdAt` DESC
6. `routes`: `userId` ASC + `status` ASC
7. `chatRooms`: `updatedAt` DESC (with array-contains on `participants`)
8. `payments`: `userId` ASC + `createdAt` DESC
9. `reports`: `status` ASC + `createdAt` ASC

---

## Data Denormalization Strategy

Firestore is NoSQL — optimize for reads, denormalize where needed:

| Denormalized Field | Where | Why |
|---|---|---|
| `userName`, `userPhotoUrl` | `reviews` | Avoid extra read to fetch user info per review |
| `venueName`, `venueImage` | `routes.stops[]` | Display route stops without venue reads |
| `senderName` | `chatMessages` | Display messages without user reads |
| `lastMessage` | `chatRooms` | Show preview in chat list without reading messages subcollection |
| `participantNames` | `chatRooms` | Display participant names without user reads |
| `venueName` | `payments` | Display payment history without venue reads |

**Update strategy**: When source data changes (e.g., user changes name), use Cloud Function to fan-out updates to denormalized copies.

---

## Cost Estimation (Firebase Blaze)

### Free Tier Allowances (per day)
- 50,000 document reads
- 20,000 document writes
- 20,000 document deletes
- 1 GiB stored data
- 10 GiB/month network egress

### Estimated Usage at 10K DAU
- ~500K reads/day (50 reads/user × 10K users) → ~$0.18/day
- ~50K writes/day (5 writes/user × 10K users) → ~$0.05/day
- Storage: ~5 GiB → $0.90/month
- **Estimated monthly: ~$7-15/month** (very affordable)

### Scaling Concerns at 100K DAU
- ~5M reads/day → ~$1.80/day → ~$54/month
- ~500K writes/day → ~$0.50/day → ~$15/month
- Chat can spike reads significantly — consider pagination and caching
- **Estimated monthly at 100K DAU: ~$70-150/month**

---

## Geo-Query Strategy

Firestore doesn't natively support geo-radius queries. Options:

1. **`geoflutterfire_plus`** — Store `geohash` string with each venue, query by geohash prefix for radius search. **Recommended.**
2. **Bounding box** — Calculate lat/lng bounds for a radius, query with `where('lat', '>=', minLat)`. Less accurate.
3. **Cloud Function** — Server-side filtering. More flexible but higher latency.

**Decision**: Use `geoflutterfire_plus` with `geohash` field on venues + liveLocations.

---

## Offline Support

Firestore has built-in offline persistence:
- Enabled by default on mobile (Android/iOS)
- **Disabled by default on web** — enable explicitly: `FirebaseFirestore.instance.enablePersistence()`
- Cached data available when offline, syncs when reconnected
- Set cache size limit to avoid excessive storage: `Settings(cacheSizeBytes: 50 * 1024 * 1024)` (50MB)

---

## Backup Strategy

1. **Firestore scheduled exports** via Cloud Function (weekly)
2. Export to Cloud Storage bucket
3. Retention: 30 days
4. Can restore from export if needed

---

## Migration Path (Future)

If GTG outgrows Firestore (unlikely before 1M+ users):
- Export Firestore → BigQuery for analytics
- Consider PostgreSQL (Supabase or Cloud SQL) for complex relational queries
- Keep Firestore for real-time features (chat, live location)
- Hybrid approach: Postgres for CRUD, Firestore for real-time
