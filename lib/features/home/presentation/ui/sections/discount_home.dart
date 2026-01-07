import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_grid_Page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

//////////////////////////////////////////////////////////////
// Rating Popup (UI only)
//////////////////////////////////////////////////////////////

void showRatingPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: const Color(0xFF2F2F2F),
        child: Padding(
          padding: EdgeInsets.all(20.w),
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
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 35.sp,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Please share your rate about the restaurant",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    },
  );
}

//////////////////////////////////////////////////////////////
// 🧩 Discount Card (works with network images)
//////////////////////////////////////////////////////////////

class Discount extends StatefulWidget {
  final String imagePath; // ✅ network full url
  final String subtitle; // restaurant name
  final String price; // price text
  final String discount; // discount text
  final VoidCallback onFavoriteToggle;
  final void Function()? onTap;
  final bool initialIsFavorite;

  const Discount({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.price,
    required this.discount,
    required this.onFavoriteToggle,
    this.initialIsFavorite = false,
    this.onTap,
  });

  @override
  State<Discount> createState() => _DiscountState();
}

class _DiscountState extends State<Discount> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildImage(String url, {double? height}) {
    if (url.trim().isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.fastfood, color: AppColor.white, size: 30.sp),
        ),
      );
    }

    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: Colors.black.withOpacity(0.15),
          alignment: Alignment.center,
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.image_not_supported, color: AppColor.white, size: 30.sp),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 160.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: buildImage(widget.imagePath, height: 100.h),
                ),

                // ⭐ Rating
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => showRatingPopup(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 4.w),
                          CustomSubTitle(
                            subtitle: "4.9",
                            color: AppColor.white,
                            fontsize: 12.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ❤️ Favorite
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),

                // Restaurant name overlay
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
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomSubTitle(
                          subtitle: widget.subtitle,
                          color: AppColor.white,
                          fontsize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                // Discount chip
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSubTitle(
                          subtitle: widget.discount,
                          color: AppColor.white,
                          fontsize: 14,
                        ),
                        SizedBox(width: 4.w),
                        SvgPicture.asset(
                          "assets/icons/nspah.svg",
                          width: 22.w,
                          height: 22.h,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Text(
                widget.price,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🏠 DiscountHome (REAL HOME DATA)
//////////////////////////////////////////////////////////////

class DiscountHome extends StatelessWidget {
  final List<MenuItemModel> mostPopular; // ✅ من HomeResponse

  const DiscountHome({super.key, required this.mostPopular});

  bool _hasDiscount(MenuItemModel it) => it.hasDiscount && (it.discountValue ?? 0) > 0;

  String _discountText(MenuItemModel it) {
    final v = it.discountValue ?? 0;
    final type = (it.discountType ?? "").toLowerCase();

    if (type.contains("percent")) return "${v.toStringAsFixed(0)}%";
    // amount
    return v.toStringAsFixed(0);
  }

  String _priceText(MenuItemModel it) {
    // عندك priceAfter جاهزة
    return "${it.priceAfter.toStringAsFixed(0)}";
  }

  String _restaurantName(MenuItemModel it) {
    return it.restaurant?.name.isNotEmpty == true ? it.restaurant!.name : "Restaurant";
  }

  String _imageUrl(MenuItemModel it) {
    final path = it.primaryImage?.imageUrl;
    return UrlHelper.toFullUrl(path) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final items = mostPopular.where(_hasDiscount).toList();

    if (items.isEmpty) {
      // إذا بدك تخفي القسم كلياً:
      // return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: AppColor.primaryColor, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "No discounts available right now",
                  style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTitleSection(
            title: "Discounts",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DiscountGridPage()),
              );
            },
          ),
        ),

        RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 0.2),
            child: SizedBox(
              height: 130.h,
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
                        child: Discount(
                          imagePath: _imageUrl(it),
                          subtitle: _restaurantName(it),
                          price: _priceText(it),
                          discount: _discountText(it),
                          initialIsFavorite: it.isFavorite,
                          onFavoriteToggle: () {
                            // لاحقاً تربط favorite endpoint
                          },
                          onTap: () {
                            // افتح تفاصيل المنتج مثلاً
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
