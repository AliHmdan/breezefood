import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/reviews/presentation/rate_dialog.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';

import 'package:breezefood/features/reviews/presentation/cubit/rating_submit_cubit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/di/di.dart'; // إذا عندك Dio في getIt

class Supermarketslider extends StatelessWidget {
  final List<RestaurantModel> restaurants;
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
        height: 160.h,
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
  final RestaurantModel model;
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

    // لو deliveryTime موجودة نعرضها، وإلا نخليها نص افتراضي
    final deliveryText = widget.model.deliveryTime != null
        ? "${widget.model.deliveryTime} min"
        : "—";

    return InkWell(
      borderRadius: BorderRadius.circular(11.r),
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: Stack(
          children: [
            // ✅ صورة حقيقية Network
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
                      loadingBuilder: (c, child, p) {
                        if (p == null) return child;
                        return Container(
                          color: Colors.black.withOpacity(0.15),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // ✅ شفافية على كامل الصورة
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
            // Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Title (نفس التصميم)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  widget.model.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Rating chip (يعرض avg_rating دائمًا + عند الضغط يرسل تقييم)
            PositionedDirectional(
              end: 12,
              top: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {},

                child: _InfoChip(
                  icon: Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  text: (widget.model.ratingAvg).toStringAsFixed(1),
                ),
              ),
            ),
          ],
        ),
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
