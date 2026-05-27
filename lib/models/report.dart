import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Report — `/reports/{reportId}`
class Report extends Equatable {
  final String id;
  final String reporterId;
  final String targetType; // "venue" | "review" | "user" | "message"
  final String targetId;
  final String reason;
  final String? description;
  final String status; // "pending" | "reviewed" | "resolved" | "dismissed"
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.reviewedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Report(
      id: doc.id,
      reporterId: d['reporterId'] as String? ?? '',
      targetType: d['targetType'] as String? ?? '',
      targetId: d['targetId'] as String? ?? '',
      reason: d['reason'] as String? ?? '',
      description: d['description'] as String?,
      status: d['status'] as String? ?? 'pending',
      reviewedBy: d['reviewedBy'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reporterId': reporterId,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (description != null) 'description': description,
        'status': status,
        if (reviewedBy != null) 'reviewedBy': reviewedBy,
        'createdAt': FieldValue.serverTimestamp(),
        if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      };

  @override
  List<Object?> get props => [id];
}
