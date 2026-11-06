import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/campus_report.dart';
import '../../providers/report_provider.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onReportTap;
  final VoidCallback? onViewAllTap;

  const DashboardScreen({
    super.key,
    this.onReportTap,
    this.onViewAllTap,
  });

  static const Color primaryColor = Color(0xFF2457C5);
  static const Color darkColor = Color(0xFF17243A);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String getFirstName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name.split(' ').first;
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Student';
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF239B69);
      case 'in progress':
        return const Color(0xFFE99A27);
      case 'rejected':
        return const Color(0xFFD9534F);
      default:
        return primaryColor;
    }
  }

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water supply':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.bolt_outlined;
      case 'sanitation':
        return Icons.cleaning_services_outlined;
      case 'damaged furniture':
        return Icons.chair_outlined;
      case 'campus safety':
        return Icons.security_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final reports = provider.reports;

    final submitted = reports.where(
      (r) => r.status.toLowerCase() == 'submitted',
    ).length;

    final inProgress = reports.where(
      (r) => r.status.toLowerCase() == 'in progress',
    ).length;

    final resolved = reports.where(
      (r) => r.status.toLowerCase() == 'resolved',
    ).length;

    final rejected = reports.where(
      (r) => r.status.toLowerCase() == 'rejected',
    ).length;

    final recentReports = reports.take(3).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Row(
          children: [
            Icon(Icons.school, color: primaryColor, size: 27),
            SizedBox(width: 9),
            Text(
              'Campus Report',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _ComingSoonScreen(
                    title: 'Notifications',
                    message: 'Your campus report notifications will appear here.',
                    icon: Icons.notifications_none,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: darkColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              '${getGreeting()}, ${getFirstName()} 👋',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Help make your campus a better place.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 23),

            // Report banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2457C5),
                    Color(0xFF4386E8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'See an issue on campus?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Report it and help us create a safer, better campus for everyone.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onReportTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Report an Issue'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _SectionHeading(
              title: 'Report Summary',
              action: 'View all',
              onTap: onViewAllTap,
            ),
            const SizedBox(height: 14),

            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Submitted',
                      count: submitted,
                      icon: Icons.assignment_outlined,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'In Progress',
                      count: inProgress,
                      icon: Icons.pending_actions,
                      color: const Color(0xFFE99A27),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Resolved',
                      count: resolved,
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF239B69),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Rejected',
                      count: rejected,
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFFD9534F),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            _SectionHeading(
              title: 'Recent Reports',
              action: 'See all',
              onTap: onViewAllTap,
            ),
            const SizedBox(height: 12),

            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.errorMessage != null)
              _MessageCard(
                icon: Icons.error_outline,
                message: provider.errorMessage!,
              )
            else if (recentReports.isEmpty)
              const _MessageCard(
                icon: Icons.inbox_outlined,
                message: 'No reports yet. Your submitted incidents will appear here.',
              )
            else
              ...recentReports.map(
                (report) => _RecentReportCard(
                  report: report,
                  icon: categoryIcon(report.category),
                  statusColor: statusColor(report.status),
                  date: formatDate(report.createdAt),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onTap;

  const _SectionHeading({
    required this.title,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: DashboardScreen.darkColor,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
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
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 13),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.darkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportCard extends StatelessWidget {
  final CampusReport report;
  final IconData icon;
  final Color statusColor;
  final String date;

  const _RecentReportCard({
    required this.report,
    required this.icon,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: DashboardScreen.primaryColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: DashboardScreen.primaryColor,
          ),
        ),
        title: Text(
          report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: Colors.blueGrey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _ComingSoonScreen({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 55, color: DashboardScreen.primaryColor),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
