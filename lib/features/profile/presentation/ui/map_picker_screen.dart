import 'dart:developer';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';

// لو عندك MapPickerResult بمكان ثاني احذف هذا
class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  MapPickerResult({
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
  bool _locating = true; // ✅ جديد: عم نجيب موقعي
  String? _error;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();

    // ✅ مبدئياً خليها initial (fallback) لحد ما نجيب الموقع الحالي
    _picked = widget.initial;

    // ✅ ابدأ من موقعي الحالي
    _initFromCurrentLocation();
  }

  Future<void> _initFromCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      final pos = await _getCurrentPosition();

      if (!mounted) return;

      final current = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _picked = current;
        _locating = false;
      });

      // لو الخريطة اتنشأت حرّك الكاميرا
      await _ctrl?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: current, zoom: 16),
        ),
      );
    } catch (e, st) {
      log("location init error: $e\n$st");
      if (!mounted) return;

      // ✅ إذا فشلنا، نكمل على initial بدون ما نوقف الشاشة
      setState(() {
        _locating = false;
        _error = "تعذر تحديد موقعك الحالي، اختره يدويًا من الخريطة";
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    // 1) هل خدمة الموقع شغالة؟
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    // 2) صلاحيات
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

    // 3) جيب الموقع الحالي
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
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
          error: (msg) {
            setState(() {
              _saving = false;
              _error = msg;
            });
          },
          addressAdded: (data) async {
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
          actions: [
            IconButton(
              tooltip: "My location",
              onPressed: _initFromCurrentLocation, // ✅ زر يرجعك لموقعك
              icon: const Icon(Icons.my_location),
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                // ✅ لاحظ: حتى لو هون initial، احنا بعدين بنعمل animate للموقع الحالي
                target: _picked,
                zoom: 16,
              ),
              onMapCreated: (c) async {
                _ctrl = c;

                // ✅ لو كنا لسه محددين موقع حالي قبل إنشاء الخريطة
                if (!_locating) {
                  await _ctrl?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _picked, zoom: 16),
                    ),
                  );
                }
              },
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

            // ✅ Loading overlay لما نجيب الموقع الحالي
            if (_locating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
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
                    onPressed: (_saving || _locating) ? null : _confirm,
                    child: (_saving || _locating)
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
