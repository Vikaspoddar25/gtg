import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Route — `/routes/{routeId}`
class GtgRoute extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final List<RouteStop> stops;
  final RoutePreferences preferences;
  final double totalDistance; // km
  final double totalDuration; // minutes
  final String status; // "draft" | "active" | "completed" | "cancelled"
  final List<String> sharedWith;
  final String? polyline;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GtgRoute({
    required this.id,
    required this.userId,
    this.name,
    required this.stops,
    required this.preferences,
    this.totalDistance = 0,
    this.totalDuration = 0,
    this.status = 'draft',
    this.sharedWith = const [],
    this.polyline,
    required this.createdAt,
    this.updatedAt,
  });

  factory GtgRoute.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return GtgRoute(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      name: d['name'] as String?,
      stops: (d['stops'] as List<dynamic>?)
              ?.map((e) => RouteStop.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferences: d['preferences'] is Map<String, dynamic>
          ? RoutePreferences.fromMap(d['preferences'] as Map<String, dynamic>)
          : const RoutePreferences(),
      totalDistance: (d['totalDistance'] as num?)?.toDouble() ?? 0,
      totalDuration: (d['totalDuration'] as num?)?.toDouble() ?? 0,
      status: d['status'] as String? ?? 'draft',
      sharedWith: (d['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      polyline: d['polyline'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        if (name != null) 'name': name,
        'stops': stops.map((s) => s.toMap()).toList(),
        'preferences': preferences.toMap(),
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
        'status': status,
        'sharedWith': sharedWith,
        if (polyline != null) 'polyline': polyline,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  GtgRoute copyWith({
    String? name,
    List<RouteStop>? stops,
    RoutePreferences? preferences,
    double? totalDistance,
    double? totalDuration,
    String? status,
    List<String>? sharedWith,
    String? polyline,
  }) =>
      GtgRoute(
        id: id,
        userId: userId,
        name: name ?? this.name,
        stops: stops ?? this.stops,
        preferences: preferences ?? this.preferences,
        totalDistance: totalDistance ?? this.totalDistance,
        totalDuration: totalDuration ?? this.totalDuration,
        status: status ?? this.status,
        sharedWith: sharedWith ?? this.sharedWith,
        polyline: polyline ?? this.polyline,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id];
}

class RouteStop {
  final String venueId;
  final String venueName;
  final String venueImage;
  final int order;
  final int estimatedDuration; // minutes
  final double lat;
  final double lng;

  const RouteStop({
    required this.venueId,
    required this.venueName,
    required this.venueImage,
    required this.order,
    this.estimatedDuration = 0,
    required this.lat,
    required this.lng,
  });

  factory RouteStop.fromMap(Map<String, dynamic> m) => RouteStop(
        venueId: m['venueId'] as String? ?? '',
        venueName: m['venueName'] as String? ?? '',
        venueImage: m['venueImage'] as String? ?? '',
        order: (m['order'] as num?)?.toInt() ?? 0,
        estimatedDuration: (m['estimatedDuration'] as num?)?.toInt() ?? 0,
        lat: (m['lat'] as num?)?.toDouble() ?? 0,
        lng: (m['lng'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'venueId': venueId,
        'venueName': venueName,
        'venueImage': venueImage,
        'order': order,
        'estimatedDuration': estimatedDuration,
        'lat': lat,
        'lng': lng,
      };

  RouteStop copyWith({int? order}) => RouteStop(
        venueId: venueId,
        venueName: venueName,
        venueImage: venueImage,
        order: order ?? this.order,
        estimatedDuration: estimatedDuration,
        lat: lat,
        lng: lng,
      );
}

class RoutePreferences {
  final int numberOfFriends;
  final int budgetPerPerson;
  final List<String> selectedModes;
  final double hoursToSpend;
  final double rangeKm;

  const RoutePreferences({
    this.numberOfFriends = 1,
    this.budgetPerPerson = 500,
    this.selectedModes = const [],
    this.hoursToSpend = 3,
    this.rangeKm = 5,
  });

  factory RoutePreferences.fromMap(Map<String, dynamic> m) => RoutePreferences(
        numberOfFriends: (m['numberOfFriends'] as num?)?.toInt() ?? 1,
        budgetPerPerson: (m['budgetPerPerson'] as num?)?.toInt() ?? 500,
        selectedModes: (m['selectedModes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        hoursToSpend: (m['hoursToSpend'] as num?)?.toDouble() ?? 3,
        rangeKm: (m['rangeKm'] as num?)?.toDouble() ?? 5,
      );

  Map<String, dynamic> toMap() => {
        'numberOfFriends': numberOfFriends,
        'budgetPerPerson': budgetPerPerson,
        'selectedModes': selectedModes,
        'hoursToSpend': hoursToSpend,
        'rangeKm': rangeKm,
      };
}
