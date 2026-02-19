import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularGridPage extends StatelessWidget {
  final List<MenuItemModel> items;
  final int? restaurantId;
  final bool isRestaurantOpen; // ✅ جديد

  const PopularGridPage({
    super.key,
    required this.items,
    this.restaurantId,
    required this.isRestaurantOpen,
  });

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: CustomAppbarProfile(
          title: "most_popular".tr(),
          icon: Icons.arrow_back_ios,
          ontap: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(width), // ✅ استُخدمت
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

          return InkWell(
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
                restaurantId: resolvedRestaurantId,
                menuItemId: menuItemId,
                title: title,
                price: item.priceAfter > 0 ? item.priceAfter : item.priceBefore,
                oldPrice: item.priceBefore,
                imagePathOrUrl:
                    item.primaryImage?.imageUrl ??
                    "assets/images/shawarma_box.png",
                description: "",
                extraMeals: const <MenuExtra>[],
                isRestaurantOpen: isRestaurantOpen,
                extraGroups: <ExtraGrouped>[], // ✅
              );
            },
            child: PopularItemCard(
              item: item,
              isRestaurantOpen: isRestaurantOpen, // ✅
            ),
          );
        },
      ),
    );
  }
}
