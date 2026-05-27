import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? bio;
  final String authProvider; // "email" | "phone" | "google" | "apple"
  final String referralCode;
  final String? referredBy;
  final NotificationPrefs notificationPrefs;
  final UserLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.email,
    this.phone,
    this.photoUrl,
    this.bio,
    required this.authProvider,
    required this.referralCode,
    this.referredBy,
    this.notificationPrefs = const NotificationPrefs(),
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      authProvider: data['authProvider'] as String? ?? 'email',
      referralCode: data['referralCode'] as String? ?? '',
      referredBy: data['referredBy'] as String?,
      notificationPrefs: data['notificationPrefs'] != null
          ? NotificationPrefs.fromMap(
              data['notificationPrefs'] as Map<String, dynamic>)
          : const NotificationPrefs(),
      location: data['location'] != null
          ? UserLocation.fromMap(data['location'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bio': bio,
      'authProvider': authProvider,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'notificationPrefs': notificationPrefs.toMap(),
      if (location != null) 'location': location!.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    String? bio,
    NotificationPrefs? notificationPrefs,
    UserLocation? location,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      authProvider: authProvider,
      referralCode: referralCode,
      referredBy: referredBy,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [uid];
}

class NotificationPrefs extends Equatable {
  final bool push;
  final bool whatsapp;

  const NotificationPrefs({this.push = true, this.whatsapp = false});

  factory NotificationPrefs.fromMap(Map<String, dynamic> map) {
    return NotificationPrefs(
      push: map['push'] as bool? ?? true,
      whatsapp: map['whatsapp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {'push': push, 'whatsapp': whatsapp};

  @override
  List<Object?> get props => [push, whatsapp];
}

class UserLocation extends Equatable {
  final double lat;
  final double lng;
  final DateTime updatedAt;

  const UserLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  @override
  List<Object?> get props => [lat, lng];
}
