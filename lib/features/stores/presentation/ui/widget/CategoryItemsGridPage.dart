import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
// import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryItemsGridPage extends StatefulWidget {
  final int restaurant_id;
  final int? initialMenuItemId;
  final String title;
  final List<MenuItem> items;
  final bool isRestaurantOpen; // ✅ جديد

  const CategoryItemsGridPage({
    super.key,
    required this.restaurant_id,
    required this.title,
    required this.items,
    required this.isRestaurantOpen, // ✅
    this.initialMenuItemId,
  });

  @override
  State<CategoryItemsGridPage> createState() => _CategoryItemsGridPageState();
}

class _CategoryItemsGridPageState extends State<CategoryItemsGridPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: CustomAppbarProfile(
          title: widget.title,
          icon: Icons.arrow_back_ios,
          ontap: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final it = widget.items[index];

          final imageUrl = UrlHelper.toFullUrl(it.image ?? "") ?? "";

          return GestureDetector(
            onTap: () async {
              await showAddOrderDialog(
                
                context,
                restaurantId: widget.restaurant_id,
                menuItemId: it.id,
                title: context.pick(ar: it.nameAr, en: it.nameEn),
                price: it.effectivePrice,
                oldPrice: it.priceBefore > 0 ? it.priceBefore : it.price,
                imagePathOrUrl: imageUrl.isNotEmpty
                    ? imageUrl
                    : "assets/images/shawarma_box.png",
                description: context.pick(
                  ar: it.descriptionAr ?? "",
                  en: it.descriptionEn ?? "",
                ),
                extraMeals: it.mealExtras,
                isRestaurantOpen: widget.isRestaurantOpen, extraGroups: it.extrasGrouped,  
              );

              if (mounted) {
                context.read<CartCubit>().loadCart();
              }
            },
            child: PopularItemCard(
              item: MenuItemModel(
                id: it.id,
                nameAr: it.nameAr,
                nameEn: it.nameEn,
                priceBefore: it.priceBefore > 0 ? it.priceBefore : it.price,
                priceAfter: it.effectivePrice,
                hasDiscount: it.hasDiscount,
                discountType: it.discountType,
                discountValue: it.discountPercent,
                isFavorite: it.isFavorite,
                primaryImage: imageUrl.isNotEmpty
                    ? PrimaryImageModel(imageUrl: imageUrl)
                    : null,
                restaurant: null,
              ),
              isRestaurantOpen: widget.isRestaurantOpen,  
            ),
          );
        },
      ),
    );
  }
}
