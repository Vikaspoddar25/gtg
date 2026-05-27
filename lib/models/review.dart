import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Review — subcollection under `/venues/{venueId}/reviews/{reviewId}`
class Review extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating; // 1-5
  final String comment;
  final List<String>? images;
  final bool isReported;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.images,
    this.isReported = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Review(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String? ?? '',
      userPhotoUrl: d['userPhotoUrl'] as String?,
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      comment: d['comment'] as String? ?? '',
      images: (d['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isReported: d['isReported'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        if (userPhotoUrl != null) 'userPhotoUrl': userPhotoUrl,
        'rating': rating,
        'comment': comment,
        if (images != null) 'images': images,
        'isReported': isReported,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id];
}
