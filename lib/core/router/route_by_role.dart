import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/auth/presentation/login_page.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:flutter/material.dart';

class RoleRouter {
  static Widget screenForRole(String? role) {
    switch (role) {
      case 'customer':
        return const MainShell();

      default:
        return const MainShell();
    }
  }

  static Future<void> goHome(BuildContext context) async {
    final hasToken = await AuthStorageHelper.hasToken();
    if (!hasToken) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
      return;
    }

    final role = await AuthStorageHelper.getUserRole();
    final screen = screenForRole(role);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
