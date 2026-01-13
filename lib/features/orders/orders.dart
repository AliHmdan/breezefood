import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/current_orders.dart';
import 'package:breezefood/features/orders/orders_history.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ تحميل من API
      context.read<OrdersCubit>().loadActive();
      context.read<OrdersCubit>().loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppbarHome(title: "Orders"),
              SizedBox(height: 20.h),

              // 🔥 Animated TabBar Buttons
              Row(
                children: List.generate(2, (index) {
                  final isSelected = _tabController.index == index;
                  final titles = ["Current orders", "Orders history"];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() {});
                      },
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSubTitle(
                              subtitle: titles[index],
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : AppColor.white,
                              fontsize: 14.sp,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(top: 4.h),
                              height: 3,
                              width: isSelected ? 130.w : 0,
                              constraints: const BoxConstraints(
                                minWidth: 0,
                                maxWidth: double.infinity,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 10.h),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    CurrentOrders(),
                    OrdersHistory(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
