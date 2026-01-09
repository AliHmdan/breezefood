import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/market_details_cubit.dart';
import 'package:breezefood/features/super_market/supermarket_add_order_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class MarketPagePrice extends StatelessWidget {
  final int marketId;
  final String title;

  const MarketPagePrice({
    super.key,
    required this.marketId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MarketDetailsCubit(
            repo: getIt<SuperMarketRepo>(),
            marketId: marketId,
          )..load(),
        ),
        BlocProvider(create: (_) => getIt<CartCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          // ✅ Market loading feedback (اختياري)
          BlocListener<MarketDetailsCubit, MarketDetailsState>(
            listenWhen: (p, c) =>
                p.loading != c.loading ||
                p.loadingItems != c.loadingItems ||
                p.error != c.error,
            listener: (context, state) {
              if (state.loading || state.loadingItems) {
                EasyLoading.show(status: "Loading...".tr());
              } else {
                EasyLoading.dismiss();
              }

              if (state.error != null) {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
          ),

          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {
                  EasyLoading.show(status: "Adding...".tr());
                },
                addedSuccess: (message) {
                  EasyLoading.dismiss();

                  // ✅ فيدباك واضح
                  EasyLoading.showSuccess(
                    message.isEmpty ? "added_success".tr() : message,
                  );

                  // ✅ حمّل السلة لتحديث الزر/العدد
                  context.read<CartCubit>().loadCart();
                },
                cartLoaded: (cart, updatingIds, toast) {
                  EasyLoading.dismiss();

                  // ✅ لو بدك toast خفيف من السيرفر/الكيوبيت
                  if (toast != null && toast.trim().isNotEmpty) {
                    // either EasyLoading or SnackBar
                    EasyLoading.showInfo(toast);
                  }
                },
                error: (message) {
                  EasyLoading.dismiss();
                  EasyLoading.showError(
                    message.isEmpty ? "something_wrong".tr() : message,
                  );
                },
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 22.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: BlocBuilder<MarketDetailsCubit, MarketDetailsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null) {
                      return Center(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Categories
                        SizedBox(
                          height: 44.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, i) {
                              final c = state.categories[i];
                              final selected = c.id == state.selectedCategoryId;

                              return InkWell(
                                onTap: () => context
                                    .read<MarketDetailsCubit>()
                                    .selectCategory(c.id),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF1C1C1C),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // ✅ Items
                        Expanded(
                          child: state.loadingItems
                              ? const Center(child: CircularProgressIndicator())
                              : GridView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    12.w,
                                    12.h,
                                    12.w,
                                    90.h,
                                  ),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: state.items.length,
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 190.w,
                                        crossAxisSpacing: 10.w,
                                        mainAxisSpacing: 10.h,
                                        childAspectRatio: 0.80,
                                      ),
                                  itemBuilder: (context, index) {
                                    final it = state.items[index];

                                    final titleTxt = context.pick(
                                      ar: it.nameAr,
                                      en: it.nameEn,
                                    );
                                    final descTxt = context.pick(
                                      ar: it.descriptionAr,
                                      en: it.descriptionEn,
                                    );
                                    final priceStr = it.basePrice.money(
                                      context,
                                    );

                                    final imgUrl =
                                        UrlHelper.toFullUrl(it.image) ?? "";

                                    return Opacity(
                                      opacity: it.isAvailable ? 1 : 0.45,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          18.r,
                                        ),
                                        onTap: !it.isAvailable
                                            ? () => EasyLoading.showInfo(
                                                "Not available".tr(),
                                              )
                                            : () async {
                                                final res =
                                                    await showSupermarketAddOrderDialog(
                                                      context,
                                                      title: titleTxt,
                                                      price: priceStr,
                                                      oldPrice: null,
                                                      imagePath:
                                                          imgUrl.isNotEmpty
                                                          ? imgUrl
                                                          : "assets/images/bread.png",
                                                    );
                                                if (res == null) return;

                                                final req = AddToCartRequest(
                                                  restaurantId: marketId,
                                                  menuItemId: it.id,
                                                  quantity: res.quantity,
                                                  specialNotes: res.notes,
                                                );

                                                context.read<CartCubit>().add(
                                                  req,
                                                );
                                              },
                                        child: ProductCard(
                                          product: Product(
                                            title: titleTxt,
                                            desc: descTxt,
                                            price: priceStr,
                                            image: imgUrl.isNotEmpty
                                                ? imgUrl
                                                : "assets/images/bread.png",
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ✅ زر Your Order ثابت تحت + feedback لو السلة فاضية
              Positioned(
                left: 0,
                right: 0,
                bottom: 16.h,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: CustomButtonOrder(
                      title: "home.your_order".tr(),
                      onPressed: () async {
                        // لو بدك: تأكد السلة مو فاضية قبل ما تفتح
                        // (حسب CartCubit عندك: items length)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (_) => getIt<CartCubit>()..loadCart(),
                                ),
                                BlocProvider(
                                  create: (_) => getIt<OrderFlowCubit>(),
                                ),
                              ],
                              child: const RequestOrderScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: product.isNetworkImage
                  ? Image.network(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/bread.png",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          SizedBox(height: 6.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              product.desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              product.price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

/* ===========================
        Product Model
=========================== */

class Product {
  final String title;
  final String price;
  final String image; // ممكن url أو asset
  final String desc;

  Product({
    required this.title,
    required this.desc,
    required this.price,
    required this.image,
  });

  bool get isNetworkImage => image.startsWith("http");
}
