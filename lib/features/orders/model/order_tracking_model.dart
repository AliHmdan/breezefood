import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverTrackingResponse {
  final bool tracking;
  final double latitude;
  final double longitude;
  final int updatedAt;

  DriverTrackingResponse({
    required this.tracking,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory DriverTrackingResponse.fromJson(Map<String, dynamic> json) {
    return DriverTrackingResponse(
      tracking: json["tracking"] == true,
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      updatedAt: _toInt(json["updated_at"]),
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}
