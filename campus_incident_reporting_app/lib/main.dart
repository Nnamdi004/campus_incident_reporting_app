import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/staff/staff_dashboard_screen.dart';

import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/student/dashboard_screen.dart';
import 'screens/student/reports_screen.dart';
import 'screens/student/report_form_screen.dart';
import 'screens/student/profile_screen.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://iinyrxsvbmehqmqwgpst.supabase.co',
    publishableKey: 'sb_publishable_fWWfKMg8MlpObIn8uKShpQ_3DyEkVuo',
    accessToken: () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return '';
      }
      return user.getIdToken();
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const CampusReportApp(),
    ),
  );
}

class CampusReportApp extends StatelessWidget {
  const CampusReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2457C5),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Campus Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FC),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF17243A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2457C5), width: 1.5),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isAuthenticated) {
          return const AuthScreen();
        }

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          return const AuthScreen();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to verify your account role. '
                      'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final userData = snapshot.data?.data();
            final role = userData?['role']?.toString().toLowerCase();

            if (role == 'staff') {
              return const StaffDashboardScreen();
            }

            return const MainNavigation();
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  void openReports() {
    setState(() => selectedIndex = 1);
  }

  void openReportForm() {
    setState(() => selectedIndex = 2);
  }

  late final List<Widget> pages = [
    DashboardScreen(onReportTap: openReportForm, onViewAllTap: openReports),
    const ReportsScreen(),
    const ReportFormScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
