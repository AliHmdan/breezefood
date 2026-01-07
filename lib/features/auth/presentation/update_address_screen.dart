import 'dart:developer';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

class UpdateAddressScreen extends StatefulWidget {
  const UpdateAddressScreen({super.key});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  late final AuthFlowCubit cubit;

  String _status = 'Updating your location...';

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    log("UpdateAddressScreen started");

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _status = 'Location services are disabled');
        log('Location services disabled');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      log('Initial permission: $permission');

      if (permission == LocationPermission.denied) {
        log('Requesting permission...');
        permission = await Geolocator.requestPermission();
        log('After request: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        log('Permission permanently denied');
        setState(() => _status = 'Permission permanently denied');
        return;
      }

      if (permission == LocationPermission.denied) {
        log('User denied permission');
        setState(() => _status = 'Permission denied');
        return;
      }

      // 3) جلب الموقع الحالي
      setState(() => _status = 'Getting your location...');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('Current location: lat=${pos.latitude}, lng=${pos.longitude}');

      // 4) استدعاء API لإضافة العنوان (عن طريق cubit)
      setState(() => _status = 'Updating your address...');

      cubit.addAddress(
        address: "عنوان افتراضي", // لاحقاً بدله من UI
        lat: pos.latitude,
        lon: pos.longitude,
      );
    } catch (e, st) {
      log('Error in _start: $e\n$st');
      setState(() => _status = 'Failed to update address');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFlowCubit, AuthFlowState>(
      bloc: cubit,
      listener: (context, state) {
        state.whenOrNull(
          loading: () {
            // لو تحب خليها ثابتة بدون تغيير
            // setState(() => _status = 'Updating...');
          },
          error: (msg) {
            setState(() => _status = msg);
          },
          addressAdded: (data) {
            final msg = (data is Map)
                ? (data["message"] ?? "تمت إضافة العنوان")
                : null;

            setState(() => _status = (msg ?? "تمت إضافة العنوان").toString());
            _navigateToHome();
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 84.w,
                  color: AppColor.primaryColor,
                ),
                const SizedBox(height: 16),

                CircularProgressIndicator(color: AppColor.primaryColor),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
