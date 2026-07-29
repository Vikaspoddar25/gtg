import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtg/models/app_config.dart';
import 'package:gtg/models/chat.dart';
import 'package:gtg/models/live_location.dart';
import 'package:gtg/models/notification.dart';
import 'package:gtg/models/payment.dart';
import 'package:gtg/models/report.dart';
import 'package:gtg/models/review.dart';
import 'package:gtg/models/route.dart';
import 'package:gtg/models/user.dart';
import 'package:gtg/models/venue.dart';

/// Central Firestore service for all collection CRUD operations.
class DatabaseService {
  final FirebaseFirestore _db;

  DatabaseService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════
  // USERS — /users/{userId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> setUser(UserModel user) =>
      _usersCol.doc(user.uid).set(user.toFirestore());

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _usersCol.doc(uid).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  Stream<UserModel?> userStream(String uid) => _usersCol
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);

  Future<UserModel?> getUserByReferralCode(String code) async {
    final snap =
        await _usersCol.where('referralCode', isEqualTo: code).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // VENUES — /venues/{venueId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _venuesCol =>
      _db.collection('venues');

  Future<Venue?> getVenue(String id) async {
    final doc = await _venuesCol.doc(id).get();
    if (!doc.exists) return null;
    return Venue.fromFirestore(doc);
  }

  Future<String> addVenue(Venue venue) async {
    final ref = await _venuesCol.add(venue.toFirestore());
    return ref.id;
  }

  Future<void> updateVenue(String id, Map<String, dynamic> data) =>
      _venuesCol.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  /// Query active venues by city and optional category, ordered by rating.
  Future<List<Venue>> queryVenues({
    required String city,
    String? category,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _venuesCol
        .where('isActive', isEqualTo: true)
        .where('address.city', isEqualTo: city);
    if (category != null) {
      q = q.where('category', isEqualTo: category);
    }
    q = q.orderBy('rating', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(Venue.fromFirestore).toList();
  }

  /// Query venues by price range.
  Future<List<Venue>> queryVenuesByPrice({
    required String city,
    int? maxPrice,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> q = _venuesCol
        .where('isActive', isEqualTo: true)
        .where('address.city', isEqualTo: city)
        .orderBy('avgPricePerPerson');
    if (maxPrice != null) {
      q = q.where('avgPricePerPerson', isLessThanOrEqualTo: maxPrice);
    }
    q = q.limit(limit);
    final snap = await q.get();
    return snap.docs.map(Venue.fromFirestore).toList();
  }

  Stream<List<Venue>> venuesByOwnerStream(String ownerId) => _venuesCol
      .where('ownerId', isEqualTo: ownerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Venue.fromFirestore).toList());

  /// Prefix search on venue name (Firestore "search-as-you-type" pattern).
  /// Falls back to matching `tags`/`category` client-side for short queries.
  Future<List<Venue>> searchVenues(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final snap = await _venuesCol
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(limit)
        .get();
    final byName = snap.docs.map(Venue.fromFirestore).toList();
    if (byName.isNotEmpty) return byName;

    // Fallback: match category/tags for queries that aren't name prefixes.
    final all = await _venuesCol
        .where('isActive', isEqualTo: true)
        .limit(100)
        .get();
    final lower = q.toLowerCase();
    return all.docs
        .map(Venue.fromFirestore)
        .where((v) =>
            v.category.toLowerCase().contains(lower) ||
            v.tags.any((t) => t.toLowerCase().contains(lower)))
        .take(limit)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // REVIEWS — /venues/{venueId}/reviews/{reviewId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _reviewsCol(String venueId) =>
      _venuesCol.doc(venueId).collection('reviews');

  Future<String> addReview(String venueId, Review review) async {
    final ref = await _reviewsCol(venueId).add(review.toFirestore());
    // Increment review count on venue
    await _venuesCol.doc(venueId).update({
      'reviewCount': FieldValue.increment(1),
    });
    return ref.id;
  }

  Future<void> updateReview(
          String venueId, String reviewId, Map<String, dynamic> data) =>
      _reviewsCol(venueId).doc(reviewId).update(data);

  Future<void> deleteReview(String venueId, String reviewId) async {
    await _reviewsCol(venueId).doc(reviewId).delete();
    await _venuesCol.doc(venueId).update({
      'reviewCount': FieldValue.increment(-1),
    });
  }

  Stream<List<Review>> reviewsStream(String venueId, {int limit = 20}) =>
      _reviewsCol(venueId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(Review.fromFirestore).toList());

  // ═══════════════════════════════════════════════════════════════════════
  // ROUTES — /routes/{routeId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _routesCol =>
      _db.collection('routes');

  Future<String> addRoute(GtgRoute route) async {
    final ref = await _routesCol.add(route.toFirestore());
    return ref.id;
  }

  Future<GtgRoute?> getRoute(String id) async {
    final doc = await _routesCol.doc(id).get();
    if (!doc.exists) return null;
    return GtgRoute.fromFirestore(doc);
  }

  Future<void> updateRoute(String id, Map<String, dynamic> data) =>
      _routesCol.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  Stream<List<GtgRoute>> userRoutesStream(String userId) => _routesCol
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(GtgRoute.fromFirestore).toList());

  // ═══════════════════════════════════════════════════════════════════════
  // CHAT ROOMS — /chatRooms/{roomId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _chatRoomsCol =>
      _db.collection('chatRooms');

  Future<String> createChatRoom(ChatRoom room) async {
    final ref = await _chatRoomsCol.add(room.toFirestore());
    return ref.id;
  }

  Stream<List<ChatRoom>> userChatRoomsStream(String userId) => _chatRoomsCol
      .where('participants', arrayContains: userId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(ChatRoom.fromFirestore).toList());

  // ── Messages subcollection ──

  CollectionReference<Map<String, dynamic>> _messagesCol(String roomId) =>
      _chatRoomsCol.doc(roomId).collection('messages');

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    final batch = _db.batch();
    final msgRef = _messagesCol(roomId).doc();
    batch.set(msgRef, message.toFirestore());
    // Update last message on chat room
    batch.update(_chatRoomsCol.doc(roomId), {
      'lastMessage': {
        'text': message.text,
        'senderId': message.senderId,
        'sentAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Stream<List<ChatMessage>> messagesStream(String roomId, {int limit = 50}) =>
      _messagesCol(roomId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());

  Future<void> markMessagesRead(
      String roomId, String userId, List<String> messageIds) async {
    final batch = _db.batch();
    for (final id in messageIds) {
      batch.update(_messagesCol(roomId).doc(id), {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    // Reset unread count for this user
    batch.update(_chatRoomsCol.doc(roomId), {
      'unreadCount.$userId': 0,
    });
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS — /users/{userId}/notifications/{id}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _notificationsCol(String userId) =>
      _usersCol.doc(userId).collection('notifications');

  Future<void> addNotification(String userId, AppNotification notif) =>
      _notificationsCol(userId).add(notif.toFirestore());

  Stream<List<AppNotification>> notificationsStream(String userId,
          {int limit = 30}) =>
      _notificationsCol(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) =>
              snap.docs.map(AppNotification.fromFirestore).toList());

  Future<void> markNotificationRead(String userId, String notifId) =>
      _notificationsCol(userId).doc(notifId).update({'isRead': true});

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _notificationsCol(userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAYMENTS — /payments/{paymentId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _paymentsCol =>
      _db.collection('payments');

  Future<String> addPayment(Payment payment) async {
    final ref = await _paymentsCol.add(payment.toFirestore());
    return ref.id;
  }

  Future<Payment?> getPayment(String id) async {
    final doc = await _paymentsCol.doc(id).get();
    if (!doc.exists) return null;
    return Payment.fromFirestore(doc);
  }

  Stream<List<Payment>> userPaymentsStream(String userId) => _paymentsCol
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Payment.fromFirestore).toList());

  // ═══════════════════════════════════════════════════════════════════════
  // REPORTS — /reports/{reportId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _db.collection('reports');

  Future<String> addReport(Report report) async {
    final ref = await _reportsCol.add(report.toFirestore());
    return ref.id;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LIVE LOCATIONS — /liveLocations/{sessionId}
  // ═══════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _liveLocCol =>
      _db.collection('liveLocations');

  Future<void> updateLiveLocation(LiveLocation loc) =>
      _liveLocCol.doc(loc.id).set(loc.toFirestore());

  Future<void> removeLiveLocation(String sessionId) =>
      _liveLocCol.doc(sessionId).delete();

  Stream<List<LiveLocation>> liveLocationsForRoute(String routeId) =>
      _liveLocCol
          .where('routeId', isEqualTo: routeId)
          .snapshots()
          .map((snap) =>
              snap.docs.map(LiveLocation.fromFirestore).toList());

  // ═══════════════════════════════════════════════════════════════════════
  // CONFIG — /config/app
  // ═══════════════════════════════════════════════════════════════════════

  Future<AppConfig> getAppConfig() async {
    final doc = await _db.collection('config').doc('app').get();
    if (!doc.exists) return const AppConfig();
    return AppConfig.fromFirestore(doc);
  }

  Stream<AppConfig> appConfigStream() => _db
      .collection('config')
      .doc('app')
      .snapshots()
      .map((doc) =>
          doc.exists ? AppConfig.fromFirestore(doc) : const AppConfig());
}
