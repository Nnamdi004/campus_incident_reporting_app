import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campus_report.dart';
import '../models/app_notification.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  Future<void> submitReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required String studentId,
    required String studentEmail,
    String? photoPath,
  }) async {
    final report = CampusReport(
      id: '',
      title: title,
      description: description,
      category: category,
      location: location,
      status: 'Submitted',
      studentId: studentId,
      studentEmail: studentEmail,
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );

    await _reportsCollection.add(report.toFirestore());
  }

  Stream<List<CampusReport>> getReports() {
    return _reportsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => CampusReport.fromFirestore(document))
              .toList(),
        );
  }

  // Update report status and notify the student.
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
  }) async {
    final reportReference = _reportsCollection.doc(reportId);
    final reportSnapshot = await reportReference.get();

    if (!reportSnapshot.exists) {
      throw Exception('Report not found.');
    }

    final report = CampusReport.fromFirestore(reportSnapshot);

    if (report.status == newStatus) return;

    await reportReference.update({
      'status': newStatus,
    });

    final notification = AppNotification(
      id: '',
      recipientId: report.studentId,
      reportId: reportId,
      title: 'Report status updated',
      message: 'Your report "${report.title}" is now $newStatus.',
      status: newStatus,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _notificationsCollection.add(notification.toFirestore());
  }

  // Listen to notifications belonging to a particular student.
  Stream<List<AppNotification>> getNotifications(String studentId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();

      notifications.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return notifications;
    });
  }

  // Mark a notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all notifications as read.
  Future<void> markAllNotificationsAsRead(String studentId) async {
    final snapshot = await _notificationsCollection
        .where('recipientId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(document.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
