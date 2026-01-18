import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/popular_grid_Page.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/orders/add_order.dart'; // showAddOrderDialog
import 'package:breezefood/features/stores/model/restaurant_details_model.dart'; // MenuExtra (الموحد)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';

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
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: SizedBox(
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

                final title = item.nameAr.isNotEmpty
                    ? item.nameAr
                    : item.nameEn;

                return Container(
                  width: cardWidth,
                  margin: EdgeInsetsDirectional.only(
                    end: index == count - 1 ? 0 : gap,
                  ),
                  child: GestureDetector(
                    onTap: () {
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

                      showAddOrderDialog(
                        context,
                        restaurantId: resolvedRestaurantId, // ✅ جديد
                        menuItemId: menuItemId, // ✅ جديد
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
                    },

                    child: PopularItemCard(item: item), // ✅ MenuItemModel
                  ),
                );
              },
            ),
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
  late bool _isFavorite;
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
      final favCubit = context.read<FavoritesCubit>();
      final res = await favCubit.toggle(id);

      if (!res.ok) {
        setState(() => _isFavorite = previous);
        EasyLoading.showError(res.message ?? "Failed");
        return;
      }
    } catch (_) {
      setState(() => _isFavorite = previous);
      EasyLoading.dismiss();
      EasyLoading.showError("Failed");
    } finally {
      _sending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlHelper.toFullUrl(widget.item.primaryImage?.imageUrl);

    final title = context.pick(ar: widget.item.nameAr, en: widget.item.nameEn);

    final price = widget.item.priceAfter > 0
        ? widget.item.priceAfter
        : widget.item.priceBefore;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: AppColor.black, // 🔥 نفس Menu
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
              PositionedDirectional(
                top: 6,
                end: 6,
                child: GestureDetector(
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
            height: 55.h, // 🔥 مكمل للـ 140.h
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
                Text(
                  context.syp(price),
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
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
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 28),
    );
  }
}

/// --------------------------------------------------------------
/// Placeholder widget
/// --------------------------------------------------------------
class MostPopular extends StatelessWidget {
  const MostPopular({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
