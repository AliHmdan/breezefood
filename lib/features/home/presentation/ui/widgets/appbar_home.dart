import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/profile/presentation/ui/map_picker_screen.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppbarHome extends StatelessWidget {
  final HomeResponse? home;
  final HomeCubit homeCubit; // ✅

  const AppbarHome({super.key, this.home, required this.homeCubit});

  @override
  Widget build(BuildContext context) {
    final hasCoords = home?.hasCoordinates ?? false;
    final province = home?.provinceDetected;

    final title = hasCoords
        ? (province?.isNotEmpty == true ? province! : "موقعك الحالي")
        : "حدد موقعك";

    final subtitle = hasCoords ? "" : "لإظهار الأقرب إليك (مطاعم/سوبر ماركت)";

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openLocationSheet(context),
            child: AbsorbPointer(
              child: CustomAppbarHome(
                title: title,
                subtitle: subtitle,
                image: "assets/icons/location.svg",
                onTap: () {},
                icon: Icons.keyboard_arrow_down,
              ),
            ),
          ),
          const SizedBox(height: 15),
          CustomSearch(
            hint: 'Search',
            readOnly: true,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => Search()));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openLocationSheet(BuildContext context) async {
    final action = await showModalBottomSheet<_HomeLocationAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HomeLocationPickerSheet(),
    );

    if (action == null) return;

    switch (action) {
      case _HomeLocationAction.pickOnMap:
        final initial = await _getInitialLatLng();
        if (!context.mounted) return;

        final res = await Navigator.push<MapPickerResult>(
          context,
          MaterialPageRoute(builder: (_) => MapPickerScreen(initial: initial)),
        );
        if (res != null) {
          await homeCubit.load();
        }
        break;

      case _HomeLocationAction.useMyLocation:
        final pos = await _getMyLocation();
        if (pos != null) {
          await homeCubit.updateUserLocation(
            address: "موقعي الحالي",
            lat: pos.latitude,
            lon: pos.longitude,
          );
        }
        break;
    }
  }

  Future<LatLng> _getInitialLatLng() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return const LatLng(33.5138, 36.2765);

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return const LatLng(33.5138, 36.2765);
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return const LatLng(33.5138, 36.2765);
    }
  }

  Future<LatLng?> _getMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}

enum _HomeLocationAction { pickOnMap, useMyLocation }

class _HomeLocationPickerSheet extends StatelessWidget {
  const _HomeLocationPickerSheet();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    Widget tile({
      required IconData icon,
      required String title,
      required String subtitle,
      required _HomeLocationAction action,
    }) {
      return InkWell(
        onTap: () => Navigator.pop(context, action),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColor.Dark,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_right, color: Colors.white54),
            ],
          ),
        ),
      );
    }

    return Container(
      height: h * 0.46,
      decoration: BoxDecoration(
        color: AppColor.Dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            "اختيار الموقع",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(color: Colors.white24),

          tile(
            icon: Icons.map_outlined,
            title: "اختيار على الخريطة",
            subtitle: "حدد موقع جديد وتحديث العنوان",
            action: _HomeLocationAction.pickOnMap,
          ),
          tile(
            icon: Icons.my_location,
            title: "استخدام موقعي الحالي",
            subtitle: "التحديث تلقائياً من GPS",
            action: _HomeLocationAction.useMyLocation,
          ),
        ],
      ),
    );
  }
}
