import 'dart:io';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'storage.dart';

/// `10.0.2.2` is the standard Android emulator alias for the host machine's
/// `localhost` - it only resolves inside the emulator. A physical device on
/// the same Wi-Fi needs the host's actual LAN IP instead, passed at build/run
/// time: `flutter run --dart-define=DEV_HOST=192.168.1.5` (find your IP with
/// `ipconfig` on Windows or `ifconfig`/`ip addr` on macOS/Linux). The Laravel
/// dev server also needs to be started with `php artisan serve --host=0.0.0.0`
/// so it accepts connections from outside the machine.
const _devHostOverride = String.fromEnvironment('DEV_HOST');

String _apiHost() {
  if (_devHostOverride.isNotEmpty) return _devHostOverride;
  if (Platform.isAndroid) return '10.0.2.2';
  return 'localhost';
}

String _defaultBaseUrl() => 'http://${_apiHost()}:8000/api/v1';

/// The backend serializes file URLs (venue photos, etc.) using its own
/// `APP_URL`, which is `http://localhost:8000` in local dev - not reachable
/// from a device other than the host itself, hence the same host swap as
/// [_defaultBaseUrl] above. Every displayed media URL should be passed
/// through this first.
String resolveMediaUrl(String url) => url.replaceFirst('localhost', _apiHost());

/// The scheme+host+port the backend itself is reachable at from this device -
/// i.e. Duitku's configured `returnUrl`. Used to detect, from inside the
/// in-app payment WebView, when Duitku has redirected back to us.
String apiOrigin() => 'http://${_apiHost()}:8000';

/// Thin Dio wrapper: attaches the customer's bearer token to every request
/// and translates Laravel's error JSON into an [ApiException].
class ApiClient {
  ApiClient({String? baseUrl, TokenStorage? storage})
      : _storage = storage ?? TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultBaseUrl(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final Dio _dio;
  final TokenStorage _storage;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    return _send(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    return _send(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _send(() => _dio.delete(path));
  }

  Future<Map<String, dynamic>> _send(Future<Response> Function() request) async {
    try {
      final response = await request();
      if (response.data == null || response.data is! Map<String, dynamic>) {
        return <String, dynamic>{};
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      throw _translate(error);
    }
  }

  ApiException _translate(DioException error) {
    final response = error.response;
    final body = response?.data;

    if (body is Map<String, dynamic>) {
      final message = (body['message'] as String?)?.trim();
      final rawErrors = body['errors'];
      final errors = <String, List<String>>{};

      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((v) => v.toString()).toList();
          }
        });
      }

      return ApiException(
        statusCode: response?.statusCode,
        message: (message != null && message.isNotEmpty) ? message : _fallbackMessage(error),
        errors: errors,
      );
    }

    return ApiException(statusCode: response?.statusCode, message: _fallbackMessage(error));
  }

  String _fallbackMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Periksa koneksi internet kamu.';
    }
    return error.response?.statusMessage ?? 'Terjadi kesalahan. Coba lagi.';
  }
}
