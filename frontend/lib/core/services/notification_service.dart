import 'package:campus_lost_found/core/models/notification.dart';
import 'package:campus_lost_found/core/services/api_service.dart';

class NotificationService {
  final ApiService apiService;

  NotificationService({required this.apiService});

  Future<List<AppNotification>> fetchNotifications() async {
    const query = r'''
      query GetNotifications {
        notifications(orderBy: { createdAt: desc }) {
          id
          type
          message
          isRead
          createdAt
          relatedItem {
            id
            title
          }
        }
      }
    ''';

    final result = await apiService.query(query);
    final notifications = result['notifications'] as List<dynamic>? ?? const [];
    return notifications
        .map((entry) => AppNotification.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<int> fetchUnreadCount() async {
    const query = r'''
      query GetUnreadCount {
        notifications(where: { isRead: { equals: false } }) {
          id
        }
      }
    ''';

    final result = await apiService.query(query);
    final notifications = result['notifications'] as List<dynamic>? ?? const [];
    return notifications.length;
  }

  Future<bool> markAsRead(String notificationId) async {
    const mutation = r'''
      mutation MarkNotificationRead($id: ID!) {
        updateNotification(
          where: { id: $id },
          data: { isRead: true }
        ) {
          id
          isRead
        }
      }
    ''';

    final result = await apiService.mutation(
      mutation,
      variables: {'id': notificationId},
    );

    return result.containsKey('updateNotification');
  }
}
