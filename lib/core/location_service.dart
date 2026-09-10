import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Wraps geolocator with graceful fallbacks: any permission denial, disabled
/// service, or platform error just means "no location available" rather
/// than a crash - browsing still works, it just can't sort by distance.
class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        ).timeout(const Duration(seconds: 8));
      } on TimeoutException {
        // A fresh fix can take a while (or never arrive, e.g. some
        // emulators/indoor GPS) - a recent cached fix is still far more
        // useful than nothing for "nearest venue" sorting.
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }
}
