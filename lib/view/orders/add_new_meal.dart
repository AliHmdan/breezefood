import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:breezefood/view/HomePage/widgets/custom_search.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/HomePage/widgets/custom_title.dart';
import 'package:breezefood/view/orders/add_order.dart';
import 'package:breezefood/view/orders/request_order.dart';
import 'package:breezefood/view/orders/request_order/horizontal_products_section.dart';
import 'package:breezefood/view/orders/request_order/tiem_price.dart';
import 'package:breezefood/view/profile/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNewMeal extends StatefulWidget {
  const AddNewMeal({super.key});

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

  @override
  Widget build(BuildContext context) {
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
              onTap: (){
                Navigator.pop(context);
              },
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSubTitle(
                            subtitle:
                            "Lorem ipsum dolor amet consectetur.",
                            color: AppColor.gry,
                            fontsize: 8.sp,
                          ),
                        ),
                        _divider(),
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        const Text(
                          "4.9",
                          style:
                          TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        _divider(),
                        const Text(
                          "500+ Order",
                          style:
                          TextStyle(color: Colors.white, fontSize: 12),
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
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 6.h),
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
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        showAddOrderDialog(
                          context,
                          title: "Chicken",
                          price: "5.00\$",
                          oldPrice: "5.00\$",
                          imagePath: "assets/images/004.jpg",
                        );
                      },
                      child: SizedBox(
                        height: 140.h,
                        width: 160.w,
                        child: PopularItemCard(
                          isFavorite: false,
                          imagePath: "assets/images/004.jpg",
                          title: "Chicken",
                          price: "5.00\$",
                          oldPrice: "5.00\$",
                          onFavoriteToggle: () {},
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  const MostPopular(),
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTitleSection(
                      title: "Customer Favorite",
                      all: "All",
                      icon: Icons.arrow_forward_ios_outlined,
                    ),
                  ),

                  SizedBox(height: 5),
                  const HorizontalProductsSection(),
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
