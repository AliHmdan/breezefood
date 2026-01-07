import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestaurantCard extends StatefulWidget {
  final RestaurantModel restaurant;
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
    _rating = (widget.restaurant.ratingAvg ?? 0).toDouble();
  }

  @override
  void didUpdateWidget(covariant RestaurantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant.id != widget.restaurant.id ||
        oldWidget.restaurant.ratingAvg != widget.restaurant.ratingAvg) {
      _rating = (widget.restaurant.ratingAvg ?? 0).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    final cover = UrlHelper.toFullUrl(r.coverImage);
    final logo = UrlHelper.toFullUrl(r.logo);
    final imageUrl = (cover ?? "").trim().isNotEmpty ? cover : logo;

    final ratingCount = (r.ratingCount ?? 0);
    final ordersText = ratingCount > 0 ? "$ratingCount Ratings" : "New";

    final deliveryTime = (r.deliveryTime ?? 0);
    final timeText = deliveryTime > 0 ? "$deliveryTime min" : "--";

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: Stack(
          children: [
            // Background image
            _NetImage(url: imageUrl, height: 112.h),

            // overlay
            Container(
              height: 112.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ⭐ Rating
                        GestureDetector(
                          onTap: () async {
                            final result = await showRatingDialog(
                              context,
                              _rating,
                            );
                            if (result != null) {
                              setState(() => _rating = result);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
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
                        ),

                        // ⏱ delivery time
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 4.w),
                              Text(
                                timeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Text
                    Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: Column(
                        children: [
                          Text(
                            (r.name ?? "Restaurant").trim(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// Open Now List (REAL DATA)
//////////////////////////////////////////////////////////////

class OpenNow extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final void Function(RestaurantModel r)? onTap;

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

//////////////////////////////////////////////////////////////
// Net Image helper
//////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////
// Rating Dialog (same as yours)
//////////////////////////////////////////////////////////////

Future<double?> showRatingDialog(BuildContext context, double currentRating) {
  double selectedRating = currentRating;

  return showDialog<double>(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "What is your rate?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Please share your rate about the restaurant",
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              RatingBar.builder(
                initialRating: currentRating,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32.sp,
                unratedColor: Colors.white30,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => selectedRating = rating,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.pop(context, selectedRating),
                child: CustomSubTitle(
                  subtitle: "Submit",
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
