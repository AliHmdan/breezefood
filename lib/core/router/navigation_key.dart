import 'package:flutter/material.dart';

class NavigationKey {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get context {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      throw Exception('❌ NavigationKey.context is null — تأكد من تمرير navigatorKey لـMaterialApp');
    }
    return ctx;
  }
}
