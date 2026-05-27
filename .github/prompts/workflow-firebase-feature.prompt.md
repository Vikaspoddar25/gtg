# Workflow: Implement a Firebase-Backed Feature

Build a complete feature from database schema to UI integration with tests.

## Required Input
- **Feature name**: (e.g., `Venue Management`, `Chat`, `Payments`)
- **Firestore collection**: (e.g., `venues`, `chatRooms`, `payments`)
- **Operations needed**: (e.g., CRUD, real-time streams, geo-queries)

## Steps

### Step 1 — Review Schema
Read `plan-database.md` for the collection schema:
- Document fields, types, nullability
- Subcollections
- Indexes needed
- Security rules notes

### Step 2 — Create/Update Model
Use the `model-creation` skill:
- Create `lib/models/<model>.dart`
- Include all fields from schema
- Equatable, fromFirestore/toFirestore, fromJson/toJson, copyWith
- Handle nested objects, timestamps, GeoPoints

### Step 3 — Create/Update Service
Use the `firebase-service` skill:
- Create `lib/services/<feature>_service.dart`
- CRUD operations matching the schema
- Real-time streams where applicable
- Filtered queries with proper indexes
- Constructor accepts optional `FirebaseFirestore` for testing

### Step 4 — Create/Update Provider
Use the `provider-wiring` skill:
- Create `lib/providers/<feature>_provider.dart`
- Wire to the service
- Expose loading/error/data states
- Register in `main.dart` MultiProvider

### Step 5 — Wire to UI
- Update the relevant screen(s) to use the Provider
- Replace mock/hardcoded data with `Provider.of<XProvider>(context)`
- Add loading states (shimmer or CircularProgressIndicator)
- Add error states
- Add empty states

### Step 6 — Update Security Rules
Check `firestore.rules`:
- Are the CRUD operations covered?
- Is the access control correct? (user-owned, public read, etc.)
- Add missing rules following patterns in `plan-security-scaling.md`

### Step 7 — Add Firestore Indexes
If composite queries are used, add indexes to `firestore.indexes.json`.

### Step 8 — Write Tests
Use the testing agent:
- Unit test for model (fromJson, toJson, equality)
- Unit test for service (using `fake_cloud_firestore`)
- Provider test (state transitions)

### Step 9 — Verify
```bash
flutter analyze
flutter test
```

### Step 10 — Update Todo
Mark the corresponding items in `todo.md` as complete.

## Agents Used
- `@firebase-backend` — Steps 1, 3, 6, 7
- `@state-management` — Steps 2, 4
- `@flutter-ui` — Step 5
- `@testing` — Step 8
