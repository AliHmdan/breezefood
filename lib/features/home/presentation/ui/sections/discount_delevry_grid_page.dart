import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount_delevry.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
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
    // ✅ فقط العناصر اللي عليها خصم فعلياً
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 1,
                childAspectRatio: 1.5,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                return DiscountDelevry(
                  imagePath: _imageUrl(item),
                  title: _title(item),
                  oldPrice: item.priceBefore.toString(),
                  newPrice: item.priceAfter.toString(),
                  onTap: () {},
                  onFavoriteToggle: () {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}
