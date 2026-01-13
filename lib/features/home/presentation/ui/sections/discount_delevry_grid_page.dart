import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount_delevry.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount_on_delivery.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountDelevryGridPageGridPage extends StatelessWidget {
  final List<MenuItemModel> discounts; // ✅ real data

  const DiscountDelevryGridPageGridPage({super.key, required this.discounts});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  String _imageUrl(MenuItemModel it) {
    final path = it.primaryImage?.imageUrl;
    return UrlHelper.toFullUrl(path) ?? "";
  }

  String _title(MenuItemModel it) {
    // لو بدك حسب اللغة لاحقاً
    return it.nameAr.isNotEmpty ? it.nameAr : it.nameEn;
  }

  String _restaurantName(MenuItemModel it) {
    return (it.restaurant?.name.isNotEmpty == true)
        ? it.restaurant!.name
        : "Restaurant";
  }

  @override
  Widget build(BuildContext context) {
    final list = discounts.where((e) => e.hasDiscount).toList();

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Discount Delevery",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            if (list.isEmpty) {
              return Center(
                child: Text(
                  "No delivery discounts available",
                  style: TextStyle(color: AppColor.white, fontSize: 14.sp),
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.only(bottom: 16.h),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.78, // ✅ شكل كرت أحسن من 1.5
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return DiscountPriceCard(
                  imageUrl: _imageUrl(item),
                  title: _title(item),
                  oldPrice: item.priceBefore.toStringAsFixed(0),
                  newPrice: item.priceAfter.toStringAsFixed(0),
                  initialIsFavorite: item.isFavorite,
                  onFavoriteToggle: () {},
                  onTap: () => openDiscountFlow(context, item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DiscountDelevryCard extends StatelessWidget {
  final MenuItemModel item;
  final String imageUrl;
  final String title;
  final String restaurantName;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const DiscountDelevryCard({
    super.key,
    required this.item,
    required this.imageUrl,
    required this.title,
    required this.restaurantName,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final oldP = item.priceBefore;
    final newP = item.priceAfter;

    final hasOld = oldP != null && oldP > 0;
    final hasNew = newP != null && newP > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: imageUrl.isEmpty
                    ? Image.asset(
                        "assets/images/shawarma_box.png",
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          "assets/images/shawarma_box.png",
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            // BODY
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Restaurant name
                    Text(
                      restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    ),

                    const Spacer(),

                    // Prices row
                    Row(
                      children: [
                        if (hasOld)
                          Text(
                            context.syp(oldP!.toString()),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (hasOld) SizedBox(width: 6.w),
                        if (hasNew)
                          Text(
                            context.syp(newP!.toString()),
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        const Spacer(),

                        // Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColor.primaryColor.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            "اطلب",
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Discount badge top-left (اختياري)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Text(
                      "خصم توصيل",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openDiscountFlow(BuildContext context, MenuItemModel item) async {
  final restaurantId = item.restaurant?.id ?? 0;
  final menuItemId = item.id ?? 0;

  if (restaurantId == 0 || menuItemId == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("لا يمكن تحديد الوجبة أو المطعم")),
    );
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResturantDetails(
        restaurant_id: restaurantId,
        initialMenuItemId: menuItemId, // ✅ أهم سطر
      ),
    ),
  );
}
