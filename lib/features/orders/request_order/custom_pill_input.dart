import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPillInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double? width;
  final double height;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const CustomPillInput({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.width,
    this.height = 40, // ارتفاع صغير مثل الصورة
    this.textInputAction,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final baseFill = const Color(0xFFE6E6E6); // رمادي فاتح مثل الصورة
    final hintClr  = const Color(0xFF8E8E8E); // رمادي أغمق قليلًا للنص

    return SizedBox(
      width: width ?? 120.w,           // عرض افتراضي مناسب للكبسولة
      height: height.h,                // ارتفاع صغير
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction ?? TextInputAction.next,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        maxLines: 1,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColor.LightActive,
          height: 1.2,
          fontFamily: "Manrope"
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.sp, color: hintClr),
          filled: true,
          fillColor: baseFill,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          // كبسولة بالكامل:
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: baseFill, width: 0), // بدون إطار واضح عند التركيز
          ),
        ),
      ),
    );
  }
}
