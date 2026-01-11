import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/market_details_cubit.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/market_details_cubit.dart';
import 'package:breezefood/features/super_market/supermarket_add_order_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/component/color.dart';

// أو حط الصفحتين بنفس الملف إذا بتحب

class MarketCategoriesScreen extends StatelessWidget {
  final int marketId;
  final String title;

  const MarketCategoriesScreen({
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
        BlocProvider(create: (_) => getIt<CartCubit>()..loadCart()),
      ],
      child: MultiBlocListener(
        listeners: [
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
              state.maybeWhen(
                loading: () => EasyLoading.show(status: "Loading...".tr()),
                error: (msg) {
                  EasyLoading.dismiss();
                  EasyLoading.showError(
                    msg.isEmpty ? "something_wrong".tr() : msg,
                  );
                },
                orElse: () => EasyLoading.dismiss(),
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColor.Dark,
          appBar: AppBar(
            backgroundColor: AppColor.Dark,
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
          body: BlocBuilder<MarketDetailsCubit, MarketDetailsState>(
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

              final cats = state.categories;
              if (cats.isEmpty) {
                return Center(
                  child: Text(
                    "No categories".tr(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                physics: const BouncingScrollPhysics(),
                itemCount: cats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, i) {
                  final c = cats[i];
                  final selected = c.id == state.selectedCategoryId;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () async {
                      // ✅ افتح صفحة الايتمز + اختار الكاتيغوري هناك
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              // ✅ نفس cubit (حتى ما تعيد جلب categories)
                              BlocProvider.value(
                                value: context.read<MarketDetailsCubit>(),
                              ),
                              // ✅ نفس cartCubit (حتى زر order يضل صحيح)
                              BlocProvider.value(
                                value: context.read<CartCubit>(),
                              ),
                            ],
                            child: MarketItemsScreen(
                              marketId: marketId,
                              marketTitle: title,
                              categoryId: c.id,
                              categoryName: c.name,
                            ),
                          ),
                        ),
                      );

                      // ✅ لما ترجع: رفّش السلة
                      if (context.mounted) context.read<CartCubit>().loadCart();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: selected
                              ? AppColor.primaryColor.withOpacity(0.7)
                              : Colors.white10,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.category,
                                color: AppColor.primaryColor,
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              c.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Tap to view items".tr(),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ✅ زر الطلب: يختفي لو السلة فاضية
          bottomNavigationBar: SafeArea(
            top: false,
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, st) {
                final hasCart = st.maybeWhen(
                  cartLoaded: (cart, _, __) => cart.items.isNotEmpty,
                  orElse: () => false,
                );

                if (!hasCart) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                  child: CustomButtonOrder(
                    title: "home.your_order".tr(),
                    onPressed: () {
                      // افتح صفحة الطلب مثل ما عندك (RequestOrderScreen)
                      // أنا ما حطيتها هون لأنك عندك جاهزة
                      // فقط تأكد تمرر نفس cartCubit (BlocProvider.value)
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MarketItemsScreen extends StatefulWidget {
  final int marketId;
  final String marketTitle;
  final int categoryId;
  final String categoryName;

  const MarketItemsScreen({
    super.key,
    required this.marketId,
    required this.marketTitle,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<MarketItemsScreen> createState() => _MarketItemsScreenState();
}

class _MarketItemsScreenState extends State<MarketItemsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ اختار الكاتيغوري أول ما تفتح صفحة الايتمز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketDetailsCubit>().selectCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () => EasyLoading.show(status: "Adding...".tr()),
          addedSuccess: (message) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess(
              message.isEmpty ? "added_success".tr() : message,
            );
            context.read<CartCubit>().loadCart();
          },
          cartLoaded: (cart, updatingIds, toast) {
            EasyLoading.dismiss();
            if (toast != null && toast.trim().isNotEmpty) {
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
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        appBar: AppBar(
          backgroundColor: AppColor.Dark,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.categoryName,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 22.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<MarketDetailsCubit, MarketDetailsState>(
          builder: (context, state) {
            if (state.loadingItems) {
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

            final items = state.items;
            if (items.isEmpty) {
              return Center(
                child: Text(
                  "No items".tr(),
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 110.h),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190.w,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 0.80,
              ),
              itemBuilder: (context, index) {
                final it = items[index];

                final titleTxt = context.pick(ar: it.nameAr, en: it.nameEn);
                final descTxt = context.pick(
                  ar: it.descriptionAr,
                  en: it.descriptionEn,
                );

                final imgUrl = UrlHelper.toFullUrl(it.image) ?? "";
                final num priceNum = it.basePrice; // ✅
                final String priceText = context.syp(priceNum, decimals: 0);

                return Opacity(
                  opacity: it.isAvailable ? 1 : 0.45,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: !it.isAvailable
                        ? () => EasyLoading.showInfo("Not available".tr())
                        : () async {
                            final res = await showSupermarketAddOrderDialog(
                              context,
                              title: titleTxt,
                              price: priceNum, // ✅ num
                              oldPrice: null, // خليها nullable
                              imagePath: imgUrl.isNotEmpty
                                  ? imgUrl
                                  : "assets/images/bread.png",
                            );

                            if (res == null) return;

                            final req = AddToCartRequest(
                              restaurantId: widget.marketId,
                              menuItemId: it.id,
                              quantity: res.quantity,
                              specialNotes: res.notes,
                            );

                            context.read<CartCubit>().add(req);
                          },
                    child: ProductCard(
                      product: Product(
                        title: titleTxt,
                        desc: descTxt ?? "",
                        price: priceText,
                        image: imgUrl.isNotEmpty
                            ? imgUrl
                            : "assets/images/bread.png",
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        // ✅ زر الطلب: يختفي لو السلة فاضية
        bottomNavigationBar: SafeArea(
          top: false,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, st) {
              final hasCart = st.maybeWhen(
                cartLoaded: (cart, _, __) => cart.items.isNotEmpty,
                orElse: () => false,
              );

              if (!hasCart) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                child: CustomButtonOrder(
                  title: "home.your_order".tr(),
                  onPressed: () {
                    // افتح RequestOrderScreen مثل ما عندك
                    // وتأكد تمرر نفس CartCubit.value
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
