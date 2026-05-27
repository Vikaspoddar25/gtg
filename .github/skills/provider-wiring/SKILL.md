---
description: "Skill: Create a ChangeNotifier Provider, wire it to a service, and register in MultiProvider"
---

# Provider Wiring Skill

Create a ChangeNotifier provider in `lib/providers/`, wire it to the corresponding service, and register it in `main.dart`.

## Inputs Required
- **Feature name** — e.g., `Venue`, `Booking`, `Chat`
- **Service class** — e.g., `VenueService` (must exist in `lib/services/`)
- **Model class** — e.g., `Venue` (must exist in `lib/models/`)

## Steps

### 1. Verify Dependencies
- Service exists in `lib/services/`
- Model exists in `lib/models/`

### 2. Create Provider
Create `lib/providers/<feature>_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gtg/models/<model>.dart';
import 'package:gtg/services/<feature>_service.dart';

class <Feature>Provider extends ChangeNotifier {
  final <Feature>Service _service;

  <Feature>Provider(this._service);

  // ── State ───────────────────────────────────────
  List<<Model>> _items = [];
  <Model>? _selected;
  bool _isLoading = false;
  String? _error;

  // ── Getters ─────────────────────────────────────
  List<<Model>> get items => List.unmodifiable(_items);
  <Model>? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Stream subscriptions ────────────────────────
  StreamSubscription? _subscription;

  // ── Actions ─────────────────────────────────────
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selected = await _service.getById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startListening() {
    _subscription?.cancel();
    _subscription = _service.streamAll().listen(
      (items) {
        _items = items;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Dispose ─────────────────────────────────────
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### 3. Register in main.dart
Add to the `providers` list in `MultiProvider` in `lib/main.dart`:
```dart
ChangeNotifierProvider(
  create: (_) => <Feature>Provider(<Feature>Service()),
),
```

Import the provider and service at the top of `main.dart`.

### 4. Verify
```bash
flutter analyze
```

## Quality Checklist
- [ ] Extends `ChangeNotifier`
- [ ] Exposes `isLoading`, `error`, `hasError`, and data getters
- [ ] Data getters return unmodifiable copies (`List.unmodifiable`)
- [ ] `notifyListeners()` called after every state mutation
- [ ] try/catch in every async method
- [ ] Stream subscriptions cancelled in `dispose()`
- [ ] Registered in `main.dart` `MultiProvider`
- [ ] Imports added to `main.dart`
- [ ] `flutter analyze` passes
