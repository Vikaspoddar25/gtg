import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Live location — `/liveLocations/{sessionId}`
class LiveLocation extends Equatable {
  final String id;
  final String routeId;
  final String userId;
  final String displayName;
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final DateTime updatedAt;
  final DateTime expiresAt;

  const LiveLocation({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.displayName,
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory LiveLocation.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return LiveLocation(
      id: doc.id,
      routeId: d['routeId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      displayName: d['displayName'] as String? ?? '',
      lat: (d['lat'] as num?)?.toDouble() ?? 0,
      lng: (d['lng'] as num?)?.toDouble() ?? 0,
      heading: (d['heading'] as num?)?.toDouble(),
      speed: (d['speed'] as num?)?.toDouble(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'routeId': routeId,
        'userId': userId,
        'displayName': displayName,
        'lat': lat,
        'lng': lng,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      };

  @override
  List<Object?> get props => [id];
}
