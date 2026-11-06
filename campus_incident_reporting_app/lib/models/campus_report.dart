import 'package:cloud_firestore/cloud_firestore.dart';

class CampusReport {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String studentId;
  final String studentEmail;
  final String? photoPath;
  final DateTime createdAt;

  CampusReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.studentId,
    required this.studentEmail,
    this.photoPath,
    required this.createdAt,
  });

  factory CampusReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return CampusReport(
      id: document.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      location: data['location'] ?? '',
      status: data['status'] ?? 'Submitted',
      studentId: data['studentId'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      photoPath: data['photoPath'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'studentId': studentId,
      'studentEmail': studentEmail,
      'photoPath': photoPath,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
