import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealCard extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  final Widget? counter; // ✅ بدل showCounter/qty

  const MealCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 1, right: 10),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: _MealImage(image: image),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSubTitle(
                  subtitle: name,
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
                const SizedBox(height: 4),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Price : ",
                        style: TextStyle(color: AppColor.gry, fontSize: 14.sp),
                      ),
                      TextSpan(
                        text: "${price.toStringAsFixed(0)}\$ ",
                        style: TextStyle(
                          color: AppColor.yellow,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ العداد من برا
          if (counter != null) ...[
            const SizedBox(width: 10),
            counter!,
          ],
        ],
      ),
    );
  }
}

class _MealImage extends StatelessWidget {
  final String image;
  const _MealImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final raw = image.trim();
    final fullUrl = UrlHelper.toFullUrl(raw);

    if (fullUrl != null) {
      return Image.network(
        fullUrl,
        width: 100.w,
        height: 105.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final asset = raw.isNotEmpty ? raw : "assets/images/shawarma_box.png";
    return Image.asset(
      asset,
      width: 100.w,
      height: 105.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      "assets/images/shawarma_box.png",
      width: 100.w,
      height: 105.h,
      fit: BoxFit.cover,
    );
  }
}
