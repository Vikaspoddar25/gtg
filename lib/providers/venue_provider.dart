import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/venue.dart';
import 'package:gtg/services/database_service.dart';

/// State for venue discovery — search results, selected venue, and loading state.
class VenueProvider extends ChangeNotifier {
  final DatabaseService _db;

  VenueProvider(this._db);

  // ── State ────────────────────────────────────────────────────────────────

  List<Venue> _venues = [];
  Venue? _selected;
  bool _isLoading = false;
  String? _error;
  String _currentCity = '';
  String? _currentCategory;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Venue> get venues => List.unmodifiable(_venues);
  Venue? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadVenues({
    required String city,
    String? category,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    _currentCity = city;
    _currentCategory = category;
    notifyListeners();
    try {
      _venues = await _db.queryVenues(
        city: city,
        category: category,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVenuesByPrice({
    required String city,
    int? maxPrice,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _venues = await _db.queryVenuesByPrice(
        city: city,
        maxPrice: maxPrice,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectVenue(String id) async {
    if (_selected?.id == id) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selected = await _db.getVenue(id);
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

  /// Reload the last query (useful after adding/updating a venue).
  Future<void> refresh() async {
    if (_currentCity.isEmpty) return;
    await loadVenues(city: _currentCity, category: _currentCategory);
  }
}
