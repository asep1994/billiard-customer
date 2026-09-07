import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../repositories/device_token_repository.dart';
import '../router.dart';

/// Wraps Firebase Cloud Messaging: requests permission, keeps our backend's
/// record of this device's token up to date, and shows a system
/// notification while the app is in the foreground (FCM only does that
/// automatically when the app is backgrounded or terminated).
///
/// `initialize()` is safe to call once at app startup regardless of auth
/// state - it just wires up listeners. `registerToken()` is separate and
/// should only be called once a customer is actually logged in, since the
/// backend endpoint it hits requires authentication.
class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();

  late final FirebaseMessaging _messaging;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _deviceTokenRepository = DeviceTokenRepository();

  static const _channel = AndroidNotificationChannel(
    'booking_reminders',
    'Pengingat Booking',
    description: 'Notifikasi pengingat dan status booking kamu',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (response) => _openBooking(response.payload),
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) => _openBooking(message.data['booking_id']));

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _openBooking(initialMessage.data['booking_id']);
  }

  /// Fetches this device's current FCM token and sends it to the backend so
  /// it knows where to deliver this customer's pushes. Call after a
  /// successful login/register, and after `AuthProvider.bootstrap()`
  /// confirms an already-authenticated session. Failure here is never fatal
  /// - browsing and booking work fine without push notifications.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _deviceTokenRepository.register(token);
    } catch (e) {
      debugPrint('PushNotificationService.registerToken failed: $e');
    }

    _messaging.onTokenRefresh.listen((token) {
      _deviceTokenRepository.register(token).catchError((_) {});
    });
  }

  /// Best-effort: tells the backend to stop sending this device pushes for
  /// the account that's logging out.
  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _deviceTokenRepository.unregister(token);
    } catch (e) {
      debugPrint('PushNotificationService.unregisterToken failed: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['booking_id'] as String?,
    );
  }

  void _openBooking(String? bookingId) {
    if (bookingId == null || bookingId.isEmpty) return;
    router.push('/bookings/$bookingId');
  }
}
