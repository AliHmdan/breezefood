import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import 'package:breezefood/core/component/color.dart';

class AppShareFab extends StatelessWidget {
  final String text;            // النص اللي بدك تشاركه
  final String? subject;        // عنوان (اختياري)
  final Rect? sharePosition;    // مهم للـ iPad
  final double radius;
  final EdgeInsets padding;
  final String iconAsset;

  const AppShareFab({
    super.key,
    required this.text,
    this.subject,
    this.sharePosition,
    this.radius = 20,
    this.padding = const EdgeInsets.all(0),
    this.iconAsset = "assets/icons/share.svg",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () async {
          final box = context.findRenderObject() as RenderBox?;
          final pos = sharePosition ??
              (box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null);

          await Share.share(
            text,
            subject: subject,
            sharePositionOrigin: pos,
          );
        },
        child: CircleAvatar(
          radius: radius.r,
          backgroundColor: AppColor.white,
          child: SvgPicture.asset(
            iconAsset,
            width: 25.w,
            height: 25.h,
          ),
        ),
      ),
    );
  }
}
