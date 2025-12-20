import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../component/color.dart';


class Supermarketslider extends StatelessWidget {
  const Supermarketslider({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_SliderItem> items = [
      _SliderItem(
        image: 'assets/images/004.jpg',
        title: 'Pizza House',
        rating: 4.5,
        deliveryPrice: '500\$',
      ),
      _SliderItem(
        image: 'assets/images/004.jpg',
        title: 'Burger King',
        rating: 4.2,
        deliveryPrice: '3000\$',
      ),
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 120.h,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: items.map((item) {
        return _SliderItemWidget(item: item);
      }).toList(),
    );
  }
}

/* ============================================================ */
/* Model */
class _SliderItem {
  final String image;
  final String title;
  final double rating;
  final String deliveryPrice;

  _SliderItem({
    required this.image,
    required this.title,
    required this.rating,
    required this.deliveryPrice,
  });
}

/* ============================================================ */
/* Slider Item */
class _SliderItemWidget extends StatefulWidget {
  final _SliderItem item;

  const _SliderItemWidget({required this.item});

  @override
  State<_SliderItemWidget> createState() => _SliderItemWidgetState();
}

class _SliderItemWidgetState extends State<_SliderItemWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.item.rating; // ✅ تهيئة صحيحة
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11.r),
      child: Stack(
        children: [
          // الصورة
          Positioned.fill(
            child: Image.asset(
              widget.item.image,
              fit: BoxFit.cover,
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

          // العنوان
          Center(
            child: Text(
              widget.item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // التوصيل
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
              text: widget.item.deliveryPrice,
            ),
          ),

          // التقييم
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () async {
                final result =
                await showRatingDialog(context, _rating);

                if (result != null) {
                  setState(() => _rating = result);
                }
              },
              child:_InfoChip(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16.sp,
                ),
                text: _rating.toStringAsFixed(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================ */
/* Chip */
class _InfoChip extends StatelessWidget {
  final Widget icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

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
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}


/* ============================================================ */
/* Rating Dialog */
Future<double?> showRatingDialog(
    BuildContext context,
    double currentRating,
    ) {
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
                  onPressed: () =>
                      Navigator.pop(context, selectedRating),
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
