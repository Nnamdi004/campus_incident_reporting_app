import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Icons.hourglass_top_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
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
        return Colors.blue;
    }
  }

  void _openNotification(BuildContext context, AppNotification notification) {
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updates about your reports will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final color = _statusColor(notification.status);

                return ListTile(
                  onTap: () => _openNotification(context, notification),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(_statusIcon(notification.status), color: color),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2457C5),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 5),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  tileColor: notification.isRead
                      ? null
                      : const Color(0xFFF2F6FF),
                );
              },
            ),
    );
  }
}
