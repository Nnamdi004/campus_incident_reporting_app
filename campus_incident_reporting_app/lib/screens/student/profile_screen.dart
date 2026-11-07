import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final studentName = user?.displayName ?? 'Student';
    final studentEmail = user?.email ?? 'No email available';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            // Profile avatar
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE5EDFF),
              child: Icon(Icons.person, size: 55, color: Color(0xFF2457C5)),
            ),

            const SizedBox(height: 15),

            const Text(
              'Student Name',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              studentEmail,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EDFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'STUDENT ACCOUNT',
                style: TextStyle(
                  color: Color(0xFF2457C5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Account information
            _SectionTitle(title: 'Account Information'),

            _ProfileTile(
              icon: Icons.person_outline,
              title: 'Full Name',
              subtitle: studentName,
              onTap: () => _showMessage(
                context,
                'Profile editing will be available soon.',
              ),
            ),

            _ProfileTile(
              icon: Icons.email_outlined,
              title: 'Email Address',
              subtitle: 'student@university.edu',
            ),

            _ProfileTile(
              icon: Icons.school_outlined,
              title: 'Account Type',
              subtitle: 'Student',
            ),

            const SizedBox(height: 20),

            // App settings
            _SectionTitle(title: 'App Settings'),

            _ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage report notifications',
              onTap: () => _showMessage(
                context,
                'Notification settings will be available soon.',
              ),
            ),

            _ProfileTile(
              icon: Icons.help_outline,
              title: 'Help and Support',
              subtitle: 'Get assistance with the app',
              onTap: () => _showMessage(
                context,
                'Help and support will be available soon.',
              ),
            ),

            _ProfileTile(
              icon: Icons.info_outline,
              title: 'About Campus Report',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Campus Report',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'A campus incident reporting application.',
                );
              },
            ),

            const SizedBox(height: 25),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Campus Report • Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2457C5)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
