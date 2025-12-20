import 'package:breezefood/auth/SplachVideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
    // 🔥 إخفاء شريط الحالة
SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,      // ← شفاف
      statusBarIconBrightness: Brightness.light, // ← لو خلفيتك داكنة اجعل الأيقونات فاتحة
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'breeze food UI',
          debugShowCheckedModeBanner: false,

          // ⭐ هنا نضيف الـ MediaQuery ⭐
          builder: (ctx, widget) {
            final media = MediaQuery.of(ctx);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: 1.1), // ← التعديل المطلوب
              child: widget!,
            );
          },

          home: child,
        );
      },
      child: const SplashVideoScreen(),
    );
  }
}
