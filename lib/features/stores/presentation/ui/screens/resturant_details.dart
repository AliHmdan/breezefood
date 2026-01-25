import 'package:breezefood/android_swipe_back.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discountMealSection.dart';
import 'package:breezefood/features/reviews/presentation/rate_dialog.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/request_order/tiem_price.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/reviews/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/most_popular_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 
class ResturantDetails extends StatefulWidget {
  final int restaurant_id;
  final int? initialMenuItemId;

  const ResturantDetails({
    super.key,
    required this.restaurant_id,
    this.initialMenuItemId,
  });

  @override
  State<ResturantDetails> createState() => _ResturantDetailsState();
}

class _ResturantDetailsState extends State<ResturantDetails> {
  int selectedCategoryIndex = 0;
  bool _openedInitial = false;

  late final RestaurantDetailsCubit cubit;
  late final MostPopularCubit mostPopularCubit;

  @override
  void initState() {
    super.initState();

    cubit = getIt<RestaurantDetailsCubit>();
    mostPopularCubit = getIt<MostPopularCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(widget.restaurant_id);
      mostPopularCubit.load(widget.restaurant_id);

      // ✅ نفس CartCubit يلي جاي من Home
      if (mounted) context.read<CartCubit>().loadCart();
    });
  }

  @override
  void dispose() {
    cubit.close();
    mostPopularCubit.close();
    super.dispose();
  }

  String _fullImageUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return "";
    return UrlHelper.toFullUrl(v) ?? "";
  }

  double _extractCartTotal(dynamic cart) {
    if (cart == null) return 0.0;

    if (cart is Map) {
      final keys = [
        "total",
        "total_price",
        "totalPrice",
        "grand_total",
        "grandTotal",
        "subtotal",
        "sub_total",
        "subTotal",
        "amount",
      ];
      for (final k in keys) {
        final n = _toNum(cart[k]);
        if (n != null) return n.toDouble();
      }
    }

    try {
      final n = _toNum((cart as dynamic).total);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).totalPrice);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).grandTotal);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).subTotal);
      if (n != null) return n.toDouble();
    } catch (_) {}

    return 0.0;
  }

  String _pickSingleLangFromMixed(String s, BuildContext context) {
    final v = (s).trim();
    if (v.isEmpty) return "";

    // أشهر فواصل الدمج بالسيرفرات
    final separators = ['|', '||', '/', ' / ', '\n', ' - ', ' — ', ' – '];

    for (final sep in separators) {
      if (v.contains(sep)) {
        final parts = v
            .split(sep)
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parts.length >= 2) {
          // إذا عربي خذ الأول، إذا إنكليزي خذ الثاني (هذا الافتراض الأكثر شيوعاً)
          return context.isAr ? parts.first : parts[1];
        }
      }
    }

    // إذا ما كان مدموج أصلاً
    return v;
  }

  int _extractCartCount(dynamic cart) {
    if (cart == null) return 0;

    if (cart is Map) {
      final items = cart["items"] ?? cart["data"] ?? cart["cart_items"];
      if (items is List) return items.length;

      final count = cart["count"] ?? cart["items_count"] ?? cart["itemsCount"];
      final n = _toNum(count);
      if (n != null) return n.toInt();
    }

    try {
      final items = (cart as dynamic).items;
      if (items is List) return items.length;
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).count);
      if (n != null) return n.toInt();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).itemsCount);
      if (n != null) return n.toInt();
    } catch (_) {}

    return 0;
  }

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<RatingSubmitCubit>())],
      child: AndroidSwipeBack(
        child: BlocListener<CartCubit, CartState>(
          listenWhen: (prev, curr) =>
              curr.maybeWhen(addedSuccess: (_) => true, orElse: () => false),
          listener: (context, state) {
            context.read<CartCubit>().loadCart();
          },
          child: Scaffold(
            bottomNavigationBar: SafeArea(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, st) {
                  double total = 0.0;
                  int count = 0;
                  bool loading = false;

                  st.maybeWhen(
                    loading: () => loading = true,
                    cartLoaded: (cart, updatingIds, toast) {
                      total = _extractCartTotal(cart);
                      count = _extractCartCount(cart);
                    },
                    orElse: () {},
                  );

                  if (count <= 0) return const SizedBox.shrink();

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.Dark,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      title: loading
                          ? "common.view_cart_loading".tr()
                          : "common.view_cart".tr(
                              namedArgs: {
                                "count": "$count",
                                "total": context.money(total, decimals: 0),
                              },
                            ),
                      onPressed: loading
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      // ✅ نفس CartCubit الحالي
                                      BlocProvider.value(
                                        value: context.read<CartCubit>(),
                                      ),
                                      BlocProvider(
                                        create: (_) => getIt<OrderFlowCubit>(),
                                      ),
                                    ],
                                    child: const RequestOrderScreen(),
                                  ),
                                ),
                              );

                              if (context.mounted) {
                                context.read<CartCubit>().loadCart();
                              }
                            },
                    ),
                  );
                },
              ),
            ),
            body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
              bloc: cubit,
              builder: (context, state) {
                String headerImageUrl = "";
                String restaurantName = "common.empty".tr();
                String description = "common.empty".tr();
                String deliveryTime = "--";
                String deliveryCash = "--";
                String ratingText = "0.0";
                String ordersText = "reviews.orders_count".tr(
                  namedArgs: {"count": "0"},
                );

                List<String> categories = const [];
                List<List<MenuItem>> itemsByCategory = const [];
                List<MenuItem> selectedItems = const [];
                List<MenuItem> discountedItems = const [];

                state.maybeWhen(
                  loaded: (data) {
                    final g = data.general;

                    restaurantName = (g.name).trim().isNotEmpty
                        ? _pickSingleLangFromMixed(g.name, context)
                        : "restaurant.details.fallback_name".tr();

                    description = (g.description ?? "").trim().isNotEmpty
                        ? _pickSingleLangFromMixed(g.description!, context)
                        : " ";

                    headerImageUrl = _fullImageUrl(
                      (g.cover ?? g.logo ?? "").toString(),
                    );

                    if (g.deliveryTime > 0) deliveryTime = "${g.deliveryTime}";
                    deliveryCash = context.money(g.deliveryCash, decimals: 0);

                    if (g.avgRating > 0) {
                      ratingText = g.avgRating.toStringAsFixed(1);
                    }
                    if (g.totalCompletedOrders > 0) {
                      ordersText = "reviews.orders_count".tr(
                        namedArgs: {"count": "${g.totalCompletedOrders}"},
                      );
                    }

                    final sections = data.restaurantMenuItems;

                    categories = sections.map((e) {
                      return context.pick(
                        ar: e.category.nameAr,
                        en: e.category.nameEn,
                      );
                    }).toList();

                    itemsByCategory = sections.map((e) => e.items).toList();

                    if (categories.isNotEmpty) {
                      if (selectedCategoryIndex >= categories.length) {
                        selectedCategoryIndex = 0;
                      }
                      selectedItems = itemsByCategory[selectedCategoryIndex];
                    } else {
                      selectedItems = const [];
                    }

                    final allItems = sections.expand((s) => s.items).toList();
                    discountedItems =
                        allItems.where((x) => x.hasDiscount).toList()..sort(
                          (a, b) =>
                              b.discountPercent.compareTo(a.discountPercent),
                        );

                    // ✅ open initial item once
                    if (!_openedInitial && widget.initialMenuItemId != null) {
                      _openedInitial = true;

                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!mounted) return;

                        MenuItem? it;
                        try {
                          it = allItems.firstWhere(
                            (x) => x.id == widget.initialMenuItemId,
                          );
                        } catch (_) {
                          it = null;
                        }

                        if (it == null) return;

                        final title = context.pick(
                          ar: it.nameAr,
                          en: it.nameEn,
                        );
                        final desc = context.pick(
                          ar: it.descriptionAr ?? "",
                          en: it.descriptionEn ?? "",
                        );
                        final img = _fullImageUrl(it.image ?? "");

                        await showAddOrderDialog(
                          context,
                          restaurantId: widget.restaurant_id,
                          menuItemId: it.id,
                          title: title,
                          price: it.effectivePrice,
                          oldPrice: (it.priceBefore > 0
                              ? it.priceBefore
                              : it.price),
                          imagePathOrUrl: img.isNotEmpty
                              ? img
                              : "assets/images/shawarma_box.png",
                          description: desc,
                          extraMeals: it.mealExtras,
                        );

                        if (mounted) context.read<CartCubit>().loadCart();
                      });
                    }
                  },
                  orElse: () {},
                );
                int? myReviewId;
                double myUserRating = 0.0;

                state.maybeWhen(
                  loaded: (data) {
                    myReviewId = data.myRating?.id;
                    myUserRating = data.myRating?.rating ?? 0.0;
                  },
                  orElse: () {},
                );

                return Stack(
                  children: [
                    SizedBox(
                      height: 240.h,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          headerImageUrl.isEmpty
                              ? Image.asset(
                                  "assets/images/shawarma_box.png",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  headerImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    "assets/images/shawarma_box.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.black.withOpacity(0.2),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              restaurantName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar'
                                    ? 'Cairo'
                                    : 'Inter',
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 12,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 220.h,
                        bottom: MediaQuery.of(context).padding.bottom + 16.h,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.Dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TiemPrice(
                                    icon: Icons.alarm,
                                    title: deliveryTime,
                                    subtitle: "common.min".tr(),
                                  ),
                                  TiemPrice(
                                    title: deliveryCash,
                                    subtitle: "",
                                    svgPath: "assets/icons/motor.svg",
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Search(
                                      restaurantId: widget.restaurant_id,
                                    ),
                                  ),
                                );
                              },
                              child: AbsorbPointer(
                                child: CustomSearch(hint: "common.search".tr()),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  final res = await showRateDialogWithDelete(
                                    context,
                                    currentRating: myUserRating > 0
                                        ? myUserRating
                                        : (double.tryParse(ratingText) ?? 0.0),
                                    canDelete:
                                        (myReviewId != null && myReviewId! > 0),
                                  );

                                  if (res == null) return;

                                  final submitCubit = context
                                      .read<RatingSubmitCubit>();

                                  EasyLoading.show(
                                    status: "common.sending".tr(),
                                  );

                                  if (res.delete) {
                                    if (myReviewId == null) {
                                      EasyLoading.showError(
                                        "reviews.no_review_to_delete".tr(),
                                      );
                                      return;
                                    }

                                    await submitCubit.deleteRestaurantRate(
                                      reviewId: myReviewId!,
                                    );

                                    submitCubit.state.maybeWhen(
                                      deleteSuccess: () {
                                        EasyLoading.showSuccess(
                                          "reviews.delete_success".tr(),
                                        );
                                        cubit.load(widget.restaurant_id);
                                      },
                                      error: (msg) =>
                                          EasyLoading.showError(msg),
                                      orElse: () => EasyLoading.dismiss(),
                                    );
                                    return;
                                  }

                                  // Submit
                                  await submitCubit.submitRestaurantRate(
                                    restaurantId: widget.restaurant_id,
                                    rating: res.rating!,
                                  );

                                  submitCubit.state.maybeWhen(
                                    success: () {
                                      EasyLoading.showSuccess(
                                        "reviews.rate_success".tr(),
                                      );
                                      cubit.load(widget.restaurant_id);
                                    },
                                    error: (msg) => EasyLoading.showError(msg),
                                    orElse: () => EasyLoading.dismiss(),
                                  );
                                },

                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomSubTitle(
                                        subtitle: description,
                                        color: AppColor.gry,
                                        fontsize: 8,
                                      ),
                                    ),
                                    _divider(),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ratingText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    _divider(),
                                    CustomSubTitle(
                                      subtitle: ordersText,
                                      color: AppColor.white,
                                      fontsize: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ---------------- Category ----------------
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SizedBox(
                                height: 35.h,
                                child: categories.isEmpty
                                    ? Center(
                                        child: CustomSubTitle(
                                          subtitle: "common.empty".tr(),
                                          color: AppColor.gry,
                                          fontsize: 14.sp,
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final isSelected =
                                              selectedCategoryIndex == index;

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                            ), // مسافة خفيفة اختيارية
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedCategoryIndex = index;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: isSelected
                                                      ? AppColor.primaryColor
                                                      : AppColor.black,
                                                ),
                                                child: CustomSubTitle(
                                                  subtitle: categories[index],
                                                  color: isSelected
                                                      ? AppColor.white
                                                      : AppColor.LightActive,
                                                  fontsize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),

                            // ✅ Discounts Section
                            DiscountMealSection(
                              items: discountedItems,
                              fullImageUrl: _fullImageUrl,
                              onTap: (it) async {
                                final title = context.pick(
                                  ar: it.nameAr,
                                  en: it.nameEn,
                                );
                                final desc = context.pick(
                                  ar: it.descriptionAr ?? "",
                                  en: it.descriptionEn ?? "",
                                );
                                final img = _fullImageUrl(it.image ?? "");

                                await showAddOrderDialog(
                                  context,
                                  restaurantId: widget.restaurant_id,
                                  menuItemId: it.id,
                                  title: title,
                                  price: it.effectivePrice,
                                  oldPrice: (it.priceBefore > 0
                                      ? it.priceBefore
                                      : it.price),
                                  imagePathOrUrl: img.isNotEmpty
                                      ? img
                                      : "assets/images/shawarma_box.png",
                                  description: desc,
                                  extraMeals: it.mealExtras,
                                );

                                if (context.mounted) {
                                  context.read<CartCubit>().loadCart();
                                }
                              },
                            ),

                            const SizedBox(height: 10),

                            // ---------------- Most Popular ----------------
                            BlocBuilder<MostPopularCubit, MostPopularState>(
                              bloc: mostPopularCubit,
                              builder: (context, mpState) {
                                return mpState.maybeWhen(
                                  loading: () => const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  error: (msg) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    child: CustomSubTitle(
                                      subtitle: msg,
                                      color: AppColor.red,
                                      fontsize: 12,
                                    ),
                                  ),
                                  loaded: (items) {
                                    if (items.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: MostPopularSection(items: items),
                                    );
                                  },
                                  orElse: () => const SizedBox.shrink(),
                                );
                              },
                            ),

                            // =========================================Menu===================================
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: CustomTitleSection(
                                title: "restaurant.menu".tr(),
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (selectedItems.isEmpty)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 16,
                                ),
                                child: CustomSubTitle(
                                  subtitle: "common.empty".tr(),
                                  color: AppColor.gry,
                                  fontsize: 12.sp,
                                ),
                              )
                            else
                              SizedBox(
                                height: 140.h,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 16,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: selectedItems.length,
                                    itemBuilder: (context, i) {
                                      final it = selectedItems[i];

                                      final imageUrl = _fullImageUrl(
                                        it.image ?? "",
                                      );

                                      // ✅ خلي السعر فعّال (بعد الخصم)
                                      final price = it.effectivePrice;

                                      final mapped = MenuItemModel(
                                        id: it.id,
                                        nameAr: it.nameAr,
                                        nameEn: it.nameEn,
                                        priceBefore: (it.priceBefore > 0
                                            ? it.priceBefore
                                            : it.price),
                                        priceAfter: it.effectivePrice,
                                        hasDiscount: it.hasDiscount,
                                        discountType: it.discountType,
                                        discountValue: it.discountPercent,
                                        isFavorite: it.isFavorite,
                                        primaryImage: imageUrl.isEmpty
                                            ? null
                                            : PrimaryImageModel(
                                                imageUrl: imageUrl,
                                              ),
                                        restaurant: null,
                                      );

                                      return GestureDetector(
                                        onTap: () async {
                                          final menuItemId = it.id;
                                          final restaurantId =
                                              widget.restaurant_id;

                                          if (menuItemId == 0 ||
                                              restaurantId == 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: CustomSubTitle(
                                                  subtitle:
                                                      "orders.cannot_identify_meal_or_restaurant"
                                                          .tr(),

                                                  color: AppColor.red,
                                                  fontsize: 14.sp,
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          await showAddOrderDialog(
                                            context,
                                            restaurantId: restaurantId,
                                            menuItemId: menuItemId,
                                            title: context.pick(
                                              ar: it.nameAr,
                                              en: it.nameEn,
                                            ),
                                            price: price,
                                            oldPrice: (it.priceBefore > 0
                                                ? it.priceBefore
                                                : it.price),
                                            imagePathOrUrl: imageUrl.isNotEmpty
                                                ? imageUrl
                                                : "assets/images/shawarma_box.png",
                                            description: context.pick(
                                              ar: it.descriptionAr ?? "",
                                              en: it.descriptionEn ?? "",
                                            ),
                                            extraMeals: it.mealExtras,
                                          );

                                          if (mounted) {
                                            context
                                                .read<CartCubit>()
                                                .loadCart();
                                          }
                                        },
                                        child: Container(
                                          width: 170.w,
                                          margin: EdgeInsetsDirectional.only(
                                            end: i == selectedItems.length - 1
                                                ? 0
                                                : 8.w,
                                          ),
                                          child: PopularItemCard(item: mapped),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            state.maybeWhen(
                              loading: () => const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (msg) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Center(
                                  child: CustomSubTitle(
                                    subtitle: msg,
                                    color: AppColor.red,
                                    fontsize: 14,
                                  ),
                                ),
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 10),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 20.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.LightActive,
    );
  }
}

String _trMsg(String msg, {required String fallbackKey}) {
  final v = msg.trim();
  if (v.isEmpty) return fallbackKey.tr();

  // إذا رجعت من repo keys مثل "rate_failed" أو "delete_failed"
  if (v == "rate_failed") return "reviews.rate_failed".tr();
  if (v == "delete_failed") return "reviews.delete_failed".tr();

  // غير هيك اعرضه كما هو
  return v;
}

class DiscountItemCard extends StatelessWidget {
  final MenuItem item;
  final String imageUrl;

  const DiscountItemCard({
    super.key,
    required this.item,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final before = item.priceBefore > 0 ? item.priceBefore : item.price;
    final after = item.effectivePrice;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: AppColor.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              SizedBox(
                height: 85.h,
                width: double.infinity,
                child: imageUrl.isEmpty
                    ? _fallback()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      ),
              ),

              // overlay (نفس MostPopular)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              // discount badge
              PositionedDirectional(
                bottom: 0,
                start: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(20.r),
                      bottomEnd: Radius.circular(20.r),
                    ),
                  ),
                  child: CustomSubTitle(
                    subtitle: "-${item.discountPercent.toStringAsFixed(0)}%",
                    color: AppColor.white,
                    fontsize: 11.sp,
                  ),
                ),
              ),
            ],
          ),

          // ================= TEXT =================
          Container(
            height: 55.h,
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
            color: AppColor.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      context.money(before, decimals: 0),
                      style: TextStyle(
                        color: AppColor.LightActive,
                        fontSize: 11.sp,
                        decoration: TextDecoration.lineThrough,
                        fontFamily:
                            Localizations.localeOf(context).languageCode == 'ar'
                            ? 'Cairo'
                            : 'Inter',
                      ),
                    ),

                    const SizedBox(width: 6),
                    CustomSubTitle(
                      subtitle: context.money(after, decimals: 0),
                      color: AppColor.red,
                      fontsize: 12.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 26),
    );
  }
}
