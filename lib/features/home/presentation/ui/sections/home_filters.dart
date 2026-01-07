import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFilters extends StatefulWidget {
  final Function(String section) onFilterTap;

  const HomeFilters({super.key, required this.onFilterTap});

  @override
  State<HomeFilters> createState() => _HomeFiltersState();
}

class _HomeFiltersState extends State<HomeFilters> {
  String selectedFilter = "popular";

  @override
  void initState() {
    super.initState();
    selectedFilter = "popular";
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
            _buildFilterButton("home.filters.closer".tr(), "closer"),
            SizedBox(width: 10.w),
            _buildFilterButton("home.filters.stores".tr(), "stores"),
            SizedBox(width: 10.w),
            _buildFilterButton("home.filters.discounts".tr(), "discounts"),
            SizedBox(width: 10.w),
            _buildFilterButton("home.filters.delivery".tr(), "delivery"),
            SizedBox(width: 10.w),
            _buildFilterButton("home.filters.supermarket".tr(), "supermarket"),
            SizedBox(width: 10.w),
            _buildFilterButton("home.filters.open".tr(), "open"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = value);
        widget.onFilterTap(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColor.primaryColor : AppColor.black,
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
