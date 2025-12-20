// presentation/widgets/main_shell.dart

import 'package:breezefood/CustomBottomNav.dart';
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/HomePage.dart';
import 'package:breezefood/view/favoritePage/favorite_page.dart';
import 'package:breezefood/view/orders/orders.dart';
import 'package:breezefood/view/stores/stores_nav_tab.dart';
import 'package:flutter/material.dart';

// ⬅️ استدعاء التصميم الجديد


class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  final _pages = <Widget>[
    Home(),
    StoresNavTab(),
    FavoritePage(),
    Orders(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),

      // 🔥 استدعاء الـ BottomNavBreeze الجديد هنا
      bottomNavigationBar: BottomNavBreeze(
        currentIndex: _index,
        onChanged: (i) {
          setState(() => _index = i);
        },
      ),
    );
  }
}
