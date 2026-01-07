import 'package:breezefood/core/component/CustomBottomNav.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/home_screen.dart';
import 'package:breezefood/features/favoritePage/favorite_page.dart';
import 'package:breezefood/features/orders/orders.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/stores_nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  late final FavoritesCubit _favoritesCubit;

  final _pages = <Widget>[
    Home(),
    StoresNavTab(),
    FavoritePage(),
    BlocProvider(create: (context) => getIt<OrdersCubit>(), child: Orders()),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _favoritesCubit = getIt<FavoritesCubit>();

    if (_index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _favoritesCubit.load();
      });
    }
  }

  @override
  void dispose() {
    _favoritesCubit.close();
    super.dispose();
  }

  void _onTabChanged(int i) {
    setState(() => _index = i);

    if (i == 2) {
      _favoritesCubit.load(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favoritesCubit, 
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: BottomNavBreeze(
          currentIndex: _index,
          onChanged: _onTabChanged,
        ),
      ),
    );
  }
}
