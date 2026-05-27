---
description: "Skill: Create or update a Firebase service with Firestore CRUD, real-time listeners, and proper error handling"
---

# Firebase Service Skill

Create or update a service file in `lib/services/` that wraps Firestore operations for a specific collection.

## Inputs Required
- **Collection name** — e.g., `venues`, `routes`, `chatRooms`
- **Model class** — e.g., `Venue` (must exist in `lib/models/`)
- **Operations needed** — CRUD, real-time streams, geo-queries, etc.

## Steps

### 1. Review Schema
Read `plan-database.md` to understand:
- Collection path (e.g., `/venues/{venueId}`, `/venues/{venueId}/reviews/{reviewId}`)
- All document fields and types
- Indexes required
- Security rules for this collection

### 2. Verify Model Exists
Check that the corresponding model in `lib/models/` matches the schema. If not, update it first using the model-creation skill.

### 3. Create Service File
Create `lib/services/<collection>_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtg/models/<model>.dart';

class <Collection>Service {
  final FirebaseFirestore _db;
  final String _collection = '<collection>';

  <Collection>Service({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ── Read ────────────────────────────────────────
  Future<<Model>> getById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('<Model> not found');
    return <Model>.fromFirestore(doc);
  }

  Future<List<<Model>>> getAll() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) => <Model>.fromFirestore(doc)).toList();
  }

  // ── Create ──────────────────────────────────────
  Future<String> create(<Model> item) async {
    final ref = await _db.collection(_collection).add(item.toFirestore());
    return ref.id;
  }

  // ── Update ──────────────────────────────────────
  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(id).update(data);
  }

  // ── Delete ──────────────────────────────────────
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // ── Real-time streams ──────────────────────────
  Stream<List<<Model>>> streamAll() {
    return _db.collection(_collection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => <Model>.fromFirestore(doc)).toList(),
    );
  }

  Stream<<Model>> streamById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map(
      (doc) => <Model>.fromFirestore(doc),
    );
  }
}
```

### 4. Add Filtered Queries (if applicable)
For collections that need filtering (e.g., venues by city, category):
```dart
Future<List<Venue>> getByCity(String city) async {
  final snapshot = await _db
      .collection(_collection)
      .where('address.city', isEqualTo: city)
      .where('isActive', isEqualTo: true)
      .get();
  return snapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();
}
```

### 5. Update Firestore Indexes
If the service uses composite queries, add indexes to `firestore.indexes.json`.

### 6. Verify Security Rules
Check `firestore.rules` covers the operations. If not, add rules following the patterns in `plan-security-scaling.md`.

### 7. Verify
```bash
flutter analyze
```

## Quality Checklist
- [ ] Constructor accepts optional `FirebaseFirestore` for testing
- [ ] All CRUD operations implemented
- [ ] Real-time streams provided where needed
- [ ] Proper error handling (try/catch in caller, meaningful exceptions)
- [ ] `updatedAt` set via `FieldValue.serverTimestamp()` on updates
- [ ] No secrets or API keys in service code
- [ ] Indexes added for composite queries
- [ ] Security rules verified
- [ ] `flutter analyze` passes
