import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/user.dart';
import 'package:gtg/services/database_service.dart';

/// State for the current user's profile — load, update, and real-time sync.
class UserProvider extends ChangeNotifier {
  final DatabaseService _db;

  UserProvider(this._db);

  // ── State ────────────────────────────────────────────────────────────────

  UserModel? _profile;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserModel?>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────────

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Real-time listener ───────────────────────────────────────────────────

  void startListening(String uid) {
    _subscription?.cancel();
    _subscription = _db.userStream(uid).listen(
      (user) {
        _profile = user;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _profile = null;
    notifyListeners();
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _db.getUser(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _db.updateUser(uid, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
