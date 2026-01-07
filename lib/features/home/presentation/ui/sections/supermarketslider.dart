import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Supermarketslider extends StatelessWidget {
  final List<RestaurantModel> restaurants;

  const Supermarketslider({
    super.key,
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 120.h,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index, _) {
        return _SliderItemWidget(model: restaurants[index]);
      },
    );
  }
}

class _SliderItemWidget extends StatefulWidget {
  final RestaurantModel model;

  const _SliderItemWidget({required this.model});

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
    final imageUrl = UrlHelper.toFullUrl(widget.model.coverImage) ??
        UrlHelper.toFullUrl(widget.model.logo) ??
        "";

    // لو deliveryTime موجودة نعرضها، وإلا نخليها نص افتراضي
    final deliveryText = widget.model.deliveryTime != null
        ? "${widget.model.deliveryTime} min"
        : "—";

    return ClipRRect(
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
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white70),
                    ),
                    loadingBuilder: (c, child, p) {
                      if (p == null) return child;
                      return Container(
                        color: Colors.black.withOpacity(0.15),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
          ),

          // Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
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

          // Delivery chip (نفس الشكل)
          Positioned(
            left: 12,
            top: 12,
            child: _InfoChip(
              icon: SvgPicture.asset(
                "assets/icons/motor.svg",
                color: AppColor.white,
                width: 22.w,
                height: 22.w,
              ),
              text: deliveryText,
            ),
          ),

          // Rating chip (قابل للتعديل بنفس الديالوج)
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () async {
                final result = await showRatingDialog(context, _rating);
                if (result != null) setState(() => _rating = result);
              },
              child: _InfoChip(
                icon: Icon(Icons.star, color: Colors.amber, size: 16.sp),
                text: _rating.toStringAsFixed(1),
              ),
            ),
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
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      );
    },
  );
}
