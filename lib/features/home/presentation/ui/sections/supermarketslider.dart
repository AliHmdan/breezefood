import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
 
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:flutter_svg/flutter_svg.dart'; // إذا عندك Dio في getIt

class Supermarketslider extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final void Function(dynamic r)? onTap;

  // ✅ جديد
  final VoidCallback? onRateSuccess;

  const Supermarketslider({
    super.key,
    required this.restaurants,
    this.onTap,
    this.onRateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 235.h,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index, _) {
        final m = restaurants[index];
        return _SliderItemWidget(
          model: m,
          onTap: onTap == null ? null : () => onTap!(m),
          onRateSuccess: onRateSuccess,
        );
      },
    );
  }
}

class _SliderItemWidget extends StatefulWidget {
  final HomeRestaurantModel model;
  final VoidCallback? onTap;

  // ✅ جديد
  final VoidCallback? onRateSuccess;

  const _SliderItemWidget({
    required this.model,
    this.onTap,
    this.onRateSuccess,
  });

  @override
  State<_SliderItemWidget> createState() => _SliderItemWidgetState();
}

class _SliderItemWidgetState extends State<_SliderItemWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.model.ratingAvg;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        UrlHelper.toFullUrl(widget.model.coverImage) ??
        UrlHelper.toFullUrl(widget.model.logo) ??
        "";

    final feeText = deliveryFeeText(widget.model);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: widget.onTap,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 الصورة مع الـ Stack
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 145.h, // حدد ارتفاع واضح للصورة
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl.isEmpty
                        ? Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.store, color: Colors.white70),
                    )
                        : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  // // 💰 Delivery chip
                  // PositionedDirectional(
                  //   start: 12,
                  //   top: 12,
                  //   child:
                  //   _InfoChip(
                  //     icon: SvgPicture.asset(
                  //       "assets/icons/motor.svg",
                  //       color: Colors.white,
                  //     ),
                  //     text: feeText,
                  //   ),
                  // ),

                  // ⭐ Rating chip
                  PositionedDirectional(
                    end: 12,
                    top: 12,
                    child: _InfoChip(
                      icon: Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      text: (widget.model.ratingAvg).toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // ✅ الاسم تحت الصورة
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              widget.model.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _InfoChip(
            icon: SvgPicture.asset(
              "assets/icons/motor.svg",
              color: Colors.white,
            ),
            text: feeText,
          ),
        ],
      ),

    );
  }
}

class _InfoChip extends StatelessWidget {
  final Widget icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: 4.w),
          CustomSubTitle(
            subtitle: text,
            color: AppColor.white,
            fontsize: 12.sp,
          ),
        ],
      ),
    );
  }
}

Future<bool> submitRestaurantRating({
  required int restaurantId,
  required double rating,
}) async {
  try {
    final dio = getIt<Dio>(); // أو استخدم dio اللي عندك بالمشروع

    final res = await dio.post(
      "https://breezefood.cloud/api/reviews",
      data: {
        "reviewee_type": "restaurant",
        "reviewee_id": restaurantId,
        "rating": rating,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          // لا تكتب Authorization هون إذا interceptor موجود
        },
      ),
    );

    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}
