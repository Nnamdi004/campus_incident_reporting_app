import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AppNotification> _notifications = [];

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<AppNotification>>? _notificationSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  NotificationProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthChange,
    );
  }

  Future<void> _handleAuthChange(User? user) async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    _notifications = [];
    _errorMessage = null;

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _notificationSubscription = _firestoreService
        .getNotifications(user.uid)
        .listen(
          (notifications) {
            _notifications = notifications;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Unable to load notifications.';
            notifyListeners();
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
    } catch (_) {
      _errorMessage = 'Could not update notification.';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      await _firestoreService.markAllNotificationsAsRead(userId);
    } catch (_) {
      _errorMessage = 'Could not update notifications.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
