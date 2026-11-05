import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onReportTap;

  const DashboardScreen({super.key, this.onReportTap});

  static const Color primaryColor = Color(0xFF2457C5);
  static const Color darkColor = Color(0xFF17243A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: primaryColor, size: 27),
            SizedBox(width: 9),
            Text(
              'Campus Report',
              style: TextStyle(fontWeight: FontWeight.bold, color: darkColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Student 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Help make your campus a better place.',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),

            // Report incident banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Notice something wrong?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Report campus problems so the right team can take action.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onReportTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Report an Issue'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Your Overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 14),

            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Submitted',
                    count: '0',
                    icon: Icons.assignment_outlined,
                    color: Color(0xFF2457C5),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'In Progress',
                    count: '0',
                    icon: Icons.pending_actions,
                    color: Color(0xFFE99A27),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Resolved',
                    count: '0',
                    icon: Icons.check_circle_outline,
                    color: Color(0xFF239B69),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Rejected',
                    count: '0',
                    icon: Icons.cancel_outlined,
                    color: Color(0xFFD9534F),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Reports navigation will be connected here.
                  },
                  child: const Text('View all'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 42, color: Colors.blueGrey),
                  SizedBox(height: 12),
                  Text(
                    'No reports yet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your submitted incidents will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.darkColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
