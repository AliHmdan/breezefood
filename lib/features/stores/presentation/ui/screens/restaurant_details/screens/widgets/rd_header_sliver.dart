import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RDHeaderSliver extends StatelessWidget {
  const RDHeaderSliver({
    super.key,
    required this.headerImageUrl,
    required this.headerReady,
    required this.restaurantName,
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onBack,
    required this.onSearch,
    required this.onRateTap,
  });

  final String headerImageUrl;
  final bool headerReady;
  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;

  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onRateTap;
  static double get _overlap => 24.0; // ✅ قدّي الكارد يركب فوق الصورة
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.h + _overlap.h, // ✅ زودنا الهيدر
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      collapsedHeight: 0,
      backgroundColor: AppColor.Dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            headerReady
                ? AppNetworkImage(
                    path: headerImageUrl,
                    height: 180.h + _overlap.h, // ✅ نفس ارتفاع الهيدرس
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : SizedBox(
                    height: 180.h,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/images/meal_breeze.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xB3000000),
                        Color(0x66000000),
                        Color(0x00000000),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 12,
              start: 12,
              child: CustomArrow(
                color: AppColor.white,
                background: AppColor.black,
                colorborder: AppColor.grye,
                onTap: onBack,
              ),
            ),

            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 12,
              end: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            PositionedDirectional(
              bottom: 5 + _overlap,
              start: 10,
              end: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: context.isAr ? 'Cairo' : 'Inter',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onRateTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          avgRatingText,
                          style: TextStyle(
                            color: AppColor.Lightgry,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "($reviewsCountText)",
                          style: TextStyle(
                            color: AppColor.Lightgry.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(height: _overlap.h),
            ),
          ],
        ),
      ),
    );
  }
}
