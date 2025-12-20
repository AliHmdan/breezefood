// presentation/screens/update_address_screen.dart

import 'dart:developer';
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/MainShell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// تم إرجاع جميع الـ Imports الأصلية
import 'package:geolocator/geolocator.dart'; 

// 2. تعريف وهمي للـ Repository
class AddressRepository {
  Future<String> updateAddress({required double latitude, required double longitude}) async {
    // هذا يحاكي استجابة السيرفر
    await Future.delayed(const Duration(seconds: 1));
    return 'تم تحديث الموقع بنجاح: ($latitude, $longitude)';
  }
}


// *************************************************************

class UpdateAddressScreen extends StatefulWidget {
  const UpdateAddressScreen({super.key});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  // 💾 كود الـ Back-end لجلب الموقع
  final AddressRepository _repo = AddressRepository();
  String _status = 'Updating your location...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  // ⚙️ دالة الـ Geolocator الأصلية
  Future<void> _start() async {
    log("UpdateAddressScreen started"); // استخدام log بدلاً من print للحفاظ على الأصل

    try {
      // تحقق من تشغيل خدمة الموقع
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _status = 'Location services are disabled');
        log('Location services disabled');
        return;
      }

      // تحقق من الإذن
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

      // إذا وصلنا هنا فالإذن متاح
      setState(() => _status = 'Getting your location...');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('Current location: lat=${pos.latitude}, lng=${pos.longitude}');

      setState(() => _status = 'Updating your address...');
      final msg = await _repo.updateAddress(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      log('Server response: $msg');
      setState(() => _status = msg);
    } catch (e, st) {
      log('Error in _start: $e\n$st');
      setState(() => _status = 'Failed to update address');
    }

    await Future.delayed(const Duration(seconds: 2));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 كود الـ UI
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🗺️ أيقونة الموقع
              Icon(
                Icons.location_on, 
                size: 84.w, 
                color: AppColor.primaryColor,
              ),
              const SizedBox(height: 16),
              
              // 🔄 مؤشر التقدم
              CircularProgressIndicator(color: AppColor.primaryColor),
              const SizedBox(height: 12),
              
              // 📝 نص الحالة
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
    );
  }
}