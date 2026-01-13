import 'dart:async';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:flutter/material.dart';

class AppNavigate {
  static to(
    BuildContext context,
    Widget widget, {
    bool checkConnectivity = true,
  }) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }

  static Future toRemove(
    BuildContext context,
    Widget widget, {
    bool checkConnectivity = true,
  }) async {
    return await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }

  static back(BuildContext context, {data}) {
    return Navigator.of(context).pop(data);
  }

  static Future removeUntilTo(
    BuildContext context,
    Widget widget, {
    bool checkConnectivity = true,
  }) async {
    return await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
      (route) => false,
    );
  }
}

Future to(Widget widget, {bool checkConnectivity = true}) async {
  return await Navigator.of(NavigationKey.context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    ),
  );
}

Future toRemove(Widget widget, {bool checkConnectivity = true}) async {
  return await Navigator.of(NavigationKey.context).pushReplacement(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    ),
  );
}

back({data}) {
  return Navigator.of(NavigationKey.context).pop(data);
}

Future removeUntilTo(
  BuildContext context,
  Widget widget, {
  bool checkConnectivity = true,
}) async {
  return await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    ),
    (route) => false,
  );
}
