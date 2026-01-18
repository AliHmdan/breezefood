import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';

Future<void> openDiscountItemFlow(
  BuildContext context,
  MenuItemModel item,
) async {
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

// *************************************************************
// 🧱 البيانات الوهمية (Mock Data) لتحل محل بيانات الـ Cubit
// *************************************************************
class DiscountGridPage extends StatelessWidget {
  final List<MenuItemModel> items;

  const DiscountGridPage({super.key, required this.items});

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
            title: "Discount",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 1.3,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final it = items[index];

                  return Discount(
                    imagePath:
                        UrlHelper.toFullUrl(it.primaryImage?.imageUrl) ?? "",
                    subtitle: it.restaurant?.name ?? "Restaurant",
                    price: "${it.priceAfter.toStringAsFixed(0)} ل.س",
                    discount: (it.discountValue ?? 0).toStringAsFixed(0),
                    onFavoriteToggle: () {},
                    onTap: () {
                      openDiscountItemFlow(context, it); // ✅ هون صار صح
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
