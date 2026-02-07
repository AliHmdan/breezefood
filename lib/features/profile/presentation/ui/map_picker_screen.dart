import 'dart:async';
import 'dart:developer';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  /// ما عاد ضروري، بس خليته مشان التوافق
  final LatLng initial;
  const MapPickerScreen({super.key, required this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // ✅ fallback: Tartus, Syria
  static const LatLng _fallbackTartus = LatLng(34.8890, 35.8866);

  // ✅ placeholder أول ما تفتح قبل ما نعرف وين نروح
  static const LatLng _placeholder = LatLng(0, 0);

  // ✅ فعل/اطفي “إجبار داخل سوريا”
  static const bool _forceInsideSyria = true;

  // ✅ فحص سريع (Bounding Box) لسوريا
  bool _isInsideSyria(LatLng p) {
    return p.latitude >= 32.0 &&
        p.latitude <= 37.5 &&
        p.longitude >= 35.5 &&
        p.longitude <= 42.5;
  }

  // ✅ لو برا سوريا -> رجّع طرطوس
  LatLng _normalizeToSyria(LatLng p) {
    if (!_forceInsideSyria) return p;
    if (_isInsideSyria(p)) return p;
    return _fallbackTartus;
  }

  GoogleMapController? _ctrl;
  late LatLng _picked;

  late final AuthFlowCubit cubit;

  bool _saving = false;
  bool _locating = true;
  bool _resolvingAddress = false;

  String? _error;

  String _address = "";
  Timer? _debounce;

  bool _mapReady = false;
  bool _didInitialMove = false;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();

    // ✅ لا تعتمد على widget.initial كبداية حقيقية
    _picked = _placeholder;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ================= Location =================

  Future<Position> _getCurrentPosition() async {
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
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<void> _moveTo(LatLng target, {double zoom = 16}) async {
    // ✅ طبّق التطبيع لسوريا
    final fixed = _normalizeToSyria(target);

    _picked = fixed;

    if (mounted) {
      setState(() {});
    }

    await _ctrl?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: fixed, zoom: zoom)),
    );

    _scheduleResolveAddress(fixed);
  }

  Future<void> _initFromCurrentLocationOrFallback({
    bool showError = false,
  }) async {
    setState(() {
      _locating = true;
      _error = null;
      _address = "";
    });

    try {
      final pos = await _getCurrentPosition();
      if (!mounted) return;

      // ✅ موقع الجهاز
      final currentRaw = LatLng(pos.latitude, pos.longitude);

      // ✅ إذا برا سوريا → طرطوس
      final current = _normalizeToSyria(currentRaw);

      setState(() {
        _locating = false;
      });

      await _moveTo(current, zoom: _isInsideSyria(current) ? 16 : 13);
    } catch (e, st) {
      log("location init error: $e\n$st");
      if (!mounted) return;

      setState(() {
        _locating = false;
        _error = showError ? "map_picker.error_cannot_locate".tr() : null;
      });

      // ✅ fallback to Tartus automatically
      await _moveTo(_fallbackTartus, zoom: 13);
    }
  }

  // ================= Address resolve =================

  void _scheduleResolveAddress(LatLng p) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      await _resolveAndSetAddress(p.latitude, p.longitude);
    });
  }

  Future<void> _resolveAndSetAddress(double lat, double lon) async {
    if (!mounted) return;

    setState(() {
      _resolvingAddress = true;
    });

    final addr = await _resolveAddress(lat, lon);

    if (!mounted) return;
    setState(() {
      _address = addr;
      _resolvingAddress = false;
    });
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

  // ================= Confirm =================

  Future<void> _confirm() async {
    if (_saving || _locating) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final lat = _picked.latitude;
    final lon = _picked.longitude;

    try {
      final addressText = _address.trim().isNotEmpty
          ? _address
          : await _resolveAddress(lat, lon);

      cubit.addAddress(address: addressText, lat: lat, lon: lon);
    } catch (e, st) {
      log("confirm error: $e\n$st");
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "map_picker.error_failed_update".tr();
      });
    }
  }

  void _showErrorSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFlowCubit, AuthFlowState>(
      bloc: cubit,
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) {
            setState(() => _saving = false);
            _showErrorSnack(msg);
          },
          addressAdded: (data) async {
            final addressText = _address.trim().isNotEmpty
                ? _address
                : await _resolveAddress(_picked.latitude, _picked.longitude);

            final result = MapPickerResult(
              latitude: _picked.latitude,
              longitude: _picked.longitude,
              address: addressText,
            );

            if (!mounted) return;
            Navigator.pop(context, result);
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "map_picker.title".tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          actions: [SizedBox(width: 8.w)],
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _placeholder,
                zoom: 2,
              ),

              onMapCreated: (c) async {
                _ctrl = c;
                _mapReady = true;

                if (_didInitialMove) return;
                _didInitialMove = true;

                await _initFromCurrentLocationOrFallback(showError: false);
              },

              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,

              onTap: (pos) async {
                if (_locating) return;

                final fixed = _normalizeToSyria(pos);

                setState(() {
                  _picked = fixed;
                  _address = "";
                });

                await _ctrl?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: fixed, zoom: 16),
                  ),
                );

                _scheduleResolveAddress(fixed);
              },

              onCameraMove: (pos) {
                // ✅ pin ثابت بالنص -> نحدّث الإحداثيات (مع تطبيع سوريا)
                _picked = _normalizeToSyria(pos.target);
              },

              onCameraIdle: () {
                _scheduleResolveAddress(_picked);
                if (mounted) setState(() {});
              },
            ),

            // ✅ pin ثابت بالنص
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, -18.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.place, size: 46.sp, color: Colors.redAccent),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ زر "موقعي" (وإذا فشل أو برا سوريا يرجعك طرطوس)
            Positioned(
              right: 14.w,
              bottom: 170.h,
              child: SafeArea(
                child: InkWell(
                  onTap: () =>
                      _initFromCurrentLocationOrFallback(showError: true),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ),
            ),

            // ✅ Bottom sheet info + confirm
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                  decoration: BoxDecoration(
                    color: AppColor.Dark.withOpacity(0.92),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "map_picker.selected_location".tr(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _resolvingAddress
                                      ? Row(
                                          key: const ValueKey("loadingAddr"),
                                          children: [
                                            SizedBox(
                                              width: 14.w,
                                              height: 14.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "map_picker.resolving".tr(),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          (_address.trim().isNotEmpty)
                                              ? _address
                                              : "${_picked.latitude.toStringAsFixed(5)}, ${_picked.longitude.toStringAsFixed(5)}",
                                          key: const ValueKey("addr"),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.75,
                                            ),
                                            fontSize: 12.sp,
                                            height: 1.35,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (_error != null) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 12.h),

                      SizedBox(
                        height: 50.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.LightActive,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: (_saving || _locating || !_mapReady)
                              ? null
                              : _confirm,
                          child: (_saving || _locating)
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "map_picker.confirm".tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_locating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.28),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColor.Dark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "map_picker.locating".tr(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
