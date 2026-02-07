import 'dart:developer';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum _LocationGate {
  none,
  serviceOff,
  deniedForever,
  denied,
}

class UpdateAddressScreen extends StatefulWidget {
  const UpdateAddressScreen({super.key});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen>
    with WidgetsBindingObserver {
  late final AuthFlowCubit cubit;

  String _status = 'auth.updating_location'.tr();
  _LocationGate _gate = _LocationGate.none;
  bool _isBusy = true;

  // ✅ لما نفتح Settings نعمل retry تلقائي عند الرجوع
  bool _retryOnResume = false;

  // ✅ ثروتل بسيط لمنع تكرار start مرتين بسرعة
  DateTime? _lastAutoRetryAt;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Retry تلقائي بعد الرجوع من الإعدادات
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    if (!_retryOnResume) return;
    if (_isBusy) return;

    final now = DateTime.now();
    if (_lastAutoRetryAt != null &&
        now.difference(_lastAutoRetryAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastAutoRetryAt = now;

    _retryOnResume = false;
    _start();
  }

  Future<void> _start() async {
    if (!mounted) return;

    setState(() {
      _isBusy = true;
      _gate = _LocationGate.none;
      _status = 'auth.updating_location'.tr();
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isBusy = false;
          _gate = _LocationGate.serviceOff;
          _status = 'auth.location_services_disabled'.tr();
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isBusy = false;
          _gate = _LocationGate.deniedForever;
          _status = 'auth.permission_denied_forever'.tr();
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isBusy = false;
          _gate = _LocationGate.denied;
          _status = 'auth.permission_denied'.tr();
        });
        return;
      }

      setState(() => _status = 'auth.getting_location'.tr());
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _status = 'auth.resolving_address'.tr());

      String addressText = "common.unknown_address".tr();
      try {
        final placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if ((p.street ?? '').trim().isNotEmpty) p.street!,
            if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!,
            if ((p.locality ?? '').trim().isNotEmpty) p.locality!,
            if ((p.administrativeArea ?? '').trim().isNotEmpty)
              p.administrativeArea!,
            if ((p.country ?? '').trim().isNotEmpty) p.country!,
          ];
          addressText = parts.join(', ');
        }
      } catch (_) {
        addressText = "${pos.latitude}, ${pos.longitude}";
      }

      setState(() => _status = 'auth.updating_address'.tr());
      cubit.addAddress(
        address: addressText,
        lat: pos.latitude,
        lon: pos.longitude,
      );
    } catch (e, st) {
      log('Error in _start: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _gate = _LocationGate.none;
        _status = 'auth.failed_update_address'.tr();
      });
    }
  }

  Future<void> _openFix() async {
    // ✅ لما يرجع من settings بدنا retry تلقائي
    _retryOnResume = true;

    if (_gate == _LocationGate.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
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
            // انت أصلاً عم تبيّن loading من _start
          },
          error: (msg) {
            if (!mounted) return;
            setState(() {
              _isBusy = false;
              _status = msg.tr();
            });
          },
          addressAdded: (data) {
            if (!mounted) return;

            final msg = (data is Map)
                ? (data["message"] ?? "auth.address_added".tr())
                : null;

            setState(() {
              _isBusy = false;
              _status = (msg ?? "auth.address_added".tr()).toString();
            });

            _navigateToHome();
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 84.w,
                    color: AppColor.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  if (_isBusy) ...[
                    CircularProgressIndicator(color: AppColor.primaryColor),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),

                  if (!_isBusy && _gate != _LocationGate.none) ...[
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openFix,
                        icon: const Icon(Icons.settings),
                        label: Text(
                          _gate == _LocationGate.serviceOff
                              ? "auth.open_location_settings".tr()
                              : "auth.open_app_settings".tr(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _start,
                        icon: const Icon(Icons.refresh),
                        label: Text("common.retry".tr()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
