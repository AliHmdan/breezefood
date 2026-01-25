import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';

import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/request_order.dart';
import 'package:breezefood/features/orders/current_orders.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class CartActionButton extends StatefulWidget {
  final VoidCallback onViewCart; // لما السلة فيها عناصر
  final VoidCallback onEmptyCart; // لما السلة فاضية

  /// مفاتيح الترجمة (غيرها حسب مفاتيحك)
  final String viewCartTitleKey;
  final String emptyTitleKey;

  const CartActionButton({
    super.key,
    required this.onViewCart,
    required this.onEmptyCart,
    this.viewCartTitleKey = "home.view_cart",
    this.emptyTitleKey = "home.your_order",
  });

  @override
  State<CartActionButton> createState() => _CartActionButtonState();
}

class _CartActionButtonState extends State<CartActionButton> {
  int _lastCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listenWhen: (p, c) => c.maybeWhen(
        cartLoaded: (_, __, ___) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.maybeWhen(
          cartLoaded: (cart, _, __) {
            setState(() => _lastCount = cart.items.length);
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, st) {
          // إذا في cartLoaded استخدمه، غير هيك استخدم آخر قيمة محفوظة
          final countNow = st.maybeWhen(
            cartLoaded: (cart, _, __) => cart.items.length,
            orElse: () => _lastCount,
          );

          final hasCart = countNow > 0;

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
              child: CustomButtonOrder(
                title: (hasCart
                        ? widget.viewCartTitleKey
                        : widget.emptyTitleKey)
                    .tr(),
                onPressed: hasCart ? widget.onViewCart : widget.onEmptyCart,
              ),
            ),
          );
        },
      ),
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
        int count = 0;
        double total = 0;

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, _, __) {
            count = cart.items.length;
            total = cart.grandAfter; // أو itemsTotalAfter حسب شو بتحب تعرض
          },
          orElse: () {},
        );

        final hasCart = count > 0;

        // ✅ نفس المطاعم: إذا سلة -> View Cart، إذا فاضي -> Your Order
        if (hasCart) {
          return CustomButton(
            title: loading
                ? "View Cart ..."
                : "View Cart • $count • ${context.money(total, decimals: 0)}",
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

        // ✅ سلة فاضية -> Your Order (نفس زر المطاعم)
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
