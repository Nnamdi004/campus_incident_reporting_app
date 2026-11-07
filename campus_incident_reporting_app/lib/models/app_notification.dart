import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String recipientId;
  final String reportId;
  final String title;
  final String message;
  final String status;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.reportId,
    required this.title,
    required this.message,
    required this.status,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return AppNotification(
      id: document.id,
      recipientId: data['recipientId'] ?? '',
      reportId: data['reportId'] ?? '',
      title: data['title'] ?? 'Report update',
      message: data['message'] ?? '',
      status: data['status'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'reportId': reportId,
      'title': title,
      'message': message,
      'status': status,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
