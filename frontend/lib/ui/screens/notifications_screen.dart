import 'package:campus_lost_found/core/models/notification.dart';
import 'package:campus_lost_found/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = context.read<NotificationService>();
      final notifications = await service.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openNotification(AppNotification notification) async {
    final service = context.read<NotificationService>();
    if (!notification.isRead) {
      await service.markAsRead(notification.id);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((entry) {
            if (entry.id == notification.id) {
              return AppNotification(
                id: entry.id,
                type: entry.type,
                message: entry.message,
                isRead: true,
                createdAt: entry.createdAt,
                relatedItemId: entry.relatedItemId,
                relatedItemTitle: entry.relatedItemTitle,
              );
            }
            return entry;
          }).toList();
        });
      }
    }

    if (notification.relatedItemId != null && mounted) {
      context.push('/item/${notification.relatedItemId}');
    }
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Icons.link;
      case NotificationType.claim:
        return Icons.assignment;
      case NotificationType.claimApproved:
        return Icons.check_circle;
      case NotificationType.claimRejected:
        return Icons.cancel;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Colors.blue;
      case NotificationType.claim:
        return Colors.orange;
      case NotificationType.claimApproved:
        return Colors.green;
      case NotificationType.claimRejected:
        return Colors.red;
      case NotificationType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications yet'))
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _colorForType(notification.type).withValues(alpha: 0.15),
                              child: Icon(
                                _iconForType(notification.type),
                                color: _colorForType(notification.type),
                              ),
                            ),
                            title: Text(
                              notification.typeLabel,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification.message),
                                if (notification.formattedDate.isNotEmpty)
                                  Text(
                                    notification.formattedDate,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: notification.isRead
                                ? null
                                : const Icon(Icons.circle, size: 10, color: Colors.blue),
                            onTap: () => _openNotification(notification),
                          );
                        },
                      ),
                    ),
    );
  }
}
