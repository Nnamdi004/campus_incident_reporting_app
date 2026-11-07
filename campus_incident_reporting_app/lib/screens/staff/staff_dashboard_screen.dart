import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/campus_report.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import 'staff_report_details_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  static const primary = Color(0xFF2457C5);

  String _selectedFilter = 'All';
  String _searchQuery = '';

  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _statuses = [
    'Submitted',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return primary;
    }
  }

  IconData _categoryIcon(String category) {
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of the staff account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthProvider>().logout();
  }

  Future<void> _changeStatus(
    CampusReport report,
    String newStatus,
  ) async {
    if (newStatus == report.status) return;

    try {
      await context.read<ReportProvider>().updateReportStatus(
        reportId: report.id,
        newStatus: newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report updated to $newStatus.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update report status.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openDetails(CampusReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffReportDetailsScreen(
          report: report,
          onStatusChanged: (status) =>
              _changeStatus(report, status),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final reports = provider.reports;

    final submitted =
        reports.where((r) => r.status == 'Submitted').length;
    final inProgress =
        reports.where((r) => r.status == 'In Progress').length;
    final resolved =
        reports.where((r) => r.status == 'Resolved').length;
    final rejected =
        reports.where((r) => r.status == 'Rejected').length;

    final filteredReports = reports.where((report) {
      final matchesFilter = _selectedFilter == 'All' ||
          report.status == _selectedFilter;

      final query = _searchQuery.toLowerCase();

      final matchesSearch = report.title.toLowerCase().contains(query) ||
          report.studentEmail.toLowerCase().contains(query) ||
          report.location.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded, color: primary),
            SizedBox(width: 10),
            Text(
              'Campus Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(
                      const Duration(milliseconds: 300),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Staff Dashboard',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17243A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Monitor campus incidents and manage reports.',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 24),

                      GridView.count(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 650
                                ? 4
                                : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: [
                          _SummaryCard(
                            title: 'Total Reports',
                            count: reports.length,
                            color: primary,
                            icon: Icons.assignment_outlined,
                          ),
                          _SummaryCard(
                            title: 'Submitted',
                            count: submitted,
                            color: Colors.blue,
                            icon: Icons.inbox_outlined,
                          ),
                          _SummaryCard(
                            title: 'In Progress',
                            count: inProgress,
                            color: Colors.orange,
                            icon: Icons.pending_actions,
                          ),
                          _SummaryCard(
                            title: 'Resolved',
                            count: resolved,
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      const Text(
                        'Manage Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search reports, students or locations',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            ..._statuses,
                          ].map((status) {
                            final selected =
                                _selectedFilter == status;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedFilter = status;
                                  });
                                },
                                selectedColor:
                                    primary.withValues(alpha: 0.12),
                                labelStyle: TextStyle(
                                  color: selected ? primary : Colors.black87,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredReports.length} reports found',
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$rejected rejected',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (filteredReports.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 50,
                                color: Colors.blueGrey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No reports found.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Try another search or filter.',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filteredReports.map(
                          (report) => _StaffReportCard(
                            report: report,
                            categoryIcon:
                                _categoryIcon(report.category),
                            statusColor:
                                _statusColor(report.status),
                            onTap: () => _openDetails(report),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffReportCard extends StatelessWidget {
  final CampusReport report;
  final IconData categoryIcon;
  final Color statusColor;
  final VoidCallback onTap;

  const _StaffReportCard({
    required this.report,
    required this.categoryIcon,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        const Color(0xFF2457C5).withValues(alpha: 0.10),
                    child: Icon(
                      categoryIcon,
                      color: const Color(0xFF2457C5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.category,
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      report.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      report.studentEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'View details',
                    style: TextStyle(
                      color: Color(0xFF2457C5),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
