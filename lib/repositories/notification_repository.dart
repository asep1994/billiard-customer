import '../core/api_client.dart';
import '../models/app_notification.dart';

class NotificationsPage {
  NotificationsPage({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<NotificationsPage> list() async {
    final response = await _api.get('/customer/notifications', query: {'per_page': 50});
    final data = response['data'] as List<dynamic>? ?? [];
    final items = data.whereType<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
    return NotificationsPage(items: items, unreadCount: response['unread_count'] as int? ?? 0);
  }

  Future<void> markAsRead(String id) => _api.post('/customer/notifications/$id/read');

  Future<void> markAllAsRead() => _api.post('/customer/notifications/read-all');
}
