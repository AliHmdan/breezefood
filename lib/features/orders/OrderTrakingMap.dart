import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// يجب استيراد حزمة Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart'; 

// *************************************************************
// 🎨 الألوان (حسب طلبك)
// *************************************************************


// *************************************************************
// 🏠 واجهة تتبع الطلب (Google Map Implementation)
// *************************************************************

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // 📍 إحداثيات وهمية (يجب استبدالها بالقيم الحقيقية)
  static const LatLng _restaurantLocation = LatLng(37.7749, -122.4194); // سان فرانسيسكو كمثال
  static const LatLng _courierLocation = LatLng(37.7849, -122.4094);
  static const LatLng _destinationLocation = LatLng(37.7949, -122.4294);
  
  // 🗺️ متغيرات الخريطة
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // 📷 كاميرا الخريطة تبدأ من موقع السائق
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: _courierLocation,
    zoom: 14.0, 
  );

  @override
  void initState() {
    super.initState();
    // تهيئة المؤشرات والمسارات عند بدء التشغيل
    _setupMapElements();
    
    // ⏳ يتم استدعاء الدالة بعد 5 ثوانٍ من بناء الواجهة لإظهار الـ Dialog
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _showTrackingSheet();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 📌 إعداد المؤشرات والمسارات
  void _setupMapElements() {
    // 1. مؤشر المطعم (نقطة البداية)
    _markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: _restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'Restaurant'),
      ),
    );

    // 2. مؤشر العميل (الوجهة)
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // 3. مؤشر السائق (الموقع الحالي)
    _markers.add(
      Marker(
        markerId: const MarkerId('courier'),
        position: _courierLocation,
        // يمكن استخدام أيقونة مخصصة للسائق
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Courier'),
      ),
    );

    // 🛣️ المسار (وهمي - مسار مستقيم بين السائق والوجهة)
    // في تطبيق حقيقي، يجب استدعاء خدمة Directions API لرسم المسار الفعلي.
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_courierLocation, _destinationLocation],
        color: AppColor.primaryColor, // لون المسار المكتمل
        width: 4,
      ),
    );

    setState(() {});
  }

  // 📝 دالة إظهار الـ Bottom Sheet
  void _showTrackingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => const TrackingSheet(),
    );
  }

  // 🗺️ بناء واجهة الخريطة
  Widget _buildGoogleMap() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),

        // ⬅️ زر العودة
        Positioned(
          top: 50.h,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColor.black), 
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // 👤 معلومات السائق الأساسية (في الأسفل كما في الصورة)
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/courier_avatar.jpg'), 
                  backgroundColor: AppColor.primaryColor,
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ibrahim Ahmad',
                      style: TextStyle(
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      'Courier',
                      style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
                    ),
                  ],
                ),
                const Spacer(),
                // أزرار التواصل (وهمية)
                _buildContactButton(Icons.call, () {}),
                SizedBox(width: 8.w),
                _buildContactButton(Icons.chat_bubble_outline, () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // زر الاتصال الصغير على الخريطة
  Widget _buildContactButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.primaryColor, size: 20.sp),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));

    return Scaffold(
      extendBodyBehindAppBar: true, // لجعل الخريطة خلف شريط التطبيق
      appBar: AppBar(
        title: const Text(
          'Tracking Order',
          style: TextStyle(color: AppColor.black),
        ),
        backgroundColor: Colors.transparent, // شفاف
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildGoogleMap(), // استخدام الخريطة
    );
  }
}

// *************************************************************
// 📝 الـ Bottom Sheet (يحتوي على التفاصيل بعد 5 ثوانٍ)
// *************************************************************

class TrackingSheet extends StatelessWidget {
  const TrackingSheet({super.key});

  // 📦 بناء أيقونات خطوات الطلب
  Widget _buildStepIcon(IconData icon, bool isCompleted) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: isCompleted ? AppColor.primaryColor : AppColor.LightActive,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColor.white,
        size: 16.sp,
      ),
    );
  }

  // 📝 بناء خطوة الطلب
  Widget _buildStep(String title, String time, bool isCompleted, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔳 أيقونة وخط الزمن
          Column(
            children: [
              _buildStepIcon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                isCompleted,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColor.primaryColor : AppColor.LightActive,
                  ),
                ),
            ],
          ),
          SizedBox(width: 15.w),

          // 💬 تفاصيل الخطوة
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted ? AppColor.white : AppColor.gry, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    time,
                    style: TextStyle(color: AppColor.gry, fontSize: 12.sp), 
                  ),
                  SizedBox(height: isLast ? 0 : 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColor.Dark, 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 معلومات السائق
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/courier_avatar.jpg'),
                  backgroundColor: AppColor.primaryColor,
                ),
                SizedBox(width: 15.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ibrahim Ahmad',
                      style: TextStyle(
                        color: AppColor.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      'Courier',
                      style: TextStyle(color: AppColor.gry, fontSize: 13.sp), 
                    ),
                  ],
                ),
                const Spacer(),
                // أزرار التواصل الكبيرة
                _buildContactButton(Icons.call, () {}),
                SizedBox(width: 10.w),
                _buildContactButton(Icons.chat_bubble_outline, () {}),
              ],
            ),
            
            SizedBox(height: 20.h),

            // 🔑 كود التحقق (Check Code)
            Text(
              'Show the code when the rider is coming to you',
              style: TextStyle(color: AppColor.gry, fontSize: 13.sp), 
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              decoration: BoxDecoration(
                color: AppColor.LightActive, 
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (index) => Text(
                    '${index + 1}', 
                    style: TextStyle(
                      color: AppColor.white, 
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // 📍 عنوان التسليم
            Text(
              'Delivering to',
              style: TextStyle(color: AppColor.gry, fontSize: 13.sp), 
            ),
            SizedBox(height: 5.h),
            Text(
              '3830 Roder Ave, Fontana, CA',
              style: TextStyle(color: AppColor.white, fontSize: 14.sp), 
            ),

            SizedBox(height: 20.h),

            // 📜 جدول حالة الطلب
            Column(
              children: [
                _buildStep(
                  'Order received',
                  '08:48 pm',
                  true,
                  false,
                ),
                _buildStep(
                  'Preparing your order',
                  '08:50 pm',
                  true,
                  false,
                ),
                _buildStep(
                  'The courier has picked up your order',
                  '08:55 pm',
                  true, 
                  false,
                ),
                _buildStep(
                  'Order delivered',
                  '', 
                  false,
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// أداة مساعدة لزر الاتصال داخل الـ Bottom Sheet
Widget _buildContactButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColor.white, size: 20),
    ),
  );
}