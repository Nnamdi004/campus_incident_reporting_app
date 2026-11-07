import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/campus_report.dart';
import '../services/firestore_service.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CampusReport> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<CampusReport>>? _reportsSubscription;

  int _listenerVersion = 0;

  List<CampusReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReportProvider() {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChange,
      onError: (error) {
        debugPrint('Authentication stream error: $error');
        _errorMessage = 'Unable to verify your account.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _handleAuthChange(User? user) async {
    final version = ++_listenerVersion;

    await _reportsSubscription?.cancel();
    _reportsSubscription = null;

    if (version != _listenerVersion) return;

    if (user == null) {
      _reports = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _listenToReports(version);
  }

  void _listenToReports(int version) {
    _reportsSubscription = _firestoreService.getReports().listen(
      (reports) {
        if (version != _listenerVersion) return;

        _reports = reports;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        if (version != _listenerVersion) return;

        debugPrint('Firestore reports error: $error');
        debugPrintStack(stackTrace: stackTrace);

        _errorMessage = 'Unable to load reports. Please try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retryLoadingReports() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final version = ++_listenerVersion;

    await _reportsSubscription?.cancel();

    if (version != _listenerVersion) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _listenToReports(version);
  }

  Future<bool> submitReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required String studentId,
    required String studentEmail,
    String? photoPath,
  }) async {
    try {
      await _firestoreService.submitReport(
        title: title,
        description: description,
        category: category,
        location: location,
        studentId: studentId,
        studentEmail: studentEmail,
        photoPath: photoPath,
      );

      _errorMessage = null;
      return true;
    } catch (error) {
      debugPrint('Submit report error: $error');
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
      debugPrint('Update report status error: $error');
      _errorMessage = 'Unable to update report status.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }
}
