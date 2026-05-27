import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? subcategory;
  final String status; // "open" | "closed" | "busy"
  final double rating;
  final int reviewCount;
  final int avgPricePerPerson;
  final String currency; // "INR" | "AED"
  final List<String> images;
  final String? coverImage;
  final VenueAddress? venueAddress;
  final GeoPoint? location;
  final String? geohash;
  final VenueContact? contact;
  final Map<String, VenueHours?>? hours;
  final List<String> amenities;
  final List<String> tags;
  final String? ownerId;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Venue({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.subcategory,
    required this.status,
    required this.rating,
    this.reviewCount = 0,
    required this.avgPricePerPerson,
    this.currency = 'INR',
    this.images = const [],
    this.coverImage,
    this.venueAddress,
    this.location,
    this.geohash,
    this.contact,
    this.hours,
    this.amenities = const [],
    this.tags = const [],
    this.ownerId,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Convenience getter for backward compatibility with `imageUrl`.
  String get imageUrl => coverImage ?? (images.isNotEmpty ? images.first : '');

  factory Venue.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Venue(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String?,
      category: d['category'] as String? ?? '',
      subcategory: d['subcategory'] as String?,
      status: d['status'] as String? ?? 'open',
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      avgPricePerPerson: (d['avgPricePerPerson'] as num?)?.toInt() ?? 0,
      currency: d['currency'] as String? ?? 'INR',
      images: (d['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      coverImage: d['coverImage'] as String?,
      venueAddress: d['address'] is Map<String, dynamic>
          ? VenueAddress.fromMap(d['address'] as Map<String, dynamic>)
          : null,
      location: d['location'] as GeoPoint?,
      geohash: d['geohash'] as String?,
      contact: d['contact'] is Map<String, dynamic>
          ? VenueContact.fromMap(d['contact'] as Map<String, dynamic>)
          : null,
      hours: _parseHours(d['hours']),
      amenities: (d['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (d['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      ownerId: d['ownerId'] as String?,
      isVerified: d['isVerified'] as bool? ?? false,
      isActive: d['isActive'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        if (description != null) 'description': description,
        'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'status': status,
        'rating': rating,
        'reviewCount': reviewCount,
        'avgPricePerPerson': avgPricePerPerson,
        'currency': currency,
        'images': images,
        if (coverImage != null) 'coverImage': coverImage,
        if (venueAddress != null) 'address': venueAddress!.toMap(),
        if (location != null) 'location': location,
        if (geohash != null) 'geohash': geohash,
        if (contact != null) 'contact': contact!.toMap(),
        if (hours != null)
          'hours': hours!.map((k, v) => MapEntry(k, v?.toMap())),
        'amenities': amenities,
        'tags': tags,
        if (ownerId != null) 'ownerId': ownerId,
        'isVerified': isVerified,
        'isActive': isActive,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Venue copyWith({
    String? name,
    String? description,
    String? category,
    String? subcategory,
    String? status,
    double? rating,
    int? reviewCount,
    int? avgPricePerPerson,
    String? currency,
    List<String>? images,
    String? coverImage,
    VenueAddress? venueAddress,
    GeoPoint? location,
    String? geohash,
    VenueContact? contact,
    Map<String, VenueHours?>? hours,
    List<String>? amenities,
    List<String>? tags,
    String? ownerId,
    bool? isVerified,
    bool? isActive,
  }) =>
      Venue(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        status: status ?? this.status,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        avgPricePerPerson: avgPricePerPerson ?? this.avgPricePerPerson,
        currency: currency ?? this.currency,
        images: images ?? this.images,
        coverImage: coverImage ?? this.coverImage,
        venueAddress: venueAddress ?? this.venueAddress,
        location: location ?? this.location,
        geohash: geohash ?? this.geohash,
        contact: contact ?? this.contact,
        hours: hours ?? this.hours,
        amenities: amenities ?? this.amenities,
        tags: tags ?? this.tags,
        ownerId: ownerId ?? this.ownerId,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id];

  static Map<String, VenueHours?>? _parseHours(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return data.map((k, v) => MapEntry(
        k, v is Map<String, dynamic> ? VenueHours.fromMap(v) : null));
  }
}

class VenueAddress extends Equatable {
  final String line1;
  final String? line2;
  final String city;
  final String? state;
  final String country; // "IN" | "AE"
  final String pincode;

  const VenueAddress({
    required this.line1,
    this.line2,
    required this.city,
    this.state,
    required this.country,
    required this.pincode,
  });

  factory VenueAddress.fromMap(Map<String, dynamic> m) => VenueAddress(
        line1: m['line1'] as String? ?? '',
        line2: m['line2'] as String?,
        city: m['city'] as String? ?? '',
        state: m['state'] as String?,
        country: m['country'] as String? ?? 'IN',
        pincode: m['pincode'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'line1': line1,
        if (line2 != null) 'line2': line2,
        'city': city,
        if (state != null) 'state': state,
        'country': country,
        'pincode': pincode,
      };

  @override
  List<Object?> get props => [line1, city, country, pincode];
}

class VenueContact {
  final String? phone;
  final String? email;
  final String? website;

  const VenueContact({this.phone, this.email, this.website});

  factory VenueContact.fromMap(Map<String, dynamic> m) => VenueContact(
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        website: m['website'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (website != null) 'website': website,
      };
}

class VenueHours {
  final String open;
  final String close;

  const VenueHours({required this.open, required this.close});

  factory VenueHours.fromMap(Map<String, dynamic> m) => VenueHours(
        open: m['open'] as String? ?? '',
        close: m['close'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'open': open, 'close': close};
}

/// Mock venue data matching Figma frame 117:105.
/// NOTE: image values are Figma CDN URLs that expire after 7 days.
const List<Venue> mockVenues = [
  Venue(
    id: '1',
    name: 'QuickSpoon',
    category: 'Food',
    status: 'open',
    rating: 3.8,
    avgPricePerPerson: 500,
    coverImage: 'https://www.figma.com/api/mcp/asset/acc79b46-5beb-4564-85cd-7e14047c8c08',
  ),
  Venue(
    id: '2',
    name: 'AllEarthed',
    category: 'Food',
    status: 'open',
    rating: 4.2,
    avgPricePerPerson: 300,
    coverImage: 'https://www.figma.com/api/mcp/asset/28092c23-b2ef-45d4-a494-4b37f8427281',
  ),
  Venue(
    id: '3',
    name: 'Spicehood',
    category: 'Food',
    status: 'open',
    rating: 4.6,
    avgPricePerPerson: 800,
    coverImage: 'https://www.figma.com/api/mcp/asset/517b8287-3d55-42f3-a630-470188786a65',
  ),
  Venue(
    id: '4',
    name: 'Oggy Dobby',
    category: 'Food',
    status: 'open',
    rating: 4.6,
    avgPricePerPerson: 800,
    coverImage: 'https://www.figma.com/api/mcp/asset/a4d77769-3eac-46b3-8b2f-36fc57be968f',
  ),
  Venue(
    id: '5',
    name: 'PVR',
    category: 'Entertainment',
    status: 'open',
    rating: 4.8,
    avgPricePerPerson: 400,
    coverImage: 'https://www.figma.com/api/mcp/asset/bc62fb1c-cf01-4d8d-b0c8-db5ee5cfc946',
  ),
];
