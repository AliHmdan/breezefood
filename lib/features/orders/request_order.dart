import 'package:breezefood/core/component/color.dart' show AppColor;
import 'package:breezefood/features/orders/payment_method.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/request_order/counter_request.dart';
import 'package:breezefood/features/orders/request_order/meal_card.dart';
import 'package:breezefood/features/orders/request_order/total.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestOrder extends StatefulWidget {
  const RequestOrder({super.key});

  @override
  State<RequestOrder> createState() => _RequestOrderState();
}

class _RequestOrderState extends State<RequestOrder> {
  final List<PaymentMethod> mockMethods = const [
    PaymentMethod(
      id: 'cash',
      title: 'Cash',
      imageAsset: 'assets/images/cash.png',
      imageWidth: 36,
      imageHeight: 24,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final title = state.maybeWhen(
                cartLoaded: (cart, updatingIds, toast) => cart.restaurantName,

                orElse: () => "My Cart",
              );

              return CustomAppbarProfile(
                title: title,
                icon: Icons.arrow_back_ios,
                ontap: () => Navigator.pop(context),
              );
            },
          ),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(
              child: Text(msg, style: const TextStyle(color: Colors.red)),
            ),
            // داخل BlocBuilder
            cartLoaded: (cart, updatingIds, toast) {
              final subTotal = cart.itemsTotal; // ✅ كان غلط عندك deliveryFee
              final delivery = cart.deliveryFee;
              final total = cart.grandTotal;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      if (toast != null && toast.trim().isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            toast,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],

                      if (cart.items.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
                          child: Text(
                            "Cart is empty",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: cart.items.map((it) {
                            final isUpdating = updatingIds.contains(it.id);

                            return MealCard(
                              image: it.image,
                              name: it.nameAr,
                              price: it.unitPrice,
                              counter: CounterRequest(
                                value: it.quantity,
                                loading: isUpdating,
                                onChanged: (newQty) {
                                  context.read<CartCubit>().updateQty(
                                    cartItemId: it.id,
                                    quantity: newQty,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),

                      // ... باقي الواجهة عندك كما هي
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 18.h,
                          horizontal: 10.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Total("Sub total", subTotal),
                            Total("Delivery", delivery),
                            const Divider(color: Colors.white30),
                            Total("Total", total, isTotal: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },

            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
