---
description: "Skill: Create a Dart model class from Firestore schema with Equatable, serialization, and factory methods"
---

# Model Creation Skill

Create a Dart model class in `lib/models/` that matches a Firestore collection schema from `plan-database.md`.

## Inputs Required
- **Collection name** — e.g., `venues`, `users`
- **Schema reference** — section in `plan-database.md`

## Steps

### 1. Read Schema
Read the relevant section in `plan-database.md` to get:
- All fields, their types, and nullability
- Nested objects (e.g., `address`, `location`, `contact`)
- Default values
- Subcollections (if any)

### 2. Create Model File
Create `lib/models/<collection_singular>.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  // ... all fields from schema

  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    // ...
  });

  // ── Firestore serialization ─────────────────────
  factory Venue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Venue(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      // Handle nested objects:
      // address: VenueAddress.fromJson(data['address'] as Map<String, dynamic>? ?? {}),
      // Handle timestamps:
      // createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Handle GeoPoint:
      // location: data['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'category': category,
    // Exclude 'id' — it's the document ID
    // Include nested objects: 'address': address.toJson(),
    // Include timestamps: 'createdAt': Timestamp.fromDate(createdAt),
  };

  // ── JSON serialization (for non-Firestore use) ──
  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
  };

  // ── Copy with ───────────────────────────────────
  Venue copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
  }) => Venue(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    category: category ?? this.category,
  );

  // ── Equatable ───────────────────────────────────
  @override
  List<Object?> get props => [id, name, description, category];
}
```

### 3. Handle Nested Objects
For nested objects (e.g., `address`, `contact`, `hours`), create helper classes in the same file or a separate file:
```dart
class VenueAddress extends Equatable {
  final String line1;
  final String? line2;
  final String city;
  // ...

  const VenueAddress({required this.line1, this.line2, required this.city});

  factory VenueAddress.fromJson(Map<String, dynamic> json) => VenueAddress(...);
  Map<String, dynamic> toJson() => {...};

  @override
  List<Object?> get props => [line1, line2, city];
}
```

### 4. Handle Enums
For status fields, use Dart enums:
```dart
enum VenueStatus { open, closed, busy }
// Parse: VenueStatus.values.firstWhere((e) => e.name == data['status'])
```

### 5. Verify
```bash
flutter analyze
```

## Quality Checklist
- [ ] All fields from `plan-database.md` schema included
- [ ] Nullable fields use `?` type
- [ ] `fromFirestore` handles missing/null fields with defaults
- [ ] `toFirestore` excludes `id` (it's the document ID)
- [ ] `fromJson`/`toJson` included for non-Firestore use
- [ ] `copyWith` method for immutable updates
- [ ] Extends `Equatable` with complete `props`
- [ ] `const` constructor
- [ ] Timestamps handled: `Timestamp` ↔ `DateTime`
- [ ] GeoPoints handled if applicable
- [ ] `flutter analyze` passes
