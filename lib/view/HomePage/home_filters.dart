import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFilters extends StatefulWidget {
  final Function(String section) onFilterTap;

  const HomeFilters({super.key, required this.onFilterTap});

  @override
  State<HomeFilters> createState() => _HomeFiltersState();
}

class _HomeFiltersState extends State<HomeFilters> {
  String selectedFilter = "popular"; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    selectedFilter = "popular"; // إعادة ضبط الفلتر عند كل فتح للواجهة
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: SizedBox(
        height: 35.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          children: [
            _buildFilterButton("Moust Popular", "popular"),
            SizedBox(width: 10.w),
            _buildFilterButton("Closer to you", "closer"),
            SizedBox(width: 10.w),
            _buildFilterButton("Stores", "stores"),
            SizedBox(width: 10.w),
            _buildFilterButton("Discounts", "discounts"),
            SizedBox(width: 10.w),
            _buildFilterButton("Discounts Delivery", "delivery"),
            SizedBox(width: 10.w),
            _buildFilterButton("Super Market", "supermarket"),
            SizedBox(width: 10.w),
            _buildFilterButton("Open now", "open"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    bool isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });

        widget.onFilterTap(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColor.primaryColor : AppColor.black,
          // border: Border.all(color: AppColor.white, width: 1),
        ),
        child: CustomSubTitle(
          subtitle: label,
          color: isSelected ? AppColor.white : AppColor.LightActive,
          fontsize: 14.sp,
        ),
      ),
    );
  }
}
