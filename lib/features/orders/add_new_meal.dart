import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart'; // CustomTitleSection
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/search.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/orders/request_order.dart';
import 'package:breezefood/features/orders/request_order/horizontal_products_section.dart';
import 'package:breezefood/features/orders/request_order/tiem_price.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNewMeal extends StatefulWidget {
  /// ✅ عنصر واحد لإعادة الطلب (اختياري)
  final MenuItemModel? orderAgainItem;

  /// ✅ عناصر “Customer Favorite”
  final List<MenuItemModel> favoriteItems;

  const AddNewMeal({
    super.key,
    this.orderAgainItem,
    required this.favoriteItems,
  });

  @override
  State<AddNewMeal> createState() => _AddNewMealState();
}

class _AddNewMealState extends State<AddNewMeal> {
  final List<String> categories = const [
    "Beef",
    "Chicken",
    "Beverage",
    "Sides",
    "Desserts",
    "Salads",
  ];

  int selectedCategoryIndex = 0;
  void _openBottomSheetFromHomeItem(MenuItemModel item) {
    final restaurantId = item.restaurant?.id ?? 0;
    final menuItemId = item.id;

    if (restaurantId == 0 || menuItemId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن تحديد المطعم أو الوجبة")),
      );
      return;
    }

    showAddOrderDialog(
      context,
      restaurantId: restaurantId,
      menuItemId: menuItemId,
      title: item.nameAr,
      price: (item.priceAfter > 0 ? item.priceAfter : item.priceBefore),
      oldPrice: item.priceBefore,
      imagePathOrUrl:
          item.primaryImage?.imageUrl ?? "assets/images/shawarma_box.png",
      description: "",
      extraMeals: const <MenuExtra>[], // هون ما عندك extras من الهوم
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAgain = widget.orderAgainItem;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: Stack(
        children: [
          /// ================= HEADER IMAGE =================
          SizedBox(
            height: 240.h,
            width: double.infinity,
            child: Image.asset(
              "assets/images/shawarma_box.png",
              fit: BoxFit.cover,
            ),
          ),

          /// ================= BACK ARROW =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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

          /// ================= CONTENT =================
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

                  /// ---------------- Time & Delivery ----------------
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
                          title: "15-40",
                          subtitle: "min",
                        ),
                        TiemPrice(
                          title: "2.00",
                          subtitle: "\$",
                          svgPath: "assets/icons/motor.svg",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------------- Restaurant Name ----------------
                  const Center(
                    child: CustomTitle(
                      title: "Shawarma King",
                      color: AppColor.white,
                    ),
                  ),

                  const CustomSearch(hint: "Search"),
                  SizedBox(height: 8.h),

                  /// ---------------- Description + Rating ----------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSubTitle(
                            subtitle: "Lorem ipsum dolor amet consectetur.",
                            color: AppColor.gry,
                            fontsize: 8.sp,
                          ),
                        ),
                        _divider(),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        const Text(
                          "4.9",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        _divider(),
                        const Text(
                          "500+ Order",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  /// ---------------- Categories ----------------
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final bool isSelected =
                              selectedCategoryIndex == index;

                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedCategoryIndex = index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
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

                  /// ---------------- Order Again ----------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTitleSection(title: "Order again"),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: orderAgain == null
                          ? null
                          : () => _openBottomSheetFromHomeItem(orderAgain),
                      child: SizedBox(
                        height: 140.h,
                        width: 160.w,
                        child: orderAgain == null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "No item provided",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              )
                            : SearchPopularItemCard(
                                item: orderAgain,
                              ), // ✅ MenuItemModel card
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ---------------- Customer Favorite ----------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTitleSection(
                      title: "Customer Favorite",
                      all: "All",
                      icon: Icons.arrow_forward_ios_outlined,
                    ),
                  ),
                  const SizedBox(height: 5),

                  /// ✅ لازم نبعت items للـ HorizontalProductsSection
                  HorizontalProductsSection(items: widget.favoriteItems),
                ],
              ),
            ),
          ),
        ],
      ),

      /// ================= FIXED BOTTOM BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.Dark,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: CustomButton(
            title: "View Cart    5.00\$",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RequestOrder()),
              );
            },
          ),
        ),
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
