import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/route.dart';
import 'package:gtg/models/venue.dart';
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

  // ── Route generation (GTG flow → matching venues) ───────────────────────

  /// Filters [availableVenues] by [preferences] (budget + selected modes),
  /// sorts by rating, and creates a new draft route with one stop per
  /// available hour (capped 1-4 stops). Sets [selected] to the new route.
  Future<String?> generateRoute({
    required String userId,
    required RoutePreferences preferences,
    required List<Venue> availableVenues,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final modes = preferences.selectedModes.map((m) => m.toLowerCase()).toSet();
      final filtered = availableVenues.where((v) {
        final withinBudget = v.avgPricePerPerson <= preferences.budgetPerPerson;
        final matchesMode = modes.isEmpty ||
            modes.contains(v.category.toLowerCase()) ||
            v.tags.any((t) => modes.contains(t.toLowerCase()));
        return withinBudget && matchesMode;
      }).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      final stopCount = preferences.hoursToSpend.clamp(2, 8).round() ~/ 2;
      final selectedVenues = filtered.take(stopCount.clamp(1, 4)).toList();
      final perStopMinutes = selectedVenues.isEmpty
          ? 0
          : (preferences.hoursToSpend * 60 / selectedVenues.length).round();

      final stops = [
        for (var i = 0; i < selectedVenues.length; i++)
          RouteStop(
            venueId: selectedVenues[i].id,
            venueName: selectedVenues[i].name,
            venueImage: selectedVenues[i].imageUrl,
            order: i,
            estimatedDuration: perStopMinutes,
            lat: selectedVenues[i].location?.latitude ?? 0,
            lng: selectedVenues[i].location?.longitude ?? 0,
          ),
      ];

      final route = GtgRoute(
        id: '',
        userId: userId,
        stops: stops,
        preferences: preferences,
        status: 'draft',
        createdAt: DateTime.now(),
      );
      final id = await _db.addRoute(route);
      _selected = await _db.getRoute(id);
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

  // ── Draft-route stop mutation (Routes screen edit state) ────────────────

  /// Adds [venue] as a stop to the current draft route, creating a fresh
  /// draft route first if none is selected yet (e.g. user tapped
  /// "Add to the route" from Venue Detail without running the GTG flow).
  Future<void> addVenueToRoute(String userId, Venue venue) async {
    final stop = RouteStop(
      venueId: venue.id,
      venueName: venue.name,
      venueImage: venue.imageUrl,
      order: 0,
      estimatedDuration: 60,
      lat: venue.location?.latitude ?? 0,
      lng: venue.location?.longitude ?? 0,
    );
    if (_selected == null || _selected!.status != 'draft') {
      _isLoading = true;
      _error = null;
      notifyListeners();
      try {
        final route = GtgRoute(
          id: '',
          userId: userId,
          stops: [stop],
          preferences: const RoutePreferences(),
          status: 'draft',
          createdAt: DateTime.now(),
        );
        final id = await _db.addRoute(route);
        _selected = await _db.getRoute(id);
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }
    await addStopToSelected(stop);
  }

  Future<void> addStopToSelected(RouteStop stop) async {
    if (_selected == null) return;
    final stops = [..._selected!.stops, stop.copyWith(order: _selected!.stops.length)];
    await _persistSelectedStops(stops);
  }

  Future<void> removeStopFromSelected(int index) async {
    if (_selected == null) return;
    final stops = [..._selected!.stops]..removeAt(index);
    await _persistSelectedStops(_reindexed(stops));
  }

  Future<void> reorderSelectedStop(int oldIndex, int newIndex) async {
    if (_selected == null) return;
    final stops = [..._selected!.stops];
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    await _persistSelectedStops(_reindexed(stops));
  }

  Future<void> regenerateStopInSelected(int index, RouteStop replacement) async {
    if (_selected == null) return;
    final stops = [..._selected!.stops];
    stops[index] = replacement.copyWith(order: index);
    await _persistSelectedStops(stops);
  }

  /// Marks the selected route active (user tapped "Good To Go").
  Future<void> activateSelectedRoute() async {
    if (_selected == null) return;
    await updateRoute(_selected!.id, {'status': 'active'});
    _selected = _selected!.copyWith(status: 'active');
    notifyListeners();
  }

  /// Marks the selected route completed (user tapped "Stop Here").
  Future<void> completeSelectedRoute() async {
    if (_selected == null) return;
    await updateRoute(_selected!.id, {'status': 'completed'});
    _selected = _selected!.copyWith(status: 'completed');
    notifyListeners();
  }

  List<RouteStop> _reindexed(List<RouteStop> stops) => [
        for (var i = 0; i < stops.length; i++) stops[i].copyWith(order: i),
      ];

  Future<void> _persistSelectedStops(List<RouteStop> stops) async {
    await updateRoute(_selected!.id, {
      'stops': stops.map((s) => s.toMap()).toList(),
    });
    _selected = _selected!.copyWith(stops: stops);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
