import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/loading.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:breezefood/core/services/app_notification_service.dart';
import 'package:breezefood/core/services/launch_screen.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  configEasyLoading();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await setupDi();
  await AppNotificationService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    configEasyLoading();

    return MultiBlocProvider(
      providers: [BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>())],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            navigatorKey: NavigationKey.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'breeze food UI',
            home: child ?? const LaunchScreen(),

            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,

            theme: ThemeData(
              scaffoldBackgroundColor: AppColor.Dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColor.primaryColor,
                brightness: Brightness.dark,
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: AppColor.primaryColor,
                circularTrackColor: AppColor.backfilter,
              ),
            ),
            builder: (context, widget) {
              final wrapped = MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget ?? const SizedBox.shrink(),
              );
              return EasyLoading.init()(context, wrapped);
            },
          );
        },
        child: const LaunchScreen(),
      ),
    );
  }
}
