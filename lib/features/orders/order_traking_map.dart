import 'dart:async';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/map_marker_icon.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_tracking_state.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';
import 'package:breezefood/features/orders/tracking_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver{
  GoogleMapController? _mapController;

  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _meIcon;

  LatLng? _driverLatLng;
  LatLng? _myLatLng;

  // Markers + polyline
  final Set<Marker> _markers = {};

  // My location stream
  StreamSubscription<Position>? _posSub;

  // UI states
  bool _movedCameraOnce = false;

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadIcons();
    _startMyLocation();
    _startTracking();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersDetailsCubit>().load(widget.orderId);
    });
  }
 void _startTracking() {
    context.read<OrdersTrackingCubit>().start(
      widget.orderId,
      interval: const Duration(seconds: 15),
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    context.read<OrdersTrackingCubit>().stop(); // ✅ لازم
    _posSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      context.read<OrdersTrackingCubit>().stop(); // ✅ وقف لما يطلع من الشاشة/يخفت التطبيق
    }

    if (state == AppLifecycleState.resumed) {
      context.read<OrdersTrackingCubit>().start(
        widget.orderId,
        interval: const Duration(seconds: 15),
      );
    }
  }

 

  Future<void> _loadIcons() async {
    try {
      const driverW = 64; // جرّب 64 إذا بدك أصغر
      const meW = 64;

      final driver = await MapMarkerIcon.fromAsset(
        "assets/b_driver/driver_map_point.png",
        width: driverW,
      );
      final me = await MapMarkerIcon.fromAsset(
        "assets/b_driver/customer_map_point.png",
        width: meW,
      );

      if (!mounted) return;
      setState(() {
        _driverIcon = driver;
        _meIcon = me;
      });

      // إعادة رسم إذا كانت المواقع وصلت قبل تحميل الأيقونات
      if (_myLatLng != null) _setMyMarker(_myLatLng!);
      if (_driverLatLng != null)
        _setDriverMarker(_driverLatLng!, moveCamera: false);
    } catch (_) {}
  }

  Future<void> _startMyLocation() async {
    try {
      final ok = await _ensureLocationPermission();
      if (!ok) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      _setMyMarker(LatLng(pos.latitude, pos.longitude));

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      );

      await _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
        (p) {
          if (!mounted) return;
          _setMyMarker(LatLng(p.latitude, p.longitude));
        },
      );
    } catch (_) {}
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) return false;
    if (perm == LocationPermission.deniedForever) return false;

    return true;
  }


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _setDriverMarker(LatLng p, {required bool moveCamera}) {
    _driverLatLng = p;

    _markers
      ..removeWhere((m) => m.markerId.value == 'driver')
      ..add(
        Marker(
          markerId: const MarkerId('driver'),
          position: p,
          icon:
              _driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: "tracking.driver".tr()),
        ),
      );
    setState(() {});
    if (moveCamera && !_movedCameraOnce) {
      _movedCameraOnce = true;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(p, 16));
    }
  }

  void _setMyMarker(LatLng p) {
    _myLatLng = p;

    _markers
      ..removeWhere((m) => m.markerId.value == 'me')
      ..add(
        Marker(
          markerId: const MarkerId('me'),
          position: p,
          icon:
              _meIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: "tracking.me".tr()),
        ),
      );

    setState(() {});
  }

  Future<void> _recenter() async {
    if (_mapController == null) return;

    final d = _driverLatLng;
    final me = _myLatLng;

    if (d != null && me != null) {
      final sw = LatLng(
        d.latitude < me.latitude ? d.latitude : me.latitude,
        d.longitude < me.longitude ? d.longitude : me.longitude,
      );
      final ne = LatLng(
        d.latitude > me.latitude ? d.latitude : me.latitude,
        d.longitude > me.longitude ? d.longitude : me.longitude,
      );

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: sw, northeast: ne),
          80,
        ),
      );
      return;
    }

    final target = d ?? me;
    if (target == null) return;

    await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocListener<OrdersTrackingCubit, OrdersTrackingState>(
        listener: (context, state) {
          state.whenOrNull(
            tracking: (tracking, driverLatLng, updatedAt) {
              if (tracking) _setDriverMarker(driverLatLng, moveCamera: true);
            },
          );
        },
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
            ),

            // زر رجوع مثل المثال
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              left: 12.w,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColor.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColor.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // عنوان مثل المثال
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              left: 70.w,
              right: 14.w,
              child: _TitleChip(
                text: "tracking.title".tr(
                  namedArgs: {"id": widget.orderId.toString()},
                ),
              ),
            ),

            // Status pill
            Positioned(
              top: MediaQuery.of(context).padding.top + 62.h,
              left: 16.w,
              right: 16.w,
              child: BlocBuilder<OrdersTrackingCubit, OrdersTrackingState>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.maybeWhen(
                      loading: () => _StatusPill(
                        key: const ValueKey("l"),
                        text: "tracking.loading".tr(),
                        bg: Colors.white,
                        fg: Colors.black,
                        icon: Icons.sync,
                      ),
                      error: (mKey) => _StatusPill(
                        key: const ValueKey("e"),
                        text: mKey.tr(),
                        bg: const Color(0xFFFFF1F1),
                        fg: const Color(0xFFB00020),
                        icon: Icons.error_outline,
                      ),
                      tracking: (tracking, _, __) => _StatusPill(
                        key: const ValueKey("t"),
                        text: tracking
                            ? "tracking.live".tr()
                            : "tracking.not_available".tr(),
                        bg: tracking
                            ? const Color(0xFFEFFFF3)
                            : const Color(0xFFFFF7E6),
                        fg: tracking
                            ? const Color(0xFF0A7A2F)
                            : const Color(0xFF8A5A00),
                        icon: tracking ? Icons.location_on : Icons.location_off,
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),

            // كارد السائق تحت — بدون call/chat
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: _DriverMiniCard(),
            ),

            // زر recenter
            Positioned(
              right: 16.w,
              bottom: 120.h,
              child: _RoundFab(icon: Icons.my_location, onTap: _recenter),
            ),
            // ✅ الشيت ثابت فوق الخريطة
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.30,
                  minChildSize: 0.16,
                  maxChildSize: 0.92,
                  snap: true,
                  snapSizes: const [0.16, 0.30, 0.60, 0.92],
                  builder: (context, scrollController) {
                    return TrackingSheet(
                      orderId: widget.orderId,
                      scrollController: scrollController,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= UI Pieces =======================

class _TitleChip extends StatelessWidget {
  final String text;
  const _TitleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DriverMiniCard extends StatelessWidget {
  const _DriverMiniCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/b_driver/driver_map_point.png'),
            backgroundColor: AppColor.primaryColor,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "tracking.driver".tr(),
                style: TextStyle(
                  color: AppColor.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                "tracking.live".tr(),
                style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;

  const _StatusPill({
    super.key,
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 46.w,
          height: 46.w,
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
