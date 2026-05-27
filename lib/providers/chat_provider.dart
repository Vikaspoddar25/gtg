import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gtg/models/chat.dart';
import 'package:gtg/services/database_service.dart';

/// State for chat — room list, open conversation, messages, and real-time sync.
class ChatProvider extends ChangeNotifier {
  final DatabaseService _db;

  ChatProvider(this._db);

  // ── State ────────────────────────────────────────────────────────────────

  List<ChatRoom> _rooms = [];
  ChatRoom? _activeRoom;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ChatRoom>>? _roomsSub;
  StreamSubscription<List<ChatMessage>>? _messagesSub;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<ChatRoom> get rooms => List.unmodifiable(_rooms);
  ChatRoom? get activeRoom => _activeRoom;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ── Room list listener ───────────────────────────────────────────────────

  void startListeningRooms(String userId) {
    _roomsSub?.cancel();
    _roomsSub = _db.userChatRoomsStream(userId).listen(
      (rooms) {
        _rooms = rooms;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopListeningRooms() {
    _roomsSub?.cancel();
    _roomsSub = null;
    _rooms = [];
    notifyListeners();
  }

  // ── Active conversation ──────────────────────────────────────────────────

  void openRoom(String roomId) {
    _activeRoom = _rooms.cast<ChatRoom?>().firstWhere(
          (r) => r?.id == roomId,
          orElse: () => null,
        );
    _messages = [];
    notifyListeners();
    _messagesSub?.cancel();
    _messagesSub = _db.messagesStream(roomId).listen(
      (msgs) {
        _messages = msgs;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void closeRoom() {
    _messagesSub?.cancel();
    _messagesSub = null;
    _activeRoom = null;
    _messages = [];
    notifyListeners();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<String?> createRoom(ChatRoom room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _db.createChatRoom(room);
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

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    try {
      await _db.sendMessage(roomId, message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markMessagesRead(
    String roomId,
    String userId,
    List<String> messageIds,
  ) async {
    try {
      await _db.markMessagesRead(roomId, userId, messageIds);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
