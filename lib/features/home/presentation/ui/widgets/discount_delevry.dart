import 'package:breezefood/core/prices_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscountDelevry extends StatefulWidget {
  final String imagePath;
  final String title;

  final String oldPrice;
  final String newPrice;
  final VoidCallback onFavoriteToggle;
  final void Function()? onTap;
  final bool initialIsFavorite;

  const DiscountDelevry({
    super.key,
    required this.imagePath,
    required this.title,

    required this.oldPrice,
    required this.newPrice,
    required this.onFavoriteToggle,
    this.initialIsFavorite = false,
    this.onTap,
  });

  @override
  State<DiscountDelevry> createState() => _DiscountDelevryState();
}

class _DiscountDelevryState extends State<DiscountDelevry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Widget buildImage(String path, {double? height}) {
    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (ctx, e, s) => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.fastfood, color: Colors.white),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                /// 📌 صورة المنتج
                Container(
                  height: 100.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: buildImage(widget.imagePath, height: 100.h),
                  ),
                ),

                /// 📌 تدرج فوق الصورة + الاسم بالوسط
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// 📌 السعر القديم + الجديد أسفل الصورة - نفس الـ Style الذي طلبته
                Positioned(
                  bottom: 0,
                  left: 0,

                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        /// أيقونة دراجة التوصيل
                        SvgPicture.asset(
                          "assets/icons/motor.svg",
                          color: Colors.white,
                          width: 15,
                          height: 15,
                        ),

                        SizedBox(width: 4.w),

                        Text(
                          context.syp(widget.oldPrice),
                          style: TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 4.w),

                        Text(
                          context.syp(widget.newPrice),
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
