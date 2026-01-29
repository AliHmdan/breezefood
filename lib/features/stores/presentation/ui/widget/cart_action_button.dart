import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/current_orders.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';

class CartActionButton extends StatelessWidget {
  final VoidCallback onViewCart;
  final OrderInfo? haveOrder;

  const CartActionButton({
    super.key,
    required this.onViewCart,
    required this.haveOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        bool loading = false;
        CartSummary summary = CartSummary.empty;

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, _, __) {
            summary = CartSummary.from(cart);
          },
          orElse: () {},
        );

        // لو عم يحمل، فيك تخليها زر Disabled أو تخفيها
        if (loading) {
          return CustomButtonOrder(
            title: "cart.view_cart_loading".tr(),
            onPressed: null,
          );
        }

        if (summary.hasCart) {
          return CustomButtonOrder(
            title: "cart.view_cart".tr(),
            onPressed: onViewCart,
          );
        }

        if (haveOrder != null) {
          return CustomButtonOrder(
            title: "home.your_order".tr(),
            onPressed: () => openHaveOrderTracking(context, haveOrder!.id),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class SupermarketBottomButton extends StatelessWidget {
  const SupermarketBottomButton({super.key, this.onAfterBack});

  final VoidCallback? onAfterBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        bool loading = false;
        CartSummary summary = CartSummary.empty;

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, _, __) {
            summary = CartSummary.from(cart);
          },
          orElse: () {},
        );

        if (summary.hasCart) {
          return CustomButton(
            title: loading
                ? "cart.view_cart_loading".tr()
                : "${'cart.view_cart'.tr()} • ${summary.count} • ${context.money(summary.total, decimals: 0)}",
            onPressed: loading
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<CartCubit>()),
                            BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
                          ],
                          child: const RequestOrderScreen(),
                        ),
                      ),
                    );

                    if (context.mounted) {
                      context.read<CartCubit>().loadCart();
                      onAfterBack?.call();
                    }
                  },
          );
        }

        // ✅ سلة فاضية -> Your Order (مثل المطاعم)
        return CustomButtonOrder(
          title: "home.your_order".tr(),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<OrdersCubit>()..loadActive(),
                  child: const CurrentOrders(),
                ),
              ),
            );

            if (context.mounted) {
              context.read<CartCubit>().loadCart();
              onAfterBack?.call();
            }
          },
        );
      },
    );
  }
}
