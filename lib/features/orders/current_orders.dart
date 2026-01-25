import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/order_traking_map.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'; // OrderBundle
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_tracking_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrentOrders extends StatefulWidget {
  const CurrentOrders({super.key});

  @override
  State<CurrentOrders> createState() => _CurrentOrdersState();
}

class _CurrentOrdersState extends State<CurrentOrders> {
  Future<void> _refresh() async {
    await context.read<OrdersCubit>().loadActive();
  }

  String _fullUrl(String path) {
    final p = (path).trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;

    final fixed = p.startsWith("/") ? p.substring(1) : p;
    return "https://breezefood.cloud/$fixed"
        .replaceAll("//", "/")
        .replaceFirst("https:/", "https://");
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("pending")) return Colors.orange;
    if (s.contains("preparing")) return Colors.cyan;
    if (s.contains("delivered") || s.contains("completed")) return Colors.green;
    if (s.contains("cancel")) return AppColor.red;
    return Colors.white70;
  }

  Future<void> _showCustomerCodeDialog(int orderId) async {
    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final code = await context.read<OrdersCubit>().fetchOrderCustomerCode(
      orderId,
    );

    if (mounted) Navigator.of(context).pop(); // close loading
    if (!mounted) return;

    if (code == null || code == 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("orders.warning_title".tr()),
          content: Text("orders.customer_code_fetch_failed".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("common.close".tr()),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("orders.customer_code_title".tr()),
        content: SelectableText(
          code.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code.toString()));
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("orders.customer_code_copied".tr())),
              );
            },
            child: Text("common.copy".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("common.close".tr()),
          ),
        ],
      ),
    );
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
              onPressed: (_) => _showCustomerCodeDialog(item.id),
              backgroundColor: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(15.r),
              child: Center(
                child: Icon(Icons.qr_code_2, color: Colors.white, size: 28.sp),
              ),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        OrdersTrackingCubit(getIt<OrdersRepository>())
                          ..start(item.id),
                    child: OrderTrackingScreen(orderId: item.id),
                  ),
                ),
              );
            },

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
                                text: "orders.price_label".tr(), // "Price : "
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontFamily: "Manrope",
                                  fontSize: 12.sp,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${item.totalPrice.toStringAsFixed(0)} ${"common.currency".tr()}",
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
                        const SizedBox(height: 4),
                        CustomSubTitle(
                          subtitle: "orders.items_count".tr(
                            namedArgs: {"count": item.itemsCount.toString()},
                          ), // "Items: {count}"
                          color: Colors.white70,
                          fontsize: 11.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          activeLoaded: (o) => o,
          orElse: () => cubit.activeCache,
        );

        final isLoading = state.maybeWhen(
          loadingActive: () => true,
          orElse: () => false,
        );

        final errorMsg = state.maybeWhen(
          errorActive: (m) => m,
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
          return Center(
            child: Text(
              "orders.no_current_orders".tr(),
              style: const TextStyle(color: Colors.white70),
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
