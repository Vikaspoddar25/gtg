import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/route.dart';
import 'package:gtg/services/database_service.dart';

/// State for saved routes — user's route list, selected route, and CRUD operations.
class RouteProvider extends ChangeNotifier {
  final DatabaseService _db;

  RouteProvider(this._db);

  // ── State ────────────────────────────────────────────────────────────────

  List<GtgRoute> _routes = [];
  GtgRoute? _selected;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<GtgRoute>>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<GtgRoute> get routes => List.unmodifiable(_routes);
  GtgRoute? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Real-time listener ───────────────────────────────────────────────────

  void startListening(String userId) {
    _subscription?.cancel();
    _subscription = _db.userRoutesStream(userId).listen(
      (routes) {
        _routes = routes;
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
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<String?> addRoute(GtgRoute route) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _db.addRoute(route);
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRoute(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _db.updateRoute(id, data);
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

  Future<void> selectRoute(String id) async {
    if (_selected?.id == id) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selected = await _db.getRoute(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
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
