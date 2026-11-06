import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campus_report.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  // Submit a new incident report.
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

  // Retrieve reports in real time.
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

  // Update a report's status.
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
  }) async {
    await _reportsCollection.doc(reportId).update({
      'status': newStatus,
    });
  }
}
