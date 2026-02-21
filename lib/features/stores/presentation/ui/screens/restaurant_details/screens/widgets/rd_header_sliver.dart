import 'dart:ui';
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
    required this.innerBoxIsScrolled,
  });

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;

  final VoidCallback onBack;
  final VoidCallback onSearch;

  final bool innerBoxIsScrolled;

  static double get _overlap => 24.0;
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      backgroundColor: innerBoxIsScrolled ? AppColor.Dark : Colors.transparent,
      forceMaterialTransparency: !innerBoxIsScrolled,
      surfaceTintColor: Colors.transparent,
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
            // ✅ لما يصير scroll: طبقة دارك ناعمة فوق الصورة (بتخلي كلشي واضح)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              opacity: innerBoxIsScrolled ? 1.0 : 0.0,
              child: Container(color: AppColor.Dark.withOpacity(0.72)),
            ),

            PositionedDirectional(
              top: topPad + 12,
              start: 12,
              child: _GlassCircleButton(
                onTap: onBack,
                child: CustomArrow(
                  color: AppColor.white,
                  background: Colors.transparent,
                  colorborder: Colors.transparent,
                  onTap: onBack,
                ),
              ),
            ),

            PositionedDirectional(
              top: topPad + 12,
              end: 12,
              child: _GlassCircleButton(
                onTap: onSearch,
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ),

            PositionedDirectional(
              bottom: 8 + _overlap,
              start: 12,
              end: 12,
              child: _TitleBlock(
                restaurantName: restaurantName,
                avgRatingText: avgRatingText,
                reviewsCountText: reviewsCountText,
              ),
            ),

            // overlap spacer
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

/// ======= UI helpers =======

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.restaurantName,
    required this.avgRatingText,
    required this.reviewsCountText,
  });

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;

  @override
  Widget build(BuildContext context) {
    final font = context.isAr ? 'Cairo' : 'Inter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurantName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            height: 1.05,
            fontWeight: FontWeight.w900,
            fontFamily: font,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.65),
                offset: const Offset(0, 3),
                blurRadius: 14,
              ),
              Shadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                shape: BoxShape.circle,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
