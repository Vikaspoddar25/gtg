import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/notification.dart';
import 'package:gtg/services/database_service.dart';

/// State for in-app notifications — real-time stream, mark-read operations.
class NotificationProvider extends ChangeNotifier {
  final DatabaseService _db;

  NotificationProvider(this._db);

  // ── State ────────────────────────────────────────────────────────────────

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AppNotification>>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Real-time listener ───────────────────────────────────────────────────

  void startListening(String userId) {
    _subscription?.cancel();
    _subscription = _db.notificationsStream(userId).listen(
      (notifications) {
        _notifications = notifications;
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
    _notifications = [];
    notifyListeners();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> markRead(String userId, String notifId) async {
    try {
      await _db.markNotificationRead(userId, notifId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllRead(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.markAllNotificationsRead(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
