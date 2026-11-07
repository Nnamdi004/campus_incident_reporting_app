import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/campus_report.dart';

class StaffReportDetailsScreen extends StatefulWidget {
  final CampusReport report;
  final ValueChanged<String> onStatusChanged;

  const StaffReportDetailsScreen({
    super.key,
    required this.report,
    required this.onStatusChanged,
  });

  @override
  State<StaffReportDetailsScreen> createState() =>
      _StaffReportDetailsScreenState();
}

class _StaffReportDetailsScreenState
    extends State<StaffReportDetailsScreen> {
  String? _photoUrl;
  bool _loadingPhoto = false;

  static const primary = Color(0xFF2457C5);

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = widget.report.photoPath;

    if (path == null || path.isEmpty) return;

    setState(() => _loadingPhoto = true);

    try {
      final url = await Supabase.instance.client.storage
          .from('incident-photos')
          .createSignedUrl(path, 3600);

      if (!mounted) return;

      setState(() => _photoUrl = url);
    } catch (_) {
      // The report details remain available if the photo cannot load.
    } finally {
      if (mounted) {
        setState(() => _loadingPhoto = false);
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusColor = _statusColor(report.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Report Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.category.toUpperCase(),
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17243A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      height: 1.6,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _detailRow(
                    Icons.location_on_outlined,
                    'Location',
                    report.location,
                  ),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Date reported',
                    '${report.createdAt.day}/'
                        '${report.createdAt.month}/'
                        '${report.createdAt.year}',
                  ),
                  _detailRow(
                    Icons.access_time,
                    'Time reported',
                    TimeOfDay.fromDateTime(report.createdAt)
                        .format(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _sectionCard(
              title: 'Student Information',
              icon: Icons.person_outline,
              children: [
                _detailRow(
                  Icons.email_outlined,
                  'Email',
                  report.studentEmail,
                ),
                _detailRow(
                  Icons.badge_outlined,
                  'Student ID',
                  report.studentId,
                ),
              ],
            ),

            const SizedBox(height: 18),

            _sectionCard(
              title: 'Attached Photograph',
              icon: Icons.image_outlined,
              children: [
                if (report.photoPath == null ||
                    report.photoPath!.isEmpty)
                  const Text(
                    'No photograph was attached to this report.',
                    style: TextStyle(color: Colors.blueGrey),
                  )
                else if (_loadingPhoto)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _photoUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Text('Unable to display photograph.'),
                    ),
                  )
                else
                  const Text(
                    'Photograph could not be loaded.',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            _sectionCard(
              title: 'Update Report Status',
              icon: Icons.sync,
              children: [
                const Text(
                  'Select a new status to notify the student.',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 14),
                ...['Submitted', 'In Progress', 'Resolved', 'Rejected']
                    .map((status) {
                  final selected = report.status == status;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: OutlinedButton(
                      onPressed: selected
                          ? null
                          : () => _confirmStatusChange(status),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(
                          color: selected ? primary : Colors.grey.shade300,
                        ),
                        backgroundColor: selected
                            ? primary.withValues(alpha: 0.08)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: primary,
                          ),
                          const SizedBox(width: 10),
                          Text(status),
                          const Spacer(),
                          if (selected)
                            const Text(
                              'Current',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStatusChange(String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update report status?'),
        content: Text('Change this report status to "$status"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onStatusChanged(status);
      Navigator.pop(context);
    }
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
