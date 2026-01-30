import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/popular_grid_Page.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/orders/add_order.dart'; // showAddOrderDialog
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart'; // MenuExtra (الموحد)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';

/// --------------------------------------------------------------
/// عنوان القسم "Most Popular"
/// --------------------------------------------------------------
class CustomTitleSection extends StatelessWidget {
  final String title;
  final String? all;
  final IconData? icon;
  final VoidCallback? ontap;

  const CustomTitleSection({
    required this.title,
    this.all,
    this.icon,
    this.ontap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
            fontFamily: "Manrope",
          ),
        ),
        if (all != null && ontap != null)
          GestureDetector(
            onTap: ontap,
            child: Row(
              children: [
                Text(
                  all!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.white,
                    fontFamily: "Manrope",
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(icon, size: 12.sp, color: AppColor.white),
              ],
            ),
          ),
      ],
    );
  }
}

/// --------------------------------------------------------------
/// Section: Most Popular horizontal list (HOME)
//  ✅ MenuItemModel
/// --------------------------------------------------------------
class MostPopularSection extends StatelessWidget {
  final List<MenuItemModel> items;
  final int? restaurantId; // ✅ جديد اختياري
  const MostPopularSection({super.key, required this.items, this.restaurantId});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final gap = 8.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    final count = items.length;
    double containerWidth = switch (count) {
      0 => 0,
      1 => cardWidth + 4,
      2 => (2 * cardWidth) + gap + 4,
      _ => MediaQuery.of(context).size.width - 20,
    };

    containerWidth = containerWidth.clamp(
      0.0,
      MediaQuery.of(context).size.width - 20,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomTitleSection(
            title: "Most Popular",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PopularGridPage(items: items),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140.h,
          // width: containerWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            physics: count <= 2
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];

              final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 16.w : 0, // 🔥 أول عنصر فقط
                  end: index == count - 1 ? 16.w : gap,
                ),
                child: SizedBox(
                  width: cardWidth,

                  child: GestureDetector(
                    onTap: () async {
                      final menuItemId = item.id;
                      final resolvedRestaurantId =
                          restaurantId ?? (item.restaurant?.id ?? 0);

                      if (resolvedRestaurantId == 0 || menuItemId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("لا يمكن تحديد المطعم أو الوجبة"),
                          ),
                        );
                        return;
                      }

                      await showAddOrderDialog(
                        context,
                        restaurantId: resolvedRestaurantId,
                        menuItemId: menuItemId,
                        title: title,
                        price: (item.priceAfter > 0
                            ? item.priceAfter
                            : item.priceBefore),
                        oldPrice: item.priceBefore,
                        imagePathOrUrl:
                            item.primaryImage?.imageUrl ??
                            "assets/images/shawarma_box.png",
                        description: "",
                        extraMeals: const <MenuExtra>[],
                      );

                      if (context.mounted) {
                        context.read<CartCubit>().loadCart();
                      }
                    },

                    child: PopularItemCard(item: item), // ✅ MenuItemModel
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// --------------------------------------------------------------
/// Card: Popular Item (HOME) + Favorite Toggle
/// ✅ MenuItemModel
/// --------------------------------------------------------------
class PopularItemCard extends StatefulWidget {
  final MenuItemModel item;

  const PopularItemCard({super.key, required this.item});

  @override
  State<PopularItemCard> createState() => _PopularItemCardState();
}

class _PopularItemCardState extends State<PopularItemCard> {
  bool _isFavorite = false; // ✅ no late
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
  }

  @override
  void didUpdateWidget(covariant PopularItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.isFavorite != widget.item.isFavorite) {
      _isFavorite = widget.item.isFavorite;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_sending) return;

    final id = widget.item.id;
    if (id <= 0) return;

    final previous = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    _sending = true;

    try {
      debugPrint("❤️ toggle fav id=$id  prev=$previous -> now=$_isFavorite");

      final favCubit = context.read<FavoritesCubit>();
      final res = await favCubit.toggle(id);

      debugPrint("✅ toggle result ok=${res.ok} msg=${res.message}");

      if (!res.ok) {
        setState(() => _isFavorite = previous);
        EasyLoading.showError(res.message ?? "Failed");
      }
    } catch (e, st) {
      debugPrint("❌ toggle fav crashed: $e\n$st");
      setState(() => _isFavorite = previous);
      EasyLoading.showError("Failed: $e");
    } finally {
      _sending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlHelper.toFullUrl(widget.item.primaryImage?.imageUrl);

    final title = context.pick(ar: widget.item.nameAr, en: widget.item.nameEn);

    // ✅ منطق الخصم الموحد
    final hasDiscount =
        widget.item.hasDiscount == true && (widget.item.discountValue ?? 0) > 0;

    final before = (widget.item.priceBefore > 0)
        ? widget.item.priceBefore
        : widget.item.priceAfter;

    final after = (widget.item.priceAfter > 0)
        ? widget.item.priceAfter
        : widget.item.priceBefore;

    final percent = (widget.item.discountValue ?? 0).toDouble();

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
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? _imageFallback()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              if (hasDiscount)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(20.r),
                        bottomEnd: Radius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      "-${percent.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // Favorite
              PositionedDirectional(
                top: 6,
                end: 6,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleFavorite,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isFavorite ? 1.2 : 1.0,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ================= TEXT AREA =================
          Container(
            height: 55.h,
            width: double.infinity,
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
                  ),
                ),

                if (!hasDiscount)
                  Text(
                    context.syp(after),
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          Localizations.localeOf(context).languageCode == 'ar'
                          ? 'Cairo'
                          : 'Inter',
                    ),
                  )
                else
                  Row(
                    children: [
                      Text(
                        context.syp(before),
                        style: TextStyle(
                          color: AppColor.LightActive,
                          fontSize: 11.sp,
                          decoration: TextDecoration.lineThrough,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        context.syp(after),
                        style: TextStyle(
                          color: AppColor.red,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
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

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 26),
    );
  }
}

class MostPopular extends StatelessWidget {
  const MostPopular({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
