import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/orders/request_order/tiem_price.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/most_popular_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResturantDetails extends StatefulWidget {
  final int restaurant_id;
  const ResturantDetails({super.key, required this.restaurant_id});

  @override
  State<ResturantDetails> createState() => _ResturantDetailsState();
}

class _ResturantDetailsState extends State<ResturantDetails> {
  int selectedCategoryIndex = 0;
  late final RestaurantDetailsCubit cubit;

  late final MostPopularCubit mostPopularCubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<RestaurantDetailsCubit>();
    mostPopularCubit = getIt<MostPopularCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(widget.restaurant_id);
      mostPopularCubit.load(widget.restaurant_id); // ✅ Most Popular
    });
  }

  @override
  void dispose() {
    cubit.close();
    mostPopularCubit.close();
    super.dispose();
  }

  String _emptyIfBlank(String? s) {
    final v = (s ?? '').trim();
    return v.isEmpty ? "Empty" : v;
  }

  String _money(num? n) {
    if (n == null) return "Empty";
    return "$n";
  }

  String _fullImageUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return "";
    return UrlHelper.toFullUrl(v) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          String headerImageUrl = "";
          String restaurantName = "Empty";
          String description = "Empty";
          String deliveryTime = "Empty";
          String deliveryCash = "Empty";
          String ratingText = "0.0";
          String ordersText = "0 Order";

          List<String> categories = const [];
          List<dynamic> selectedItems = const [];

          state.maybeWhen(
            loaded: (data) {
              final g = data.general;

              headerImageUrl = _fullImageUrl(g.cover ?? g.logo ?? "");

              restaurantName = _emptyIfBlank(g.name);
              description = _emptyIfBlank(g.description);

              deliveryTime = (g.deliveryTime == 0)
                  ? "Empty"
                  : "${g.deliveryTime}";
              deliveryCash = _money(g.deliveryCash);

              try {
                ratingText = g.avgRating.toStringAsFixed(1);
              } catch (_) {
                ratingText = "${g.avgRating}";
              }

              ordersText = "${g.totalCompletedOrders} Order";

              final sections = data.restaurantMenuItems;

              categories = sections
                  .map(
                    (s) => context.pick(
                      ar: s.category.nameAr,
                      en: s.category.nameEn,
                    ),
                  )
                  .where((x) => x.trim().isNotEmpty && x != "Empty")
                  .toList();

              if (selectedCategoryIndex >= sections.length) {
                selectedCategoryIndex = 0;
              }

              selectedItems = sections.isNotEmpty
                  ? sections[selectedCategoryIndex].items
                  : const [];
            },
            orElse: () {},
          );

          return Stack(
            children: [
              SizedBox(
                height: 240.h,
                width: double.infinity,
                child: headerImageUrl.isEmpty
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
              ),

              SingleChildScrollView(
                padding: EdgeInsets.only(top: 220.h, bottom: 120.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.Dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TiemPrice(
                              icon: Icons.alarm,
                              title: deliveryTime,
                              subtitle: "min",
                            ),
                            TiemPrice(
                              title: deliveryCash,
                              subtitle: "\$",
                              svgPath: "assets/icons/motor.svg",
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Center(
                        child: CustomTitle(
                          title: restaurantName,
                          color: AppColor.white,
                        ),
                      ),

                      const CustomSearch(hint: "Search"),
                      SizedBox(height: 8.h),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomSubTitle(
                                subtitle: description,
                                color: AppColor.gry,
                                fontsize: 8.sp,
                              ),
                            ),
                            _divider(),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              ratingText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            _divider(),
                            Text(
                              ordersText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ---------------- Categories (from API) ----------------
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50.h,
                          child: categories.isEmpty
                              ? Center(
                                  child: CustomSubTitle(
                                    subtitle: "Empty",
                                    color: AppColor.gry,
                                    fontsize: 12.sp,
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final bool isSelected =
                                        selectedCategoryIndex == index;

                                    return Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => selectedCategoryIndex = index,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: isSelected
                                                ? AppColor.primaryColor
                                                : AppColor.black,
                                          ),
                                          child: Center(
                                            child: CustomSubTitle(
                                              subtitle: categories[index],
                                              color: isSelected
                                                  ? AppColor.white
                                                  : AppColor.LightActive,
                                              fontsize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      /// ---------------- Most Popular (from API) ----------------
                      BlocBuilder<MostPopularCubit, MostPopularState>(
                        bloc: mostPopularCubit,
                        builder: (context, mpState) {
                          return mpState.maybeWhen(
                            loading: () => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (msg) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(
                                msg,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            loaded: (items) {
                              if (items.isEmpty) return const SizedBox.shrink();
                              // ✅ نفس شكل home most popular (نفس PopularItemCard)
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: MostPopularSection(items: items),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: CustomTitleSection(title: "Menu"),
                      ),
                      const SizedBox(height: 10),

                      if (selectedItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomSubTitle(
                            subtitle: "Empty",
                            color: AppColor.gry,
                            fontsize: 12.sp,
                          ),
                        )
                      else
                        SizedBox(
                          height: 160.h,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: selectedItems.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, i) {
                              final it = selectedItems[i];

                              final imageUrl = _fullImageUrl(it.image ?? "");

                              final title = context.pick(
                                ar: it.nameAr,
                                en: it.nameEn,
                              );

                              final desc = context.pick(
                                ar: it.descriptionAr,
                                en: it.descriptionEn,
                              );

                              final mapped = MenuItemModel(
                                id: it.id ?? 0,
                                nameAr: it.nameAr ?? "",
                                nameEn: it.nameEn ?? "",
                                priceBefore: (it.price ?? 0).toDouble(),
                                priceAfter: (it.price ?? 0).toDouble(),
                                hasDiscount: false,
                                discountType: null,
                                discountValue: null,
                                isFavorite: it.isFavorite ?? false,
                                primaryImage: imageUrl.isEmpty
                                    ? null
                                    : PrimaryImageModel(imageUrl: imageUrl),
                                restaurant: null,
                              );

                              return GestureDetector(
                                onTap: () {
                                  final menuItemId = it.id ?? 0;
                                  final restaurantId = widget.restaurant_id;

                                  if (menuItemId == 0 || restaurantId == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "لا يمكن تحديد الوجبة أو المطعم",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final title = context.pick(
                                    ar: it.nameAr ?? "",
                                    en: it.nameEn ?? "",
                                  );

                                  final imageUrl = _fullImageUrl(
                                    it.image ?? "",
                                  );

                                  final desc = context.pick(
                                    ar: it.descriptionAr ?? "",
                                    en: it.descriptionEn ?? "",
                                  );

                                  final price = (it.price ?? 0).toDouble();
                                  final oldPrice = price;

                                  showAddOrderDialog(
                                    context,
                                    restaurantId: restaurantId, // ✅ جديد
                                    menuItemId: menuItemId, // ✅ جديد
                                    title: title,
                                    price: price,
                                    oldPrice: oldPrice,
                                    imagePathOrUrl: imageUrl.isNotEmpty
                                        ? imageUrl
                                        : "assets/images/shawarma_box.png",
                                    description: desc,
                                    extraMeals:
                                        it.mealExtras ?? const <MenuExtra>[],
                                  );
                                },

                                child: SizedBox(
                                  height: 140.h,
                                  width: 160.w,
                                  child: _MenuItemCardWrapper(
                                    item: mapped,
                                    title: title,
                                    desc: desc,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      state.maybeWhen(
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (msg) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: Text(
                              msg,
                              style: const TextStyle(color: Colors.red),
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
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 20.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.light,
    );
  }
}

class _MenuItemCardWrapper extends StatelessWidget {
  final MenuItemModel item;
  final String title;
  final String desc;

  const _MenuItemCardWrapper({
    required this.item,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopularItemCard(item: item),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
