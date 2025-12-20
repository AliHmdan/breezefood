import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/request_order/counter.dart';
import 'package:breezefood/view/orders/request_order/custom_add.dart';
import 'package:breezefood/view/orders/request_order/custom_hot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


// =====================================================
// Show Bottom Sheet (¾ Screen - From Bottom)
// =====================================================
Future<void> showAddOrderDialog(
    BuildContext context, {
      required String title,
      required String price,
      required String oldPrice,
      required String imagePath,
    }) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r),
      ),
    ),
    builder: (_) {
      final height = MediaQuery.of(context).size.height * 0.75;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColor.Dark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.r),
            ),
          ),
          child: AddOrderBody(
            title: title,
            price: price,
            oldPrice: oldPrice,
            imagePath: imagePath,
          ),
        ),
      );
    },
  );
}

// =====================================================
// Bottom Sheet Body
// =====================================================
class AddOrderBody extends StatefulWidget {
  final String title;
  final String price;
  final String imagePath;
  final String oldPrice;

  const AddOrderBody({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.oldPrice,
  });

  @override
  State<AddOrderBody> createState() => _AddOrderBodyState();
}

class _AddOrderBodyState extends State<AddOrderBody> {
  final List<String> sizes = ["S", "L"];
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ================= Drag Handle =================
        SizedBox(height: 10.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 8.h),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // ================= Image =================
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                      child: Image.asset(
                        widget.imagePath,
                        width: double.infinity,
                        height: 220.h,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Close Button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: ButtonStyle(
                          backgroundColor:
                          WidgetStateProperty.all(Colors.black54),
                        ),
                      ),
                    ),

                    // Share Button
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColor.white,
                        child: SvgPicture.asset(
                          "assets/icons/share.svg",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= Title & Price =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomSubTitle(
                              subtitle: widget.title,
                              color: AppColor.white,
                              fontsize: 16.sp,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.oldPrice,
                                style: TextStyle(
                                  color: AppColor.red,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                widget.price,
                                style: TextStyle(
                                  color: AppColor.yellow,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      CustomSubTitle(
                        subtitle:
                        "Lorem ipsum dolor sit amet Et diam mauris",
                        color: AppColor.gry,
                        fontsize: 10.sp,
                      ),

                      // ================= Divider =================
                      divider(),

                      // ================= Sizes =================
                      Row(
                        children: sizes.map((size) {
                          final isSelected = selectedSize == size;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedSize = size),
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: isSelected
                                    ? AppColor.primaryColor
                                    : AppColor.white,
                                child: CustomSubTitle(
                                  subtitle: size,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColor.Dark,
                                  fontsize: 16.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 8.h),

                      // ================= Add =================
                      CustomSubTitle(
                        subtitle: "Add a?",
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      const CustomAdd(),

                      divider(),

                      // ================= Hot =================
                      CustomSubTitle(
                        subtitle: "Hot?",
                        color: AppColor.white,
                        fontsize: 16.sp,
                      ),
                      const CustomHot(),

                      divider(height: 20),

                      const Counter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget divider({double height = 40}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Divider(
        color: AppColor.gry,
        thickness: 1.2,
        height: height,
      ),
    );
  }
}
