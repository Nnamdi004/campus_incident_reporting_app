// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:provider/provider.dart';

import 'package:campus_incident_reporting_app/main.dart';
import 'package:campus_incident_reporting_app/providers/auth_provider.dart';

void main() {
  testWidgets('AuthGate shows a loading indicator during initialization',
      (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _InitializingAuthProvider(),
      child: const MaterialApp(home: AuthGate()),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _InitializingAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isInitializing => true;

  @override
  bool get isLoading => true;

  @override
  User? get user => null;

  @override
  Future<bool> login({required String email, required String password}) async =>
      false;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async =>
      false;
}

class MyApp {
  const MyApp();
}
