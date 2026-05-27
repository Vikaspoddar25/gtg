import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Chat room — `/chatRooms/{roomId}`
class ChatRoom extends Equatable {
  final String id;
  final String type; // "direct" | "group" | "support"
  final List<String> participants;
  final Map<String, String> participantNames;
  final LastMessage? lastMessage;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatRoom({
    required this.id,
    required this.type,
    required this.participants,
    this.participantNames = const {},
    this.lastMessage,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ChatRoom(
      id: doc.id,
      type: d['type'] as String? ?? 'direct',
      participants: (d['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      participantNames: (d['participantNames'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      lastMessage: d['lastMessage'] is Map<String, dynamic>
          ? LastMessage.fromMap(d['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: (d['unreadCount'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type,
        'participants': participants,
        'participantNames': participantNames,
        if (lastMessage != null) 'lastMessage': lastMessage!.toMap(),
        'unreadCount': unreadCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id];
}

class LastMessage {
  final String text;
  final String senderId;
  final DateTime sentAt;

  const LastMessage({
    required this.text,
    required this.senderId,
    required this.sentAt,
  });

  factory LastMessage.fromMap(Map<String, dynamic> m) => LastMessage(
        text: m['text'] as String? ?? '',
        senderId: m['senderId'] as String? ?? '',
        sentAt: (m['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'sentAt': Timestamp.fromDate(sentAt),
      };
}

/// Chat message — subcollection `/chatRooms/{roomId}/messages/{messageId}`
class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String type; // "text" | "image" | "location"
  final String? imageUrl;
  final GeoPoint? location;
  final List<String> readBy;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = 'text',
    this.imageUrl,
    this.location,
    this.readBy = const [],
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? '',
      text: d['text'] as String? ?? '',
      type: d['type'] as String? ?? 'text',
      imageUrl: d['imageUrl'] as String?,
      location: d['location'] as GeoPoint?,
      readBy: (d['readBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': type,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (location != null) 'location': location,
        'readBy': readBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id];
}
