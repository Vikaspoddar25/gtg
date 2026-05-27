import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Payment — `/payments/{paymentId}`
class Payment extends Equatable {
  final String id;
  final String userId;
  final String venueId;
  final String venueName;
  final double amount;
  final String currency; // "INR" | "AED"
  final String gateway; // "razorpay" | "stripe"
  final String gatewayOrderId;
  final String? gatewayPaymentId;
  final String? gatewaySignature;
  final String status; // "created" | "authorized" | "captured" | "failed" | "refunded"
  final BookingDetails? bookingDetails;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.amount,
    this.currency = 'INR',
    required this.gateway,
    required this.gatewayOrderId,
    this.gatewayPaymentId,
    this.gatewaySignature,
    this.status = 'created',
    this.bookingDetails,
    required this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Payment(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      venueId: d['venueId'] as String? ?? '',
      venueName: d['venueName'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] as String? ?? 'INR',
      gateway: d['gateway'] as String? ?? 'razorpay',
      gatewayOrderId: d['gatewayOrderId'] as String? ?? '',
      gatewayPaymentId: d['gatewayPaymentId'] as String?,
      gatewaySignature: d['gatewaySignature'] as String?,
      status: d['status'] as String? ?? 'created',
      bookingDetails: d['bookingDetails'] is Map<String, dynamic>
          ? BookingDetails.fromMap(
              d['bookingDetails'] as Map<String, dynamic>)
          : null,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'venueId': venueId,
        'venueName': venueName,
        'amount': amount,
        'currency': currency,
        'gateway': gateway,
        'gatewayOrderId': gatewayOrderId,
        if (gatewayPaymentId != null) 'gatewayPaymentId': gatewayPaymentId,
        if (gatewaySignature != null) 'gatewaySignature': gatewaySignature,
        'status': status,
        if (bookingDetails != null)
          'bookingDetails': bookingDetails!.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id];
}

class BookingDetails {
  final DateTime date;
  final String time;
  final int guests;
  final String? notes;

  const BookingDetails({
    required this.date,
    required this.time,
    required this.guests,
    this.notes,
  });

  factory BookingDetails.fromMap(Map<String, dynamic> m) => BookingDetails(
        date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        time: m['time'] as String? ?? '',
        guests: (m['guests'] as num?)?.toInt() ?? 1,
        notes: m['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'time': time,
        'guests': guests,
        if (notes != null) 'notes': notes,
      };
}
