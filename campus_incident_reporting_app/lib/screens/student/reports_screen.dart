import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/campus_report.dart';
import '../../providers/report_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'All Categories';
  String selectedStatus = 'All';

  static const Color primaryColor = Color(0xFF2457C5);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  final List<String> categories = const [
    'All Categories',
    'Electricity',
    'Water Supply',
    'Sanitation',
    'Damaged Furniture',
    'Broken Facilities',
    'Campus Safety',
    'Other',
  ];

  final List<String> statuses = const [
    'All',
    'Submitted',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  List<CampusReport> filterReports(List<CampusReport> reports) {
    final query = _searchController.text.trim().toLowerCase();

    return reports.where((report) {
      final matchesSearch =
          report.title.toLowerCase().contains(query) ||
          report.location.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'All Categories' ||
          report.category == selectedCategory;

      final matchesStatus =
          selectedStatus == 'All' ||
          report.status.toLowerCase() == selectedStatus.toLowerCase();

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
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
      case 'electricity':
        return Icons.bolt_outlined;
      case 'water supply':
        return Icons.water_drop_outlined;
      case 'sanitation':
        return Icons.cleaning_services_outlined;
      case 'damaged furniture':
        return Icons.chair_outlined;
      case 'campus safety':
        return Icons.security_outlined;
      case 'broken facilities':
        return Icons.build_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<String?> getPhotoUrl(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;

    return await Supabase.instance.client.storage
        .from('incident-photos')
        .createSignedUrl(photoPath, 3600);
  }

  void showReportDetails(CampusReport report) {
    final color = statusColor(report.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              12,
              22,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17243A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        categoryIcon(report.category),
                        color: primaryColor,
                        size: 27,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (report.photoPath != null &&
                      report.photoPath!.isNotEmpty) ...[
                    const Text(
                      'Attached Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String?>(
                      future: getPhotoUrl(report.photoPath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return Container(
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text('Unable to load attached photo.'),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            snapshot.data!,
                            width: double.infinity,
                            height: 210,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 120,
                              alignment: Alignment.center,
                              color: Colors.grey.shade100,
                              child: const Text(
                                'Photo could not be displayed.',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                  ],

                  _DetailRow(label: 'Category', value: report.category),
                  _DetailRow(label: 'Location', value: report.location),
                  _DetailRow(
                    label: 'Date submitted',
                    value: formatDate(report.createdAt),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.6),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        );
      },
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
    final visibleReports = filterReports(provider.reports);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Campus Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF17243A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Browse campus issues',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17243A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Search reports and keep track of their progress.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by title, location or description',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Filter by category',
                      prefixIcon: const Icon(Icons.category_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Report status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 9),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statuses.map((status) {
                        final selected = selectedStatus == status;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => selectedStatus = status);
                            },
                            selectedColor: primaryColor.withValues(alpha: 0.14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'All reports',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${visibleReports.length} found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 45,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              provider.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : visibleReports.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 55,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No reports found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.reports.isEmpty
                                  ? 'Submitted reports will appear here.'
                                  : 'Try changing your search or filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: visibleReports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = visibleReports[index];
                        final color = statusColor(report.status);

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE8ECF3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showReportDetails(report),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Container(
                                    width: 49,
                                    height: 49,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.09,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      categoryIcon(report.category),
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          report.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 9),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 5,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 9,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: color.withValues(
                                                  alpha: 0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                report.status,
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              formatDate(report.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
