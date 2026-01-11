import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_delevry_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscountPriceCard extends StatefulWidget {
  final String imageUrl; // ✅ FULL URL (network)
  final String title;
  final String oldPrice;
  final String newPrice;

  final bool initialIsFavorite;
  final VoidCallback onFavoriteToggle;
  final void Function()? onTap;

  const DiscountPriceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    required this.onFavoriteToggle,
    this.initialIsFavorite = false,
    this.onTap,
  });

  @override
  State<DiscountPriceCard> createState() => _DiscountPriceCardState();
}

class _DiscountPriceCardState extends State<DiscountPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late bool _isFavorite;

  double _rating = 4.9;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

  Widget _buildNetworkImage(String url, {double? height}) {
    final u = url.trim();
    if (u.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white70,
          size: 24.sp,
        ),
      );
    }

    return Image.network(
      u,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: Colors.black.withOpacity(0.12),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image, color: Colors.white70, size: 24.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 100.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: _buildNetworkImage(widget.imageUrl, height: 100.h),
                ),
              ),

              // Gradient overlay + title
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
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

              // ⭐ Rating (top-right)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () async {
                    final result = await showRatingDialog(context, _rating);
                    if (result != null) setState(() => _rating = result);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ❤️ Favorite (اختياري، نفس الأنيميشن بدون تغيير الشكل)
              Positioned(
                top: 6.h,
                left: 6.w,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),

              // prices bottom-left
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/motor.svg",
                        color: AppColor.white,
                        width: 15,
                        height: 15,
                      ),
                      const SizedBox(width: 4),

                      Text(
                        "${widget.oldPrice}\$",
                        style: TextStyle(
                          color: AppColor.LightActive,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${widget.newPrice}\$",
                        style: TextStyle(
                          color: AppColor.white,
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
    );
  }
}

//////////////////////////////////////////////////////////////////////
//          DiscountDelivery — REAL DATA (MenuItemModel)
//////////////////////////////////////////////////////////////////////

class DiscountDelvery extends StatelessWidget {
  final List<MenuItemModel>
  discounts; // ✅ real from API (HomeResponse.discounts)

  const DiscountDelvery({super.key, required this.discounts});

  bool _hasDiscount(MenuItemModel it) =>
      it.hasDiscount && (it.priceBefore > it.priceAfter);

  String _img(MenuItemModel it) =>
      UrlHelper.toFullUrl(it.primaryImage?.imageUrl) ?? "";

  String _title(MenuItemModel it) {
    // بدك اسم الوجبة أو اسم المطعم؟ انت كنت حاطط restaurantName
    // هون خليتها اسم الوجبة (أوضح للمستخدم)
    return it.nameAr.isNotEmpty ? it.nameAr : it.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    final items = discounts.where(_hasDiscount).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTitleSection(
            title: "Discounts Delivery",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiscountDelevryGridPageGridPage(
                    discounts: items, // ✅ مرر نفس الليست
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 8),
            child: SizedBox(
              height: 110.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 2.2;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final it = items[index];

                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(right: 10.w),
                        child: DiscountPriceCard(
                          imageUrl: _img(it),
                          title: _title(it),
                          oldPrice: it.priceBefore.toStringAsFixed(0),
                          newPrice: it.priceAfter.toStringAsFixed(0),
                          initialIsFavorite: it.isFavorite,
                          onFavoriteToggle: () {},
                          onTap: () {
                            openDiscountFlow(context, it);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
