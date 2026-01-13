import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalProductsSection extends StatelessWidget {
  final List<MenuItemModel> items;
  final int? restaurantId; // ✅ جديد (اختياري)

  const HorizontalProductsSection({
    super.key,
    required this.items,
    this.restaurantId,
  });
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 140.h,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        physics: items.length <= 2
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: isRTL ? 0 : 16.w,
          right: isRTL ? 16.w : 0,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

          return Container(
            width: 160.w,
            margin: EdgeInsets.only(
              right: !isRTL && index != items.length - 1 ? 10.w : 0,
              left: isRTL && index != items.length - 1 ? 10.w : 0,
            ),
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

              child: Search(
              ), // ✅ Card بتقبل MenuItemModel
            ),
          );
        },
      ),
    );
  }
}
