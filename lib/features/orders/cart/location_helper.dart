import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 15),
    );
  }

  static Future<String> reverseGeocodeText({
    required double lat,
    required double lng,
    required String fallback,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return fallback;

      final p = placemarks.first;
      final composed =
          "${p.subAdministrativeArea ?? ''} ${p.locality ?? ''} ${p.street ?? ''}"
              .trim();

      return composed.isNotEmpty ? composed : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
