import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart'; // MenuItemModel
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart'; // PopularItemCard (MenuItemModel)
import 'package:breezefood/features/orders/add_order.dart'; // showAddOrderDialog
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart'; // MenuExtra (الموحد)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularGridPage extends StatelessWidget {
  final List<MenuItemModel> items; // ✅ صار MenuItemModel
  final int? restaurantId; // ✅ جديد اختياري

  const PopularGridPage({super.key, required this.items, this.restaurantId});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Most popular",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: items.isEmpty
              ? Center(
                  child: Text(
                    "No popular items found",
                    style: TextStyle(color: AppColor.white),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _getCrossAxisCount(
                      constraints.maxWidth,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColor.LightActive,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 5.h,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          final title = item.nameAr.isNotEmpty
                              ? item.nameAr
                              : item.nameEn;

                          return InkWell(
                            onTap: () {
                              final menuItemId = item.id;
                              final resolvedRestaurantId =
                                  restaurantId ?? (item.restaurant?.id ?? 0);

                              if (resolvedRestaurantId == 0 ||
                                  menuItemId == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "لا يمكن تحديد المطعم أو الوجبة",
                                    ),
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

                            child: PopularItemCard(
                              item: item,
                            ), // ✅ MenuItemModel
                          );
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
