import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/share_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderHeaderImage extends StatelessWidget {
  final String imagePathOrUrl;
  final String shareText;
  final VoidCallback onClose;

  const AddOrderHeaderImage({
    super.key,
    required this.imagePathOrUrl,
    required this.shareText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: AppNetworkImage(
            path: imagePathOrUrl,
            width: double.infinity,
            height: 400.h,
            fit: BoxFit.cover,
          ),
        ),

        PositionedDirectional(
          top: 5,
          end: 1,
          child: IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black54),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              minimumSize: WidgetStateProperty.all(const Size(30, 30)),
              fixedSize: WidgetStateProperty.all(const Size(30, 30)),
            ),
          ),
        ),

        PositionedDirectional(
          bottom: 5,
          end: 10,
          child: AppShareFab(
            text: shareText,
            subject: "BreezeFood",
          ),
        ),
      ],
    );
  }
}