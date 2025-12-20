// presentation/widgets/home/animated_standalone.dart

import 'package:breezefood/view/HomePage/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// *************************************************************
// ⚠️ تعريفات وهمية (Mocked Dependencies)
// *************************************************************

// 1. Mock Data لتمثيل الإعلان
class AdModelMock {
  final String title;
  final String image; // يفترض أن هذا المسار مكتمل أو مسار Asset
  
  const AdModelMock({required this.title, required this.image});
}



// *************************************************************

class Animated extends StatefulWidget {
  // 🗑️ تم استبدال home_model.AdModel بـ Mock Data أو بقيمة ثابتة
  // 💡 لتبسيط الكود لـ UI، سنستخدم بيانات ثابتة داخل الـ State
  final AdModelMock? ad;

  const Animated({super.key, this.ad});

  @override
  State<Animated> createState() => _AnimatedState();
}

class _AnimatedState extends State<Animated> {
  // 📝 بيانات إعلان ثابتة (Mock Data)
  static const AdModelMock _mockAd = AdModelMock(
    title: 'خصم 50% على جميع الوجبات السريعة! 🍟',
    // 💡 استخدام مسار وهمي أو مسار Asset حقيقي موجود لديك
    image: 'assets/images/banner_mock.jpg', 
  );
  
  // 💡 لإظهار الـ Ad دائماً في وضع الـ UI الثابت، نستخدم الـ Mock Data
  // إذا أردت إظهار رسالة الترحيب، يمكنك وضع _mockAd = null
  final AdModelMock? _currentAd = _mockAd; 

  @override
  Widget build(BuildContext context) {
    final hasAd = _currentAd != null;
    Widget child = Center(
      child: Text(
        // حالة عدم وجود إعلان
        'مرحباً بك مجدداً 👋',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (hasAd) {
      final a = _currentAd!;
      // 🗑️ تم حذف منطق بناء المسار باستخدام AppLink واعتماد مسار ثابت/وهمي
      final src = a.image; 

      child = Stack(
        fit: StackFit.expand,
        children: [
          // 💡 نستخدم Image.asset بدلاً من Image.network لـ Mock Data
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Image.asset(
              src,
              fit: BoxFit.cover,
              // 💡 errorBuilder تم تعديله للتعامل مع Asset غير موجود
              errorBuilder: (c, e, s) => Container(
                color: Colors.blueGrey.shade900,
                child: Center(child: Text('صورة إعلان غير موجودة', style: TextStyle(color: Colors.white70, fontSize: 10.sp))),
              ),
            ),
          ),
          
          // إضافة طبقة ظل للتأكد من ظهور النص
          Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(15.r),
               gradient: LinearGradient(
                 begin: Alignment.bottomCenter,
                 end: Alignment.topCenter,
                 colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                 stops: const [0.0, 0.7],
               ),
             ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                a.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedBackground(
      height: 100.h,
      child: child,
      // 💡 تم الإبقاء على الـ Mock Characters
      characters: const [
        CartoonSvg(
          alignment: Alignment.topRight,
          width: 56,
          assetPath: 'assets/characters/star.svg',
          margin: EdgeInsets.only(top: 10, right: 10),
          floatAmplitude: 4,
          phaseShift: 1.2,
        ),
        CartoonSvg(
          alignment: Alignment.bottomLeft,
          width: 90,
          assetPath: 'assets/characters/astronaut.svg',
          margin: EdgeInsets.only(left: 12, bottom: 8),
          rotationDeg: -6,
          floatAmplitude: 6,
          phaseShift: 0.0,
        ),
        CartoonSvg(
          alignment: Alignment.bottomRight,
          width: 110,
          assetPath: 'assets/characters/planet.svg',
          margin: EdgeInsets.only(right: 14, bottom: 6),
          floatAmplitude: 8,
          phaseShift: 2.2,
        ),
      ],
    );
  }
}