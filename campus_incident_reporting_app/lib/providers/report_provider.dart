import 'dart:async';

import 'package:flutter/material.dart';

import '../models/campus_report.dart';
import '../services/firestore_service.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CampusReport> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<List<CampusReport>>? _subscription;

  List<CampusReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReportProvider() {
    _listenToReports();
  }

  void _listenToReports() {
    _subscription = _firestoreService.getReports().listen(
      (reports) {
        _reports = reports;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Unable to load reports. Please try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> submitReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required String studentId,
    required String studentEmail,
    String? imageUrl,
  }) async {
    try {
      await _firestoreService.submitReport(
        title: title,
        description: description,
        category: category,
        location: location,
        studentId: studentId,
        studentEmail: studentEmail,
        imageUrl: imageUrl,
      );

      return true;
    } catch (error) {
      _errorMessage = 'Failed to submit your report. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReportStatus({
    required String reportId,
    required String newStatus,
  }) async {
    try {
      await _firestoreService.updateReportStatus(
        reportId: reportId,
        newStatus: newStatus,
      );

      return true;
    } catch (error) {
      _errorMessage = 'Unable to update report status.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}