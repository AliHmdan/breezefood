import 'dart:developer';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
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

  late final AuthFlowCubit cubit;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
    cubit = getIt<AuthFlowCubit>();
  }

  Future<String> _resolveAddress(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return "$lat, $lon";

      final p = placemarks.first;
      final parts = <String>[
        if ((p.street ?? '').trim().isNotEmpty) p.street!,
        if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!,
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!,
        if ((p.country ?? '').trim().isNotEmpty) p.country!,
      ];

      final txt = parts.join(', ').trim();
      return txt.isEmpty ? "$lat, $lon" : txt;
    } catch (_) {
      return "$lat, $lon";
    }
  }

  Future<void> _confirm() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final lat = _picked.latitude;
    final lon = _picked.longitude;

    try {
      final addressText = await _resolveAddress(lat, lon);

      // ✅ نفس UpdateAddressScreen: نحدث عنوان المستخدم عبر /update_address
      cubit.addAddress(address: addressText, lat: lat, lon: lon);
    } catch (e, st) {
      log("confirm error: $e\n$st");
      setState(() {
        _saving = false;
        _error = "Failed to update address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFlowCubit, AuthFlowState>(
      bloc: cubit,
      listener: (context, state) {
        state.whenOrNull(
          loading: () {
            // ما تعمل setState هون إذا بدك، لأنه نحن أصلاً عاملين _saving=true
          },
          error: (msg) {
            setState(() {
              _saving = false;
              _error = msg;
            });
          },
          addressAdded: (data) async {
            // ✅ رجّع نتيجة (lat/lon/address) لأي شاشة نادت MapPickerScreen
            final addressMsg = (data is Map)
                ? (data["address"]?.toString() ??
                      data["message"]?.toString() ??
                      "تم تحديث العنوان")
                : "تم تحديث العنوان";

            final result = MapPickerResult(
              latitude: _picked.latitude,
              longitude: _picked.longitude,
              address: addressMsg,
            );

            if (!mounted) return;
            Navigator.pop(context, result);
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        appBar: AppBar(
          backgroundColor: AppColor.Dark,
          title: const Text("Pick location"),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initial,
                zoom: 16,
              ),
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

            if (_error != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 70,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withOpacity(0.4)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SafeArea(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.LightActive,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: _saving ? null : _confirm,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Confirm location",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
