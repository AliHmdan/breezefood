import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountGridPage extends StatelessWidget {
  final List<MenuItem> items;
  final String Function(String raw) fullImageUrl;
  final void Function(MenuItem it) onTap;

  const DiscountGridPage({
    super.key,
    required this.items,
    required this.fullImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: CustomAppbarProfile(
          title: "Discount",
          icon: Icons.arrow_back_ios,
          ontap: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final it = items[index];
          return GestureDetector(
            onTap: () => onTap(it),
            child: DiscountItemCard(
              item: it,
              imageUrl: fullImageUrl(it.image ?? ""),

            ),
          );
        },
      ),
    );
  }
}

 
