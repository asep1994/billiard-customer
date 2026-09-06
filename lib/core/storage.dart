import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for the one thing we persist:
/// the customer's Sanctum token.
class TokenStorage {
  static const _key = 'billiard_customer_token';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Whether the user has already swiped through the onboarding slides, so the
/// splash screen only shows them once per install.
class OnboardingPreference {
  static const _key = 'billiard_customer_onboarding_seen';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
