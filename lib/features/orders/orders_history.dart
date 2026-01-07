import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'; // OrderBundle
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrdersHistory extends StatefulWidget {
  const OrdersHistory({super.key});

  @override
  State<OrdersHistory> createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  Future<void> _refresh() async {
    await context.read<OrdersCubit>().loadHistory();
  }

  String _fullUrl(String path) {
    final p = (path).trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;

    // السيرفر يرجّع أحياناً بدون "/" أو مع "//"
    final fixed = p.startsWith("/") ? p.substring(1) : p;
    return "https://breezefood.cloud/$fixed"
        .replaceAll("//", "/")
        .replaceFirst("https:/", "https://");
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("delivered") || s.contains("completed")) return Colors.green;
    if (s.contains("cancel")) return AppColor.red;
    if (s.contains("pending")) return Colors.orange;
    return Colors.white70;
  }

  Widget _buildOrderCard(OrderBundle bundle) {
    final item = bundle.order;
    final restaurant = bundle.restaurant;

    final statusColor = _statusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => _refresh(),
              backgroundColor: AppColor.black,
              borderRadius: BorderRadius.circular(15.r),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/refresh.svg",
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 10, top: 4),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      _fullUrl(restaurant.logo),
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/003.jpg",
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSubTitle(
                        subtitle: restaurant.name,
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: item.status,
                        color: statusColor,
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Price : ",
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: "Manrope",
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: "${item.totalPrice.toStringAsFixed(0)} ل.س",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final orders = state.maybeWhen(
          historyLoaded: (o) => o,
          orElse: () => cubit.historyCache,
        );

        final isLoading = state.maybeWhen(
          loadingHistory: () => true,
          orElse: () => false,
        );

        final errorMsg = state.maybeWhen(
          errorHistory: (m) => m,
          orElse: () => null,
        );

        if (isLoading && orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMsg != null && orders.isEmpty) {
          return Center(
            child: Text(errorMsg, style: const TextStyle(color: Colors.red)),
          );
        }

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "لا توجد طلبات سابقة",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final order in orders) _buildOrderCard(order),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
