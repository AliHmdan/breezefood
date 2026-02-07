import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/profile/presentation/ui/map_picker_screen.dart';
import 'package:breezefood/features/profile/presentation/ui/profile.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum _LocFail { serviceOff, denied, deniedForever, error }

class _LocResult {
  final LatLng? pos;
  final _LocFail? fail;
  const _LocResult.success(this.pos) : fail = null;
  const _LocResult.fail(this.fail) : pos = null;
}

class AppbarHome extends StatefulWidget {
  final HomeResponse? home;
  final HomeCubit homeCubit;

  const AppbarHome({super.key, this.home, required this.homeCubit});

  @override
  State<AppbarHome> createState() => _AppbarHomeState();
}

class _AppbarHomeState extends State<AppbarHome> {
  String? _cachedTitle;

  @override
  void initState() {
    super.initState();
    _loadCached();
  }

  Future<void> _loadCached() async {
    final loc = await AuthStorageHelper.getUserLocation();
    if (!mounted) return;
    if (loc == null) return;
    setState(() => _cachedTitle = (loc["text"] ?? "").toString());
  }

  Future<void> _savePickedLocation({
    required String text,
    required double lat,
    required double lon,
  }) async {
    await AuthStorageHelper.overrideHomeLocation(
      text: text,
      lat: lat,
      lon: lon,
    );

    if (!mounted) return;
    setState(() => _cachedTitle = text);
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = widget.home?.hasCoordinates ?? false;
    final province = widget.home?.provinceDetected;

    final title = (_cachedTitle?.trim().isNotEmpty == true)
        ? _cachedTitle!
        : (hasCoords
              ? (province?.isNotEmpty == true
                    ? province!
                    : "home.current_location".tr())
              : "home.select_location".tr());

    final subtitle = hasCoords ? "" : "home.location_hint".tr();

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          CustomAppbarHome(
            subtitle: subtitle,
            image: "assets/icons/location.svg",
            icon: Icons.keyboard_arrow_down,
            avatarUrl: widget.home?.avatar,
            onLocationTap: () => _openLocationSheet(context),
            onProfileTap: () async {
              final changed = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Profile()),
              );

              if (changed == true && context.mounted) {
                context.read<ProfileCubit>().load();
              }
            },
          ),
          const SizedBox(height: 15),
          CustomSearch(
            hint: "common.search".tr(),
            readOnly: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Search()),
            ),
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
          await widget.homeCubit.updateUserLocation(
            address: res.address,
            lat: res.latitude,
            lon: res.longitude,
          );
          await _savePickedLocation(
            text: res.address,
            lat: res.latitude,
            lon: res.longitude,
          );
          await widget.homeCubit.load();
        }
        break;

      case _HomeLocationAction.useMyLocation:
        final res = await _getMyLocation();
        if (!context.mounted) return;

        if (res.pos != null) {
          final txt = "home.my_location".tr();
          await widget.homeCubit.updateUserLocation(
            address: txt,
            lat: res.pos!.latitude,
            lon: res.pos!.longitude,
          );
          await _savePickedLocation(
            text: txt,
            lat: res.pos!.latitude,
            lon: res.pos!.longitude,
          );
          await widget.homeCubit.load();
          return;
        }

        // failures dialog (مثل عندك سابقاً)
        // تقدر تتركها مثل ما هي عندك
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

  Future<_LocResult> _getMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return const _LocResult.fail(_LocFail.serviceOff);

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever) {
        return const _LocResult.fail(_LocFail.deniedForever);
      }
      if (perm == LocationPermission.denied) {
        return const _LocResult.fail(_LocFail.denied);
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _LocResult.success(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      return const _LocResult.fail(_LocFail.error);
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
                    CustomSubTitle(subtitle: title, color: AppColor.white, fontsize: 12.sp),
                    // Text(
                    //   title,
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 13.sp,
                    //     fontWeight: FontWeight.w800,
                    //   ),
                    // ),
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
            "home.location_picker_title".tr(),
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
            title: "home.pick_on_map.title".tr(),
            subtitle: "home.pick_on_map.subtitle".tr(),
            action: _HomeLocationAction.pickOnMap,
          ),
          tile(
            icon: Icons.my_location,
            title: "home.use_my_location.title".tr(),
            subtitle: "home.use_my_location.subtitle".tr(),
            action: _HomeLocationAction.useMyLocation,
          ),
        ],
      ),
    );
  }
}
