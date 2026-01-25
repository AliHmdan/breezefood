import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerIcon {
  static Future<BitmapDescriptor> fromAsset(
    String assetPath, {
    int width = 120,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final bytes = (await frame.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }
}
