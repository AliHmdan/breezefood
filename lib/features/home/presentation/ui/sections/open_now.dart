import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart'
    show deliveryFeeText;
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/features/home/model/home_response.dart' as home;
import 'package:flutter_svg/flutter_svg.dart';

class RestaurantCard extends StatefulWidget {
  final home.HomeRestaurantModel restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = (widget.restaurant.ratingAvg).toDouble();
  }

  @override
  void didUpdateWidget(covariant RestaurantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant.id != widget.restaurant.id ||
        oldWidget.restaurant.ratingAvg != widget.restaurant.ratingAvg) {
      _rating = (widget.restaurant.ratingAvg).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    final cover = UrlHelper.toFullUrl(r.coverImage);
    final logo = UrlHelper.toFullUrl(r.logo);
    final imageUrl = (cover ?? "").trim().isNotEmpty ? cover : logo;

    final ratingCount = r.ratingCount;
    final ordersText = ratingCount > 0 ? "$ratingCount Ratings" : "New";

    // ✅ سعر التوصيل (من helper اللي عملناه)
    final feeText = deliveryFeeText(r);

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  _NetImage(url: imageUrl, height: 180.h),

                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ⭐ Rating
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    const Text(
                                      "|",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                    SizedBox(width: 6.w),
                                    CustomSubTitle(
                                      subtitle: ordersText,
                                      color: AppColor.white,
                                      fontsize: 12.sp,
                                    ),
                                  ],
                                ),
                              ),

                              // 🚚 delivery fee chip
                              // Container(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 8.w,
                              //     vertical: 2.h,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: Colors.black.withOpacity(0.25),
                              //     borderRadius: BorderRadius.circular(20.r),
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       CustomSubTitle(subtitle:  feeText, color: AppColor.white, fontsize: 12),
                              //       SizedBox(width: 4.w),
                              //       SvgPicture.asset(
                              //         color: Colors.white,
                              //         "assets/icons/motor.svg",
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          const Spacer(),
                          //Name Resturant
                          // Center(
                          //   child:
                          //   Text(
                          //     (r.name).trim(),
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 15.sp,
                          //       fontWeight: FontWeight.bold,
                          //    fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                          //         ? 'Cairo'
                          //         : 'Inter',
                          //       shadows: [
                          //         Shadow(
                          //           blurRadius: 8,
                          //           color: Colors.black.withOpacity(0.7),
                          //         ),
                          //
                          //       ],
                          //     ),
                          //     textAlign: TextAlign.center,
                          //     maxLines: 2,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h,),
            CustomSubTitle(subtitle: (r.name).trim(), color: AppColor.white, fontsize: 16.sp),
            // Text(
            //   (r.name).trim(),
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 15.sp,
            //     fontWeight: FontWeight.bold,
            //     fontFamily: Localizations.localeOf(context).languageCode == 'ar'
            //         ? 'Cairo'
            //         : 'Inter',
            //     shadows: [
            //       Shadow(
            //         blurRadius: 8,
            //         color: Colors.black.withOpacity(0.7),
            //       ),
            //
            //     ],
            //   ),
            //   // textAlign: TextAlign.center,
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            // ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  CustomSubTitle(subtitle:  feeText, color: AppColor.white, fontsize: 12),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    color: Colors.white,
                    "assets/icons/motor.svg",
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h,),
          ],
        ),
      ),
    );
  }
}

class OpenNow extends StatelessWidget {
  final List<home.HomeRestaurantModel> restaurants;
  final void Function(home.HomeRestaurantModel r)? onTap;

  const OpenNow({super.key, required this.restaurants, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Center(
          child: Text(
            "No restaurants available",
            style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = restaurants[index];
        return RestaurantCard(
          restaurant: r,
          onTap: onTap == null ? null : () => onTap!(r),
        );
      },
    );
  }
}

class _NetImage extends StatelessWidget {
  final String? url;
  final double height;
  final bool grayscale;

  const _NetImage({
    required this.url,
    required this.height,
    this.grayscale = false,
  });

  @override
  Widget build(BuildContext context) {
    final u = (url ?? "").trim();

    Widget child;
    if (u.isEmpty) {
      child = Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.restaurant, color: AppColor.white, size: 40.sp),
        ),
      );
    } else {
      child = Image.network(
        u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            color: Colors.black.withOpacity(0.2),
            alignment: Alignment.center,
            child: SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade800,
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: AppColor.white,
              size: 34.sp,
            ),
          ),
        ),
      );
    }

    if (!grayscale) return child;

    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: child,
    );
  }
}
