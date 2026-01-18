import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// --------------------------------------------------------------
/// Section: Discount Meal (UI ONLY)
/// بدون أي ربط باك
/// --------------------------------------------------------------
class DiscountMealSection extends StatelessWidget {
  const DiscountMealSection({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = 8.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    /// عدد العناصر الوهمية
    const int count = 4;

    return Column(
      children: [
        /// ===== TITLE =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomTitleSection(
            title: "Discount Meal",
            // all: "All",
            // icon: Icons.arrow_forward_ios_outlined,
            // ontap: () {
            //   // TODO: navigation later
            // },
          ),
        ),

        const SizedBox(height: 10),

        /// ===== LIST =====
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  margin: EdgeInsetsDirectional.only(
                    end: index == count - 1 ? 0 : gap,
                  ),

                  /// 🔥 كرت وهمي
                  child: const _DiscountDummyCard(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
// ========================================_DiscountDummyCard ===============================
class _DiscountDummyCard extends StatelessWidget {
  const _DiscountDummyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: AppColor.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Stack(
            children: [
              Container(
                height: 85.h,
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.fastfood,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              /// ❤️ fake favorite
              const PositionedDirectional(
                top: 6,
                end: 6,
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          /// TEXT
          Container(
            height: 55.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discount Meal",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
                CustomSubTitle(subtitle:  "9,999 SP", color: AppColor.white, fontsize: 12.sp)

              ],
            ),
          ),
        ],
      ),
    );
  }
}
