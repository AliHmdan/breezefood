import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RDHeaderSliver extends StatelessWidget {
  const RDHeaderSliver({
    super.key,
    required this.restaurantName,
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onBack,
    required this.onSearch,

    // ✅ NEW
    required this.innerBoxIsScrolled,
  });

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;

  final VoidCallback onBack;
  final VoidCallback onSearch;

  // ✅ NEW
  final bool innerBoxIsScrolled;

  static double get _overlap => 24.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: innerBoxIsScrolled ? AppColor.Dark : Colors.transparent,

      forceMaterialTransparency: !innerBoxIsScrolled,

      scrolledUnderElevation: 0,
      elevation: 0,

      expandedHeight: 180.h + _overlap.h,
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      collapsedHeight: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
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
