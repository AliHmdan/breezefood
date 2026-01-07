import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  const MapPickerResult({required this.latitude, required this.longitude});
}

class MapPickerScreen extends StatefulWidget {
  final LatLng initial;
  const MapPickerScreen({super.key, required this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _ctrl;
  late LatLng _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: widget.initial, zoom: 16),
            onMapCreated: (c) => _ctrl = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (pos) => setState(() => _picked = pos),
            markers: {
              Marker(
                markerId: const MarkerId("picked"),
                position: _picked,
                draggable: true,
                onDragEnd: (pos) => setState(() => _picked = pos),
              ),
            },
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MapPickerResult(latitude: _picked.latitude, longitude: _picked.longitude),
                  );
                },
                child: const Text("Confirm location"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
