import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// App notification — subcollection `/users/{userId}/notifications/{id}`
class AppNotification extends Equatable {
  final String id;
  final String type; // "chat" | "route" | "payment" | "system" | "promo"
  final String title;
  final String body;
  final NotificationData? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppNotification(
      id: doc.id,
      type: d['type'] as String? ?? 'system',
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      data: d['data'] is Map<String, dynamic>
          ? NotificationData.fromMap(d['data'] as Map<String, dynamic>)
          : null,
      isRead: d['isRead'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type,
        'title': title,
        'body': body,
        if (data != null) 'data': data!.toMap(),
        'isRead': isRead,
        'createdAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id];
}

class NotificationData {
  final String screen;
  final String? entityId;

  const NotificationData({required this.screen, this.entityId});

  factory NotificationData.fromMap(Map<String, dynamic> m) => NotificationData(
        screen: m['screen'] as String? ?? '',
        entityId: m['entityId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'screen': screen,
        if (entityId != null) 'entityId': entityId,
      };
}
