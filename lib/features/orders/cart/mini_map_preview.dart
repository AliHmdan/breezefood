import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMapPreview extends StatefulWidget {
  final double lat;
  final double lng;
  final VoidCallback onTap;

  const MiniMapPreview({
    super.key,
    required this.lat,
    required this.lng,
    required this.onTap,
  });

  @override
  State<MiniMapPreview> createState() => _MiniMapPreviewState();
}

class _MiniMapPreviewState extends State<MiniMapPreview> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant MiniMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      final newPos = LatLng(widget.lat, widget.lng);
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pos = LatLng(widget.lat, widget.lng);

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: pos, zoom: 16),
                onMapCreated: (c) => _controller = c,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: true,
                markers: const {},
              ),
              Center(
                child: Icon(
                  Icons.location_history,
                  size: 22.sp,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
