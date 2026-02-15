import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OpenStatusBadge extends StatelessWidget {
  final bool isOpen;

  /// اختياري: تصغير/تكبير البادج حسب المكان
  final double? fontSize;
  final double? dotSize;
  final EdgeInsetsGeometry? padding;

  const OpenStatusBadge({
    super.key,
    required this.isOpen,
    this.fontSize,
    this.dotSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ألوان أنعم (UI/UX)
    final Color accent = isOpen
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    final String text = isOpen
        ? "restaurant.open".tr()
        : "restaurant.closed".tr();

    final double fs = fontSize ?? 11.sp;
    final double ds = dotSize ?? 7.5.sp;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            // ✅ خلفية شبه شفافة بتناسب فوق الصور
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: accent.withOpacity(0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Dot + glow بسيط
              Container(
                width: ds,
                height: ds,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.55),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),

              // ✅ نص واضح + وزن أنظف
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fs,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),

              // ✅ أيقونة صغيرة لطيفة (اختياري بس مضافة ك UX cue)
              SizedBox(width: 6.w),
              Icon(
                isOpen ? Icons.schedule_rounded : Icons.lock_clock_rounded,
                size: (fs + 2),
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
