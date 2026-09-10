import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/app_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/state_views.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationRepository();
  late Future<NotificationsPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.list();
  }

  void _reload() => setState(() {
    _future = _repository.list();
  });

  Future<void> _markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (_) {
      // best-effort - the list still reflects the server's actual state on next reload
    }
    if (mounted) _reload();
  }

  Future<void> _openNotification(AppNotification notification) async {
    if (!notification.isRead) {
      setState(() => notification.readAt = nowInJakarta());
      _repository.markAsRead(notification.id).catchError((_) {});
    }
    if (notification.bookingId != null) {
      context.push('/bookings/${notification.bookingId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GradientHeader(
            title: 'Notifikasi',
            actions: [
              TextButton(
                onPressed: _markAllAsRead,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Tandai semua'),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: FutureBuilder<NotificationsPage>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    final message = snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Gagal memuat notifikasi.';
                    return ListView(
                      children: [ErrorView(message: message, onRetry: _reload)],
                    );
                  }

                  final notifications = snapshot.data?.items ?? [];
                  if (notifications.isEmpty) {
                    return ListView(
                      children: const [
                        EmptyView(
                          message: 'Belum ada notifikasi.',
                          icon: Icons.notifications_none,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () => _openNotification(notification),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case 'booking_confirmed':
        return Icons.check_circle_outline;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      case 'payment_received':
        return Icons.payments_outlined;
      case 'booking_reminder':
        return Icons.access_time;
      case 'payment_reminder':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'booking_confirmed':
        return AppColors.primary;
      case 'booking_cancelled':
        return AppColors.danger;
      case 'payment_received':
        return AppColors.info;
      case 'booking_reminder':
      case 'payment_reminder':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(_icon, size: 20, color: _iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notifikasi',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message ?? '',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRelativeTime(notification.createdAt),
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
