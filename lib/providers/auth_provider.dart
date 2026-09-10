import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/push_notification_service.dart';
import '../core/storage.dart';
import '../models/customer_account.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Holds the logged-in customer account and drives the router's redirect
/// logic. `unknown` is the brief startup state while we check for a saved
/// token; the splash screen waits on it before deciding where to go.
class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiClient? apiClient, TokenStorage? storage})
      : _api = apiClient ?? ApiClient(),
        _storage = storage ?? TokenStorage();

  final ApiClient _api;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.unknown;
  CustomerAccount? customer;

  Future<void> bootstrap() async {
    final token = await _storage.read();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await _api.get('/customer/me');
      customer = CustomerAccount.fromJson(response['data'] as Map<String, dynamic>);
      status = AuthStatus.authenticated;
      unawaited(PushNotificationService.instance.registerToken());
    } catch (_) {
      await _storage.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _api.post('/customer/login', data: {
      'email': email,
      'password': password,
    });

    await _storage.save(response['token'] as String);
    customer = CustomerAccount.fromJson(response['customer'] as Map<String, dynamic>);
    status = AuthStatus.authenticated;
    unawaited(PushNotificationService.instance.registerToken());
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/customer/register', data: {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    await _storage.save(response['token'] as String);
    customer = CustomerAccount.fromJson(response['customer'] as Map<String, dynamic>);
    status = AuthStatus.authenticated;
    unawaited(PushNotificationService.instance.registerToken());
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? currentPassword,
    String? password,
  }) async {
    final changingPassword = password != null && password.isNotEmpty;

    final response = await _api.put('/customer/me', data: {
      'name': name,
      'email': email,
      'phone': phone,
      if (changingPassword) 'current_password': currentPassword,
      if (changingPassword) 'password': password,
      if (changingPassword) 'password_confirmation': password,
    });

    customer = CustomerAccount.fromJson(response['data'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    await PushNotificationService.instance.unregisterToken();

    try {
      await _api.post('/customer/logout');
    } catch (_) {
      // token may already be invalid server-side; clear local state regardless
    }

    await _storage.clear();
    customer = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
