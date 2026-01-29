import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_delevry_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef AsyncVoidCallback = Future<void> Function();

class DiscountPriceCard extends StatefulWidget {
  final String imageUrl;
  final String title;

  final dynamic oldPrice; // ✅ بدل String
  final dynamic newPrice; // ✅ بدل String

  final void Function()? onTap;

  const DiscountPriceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    this.onTap,
  });

  @override
  State<DiscountPriceCard> createState() => _DiscountPriceCardState();
}

class _DiscountPriceCardState extends State<DiscountPriceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late bool _isFavorite;

  bool _sending = false;
  double _rating = 4.9;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image, color: Colors.white70, size: 24.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.6,
          child: Stack(
            children: [
              // ✅ الكارد القابل للضغط (يفتح التفاصيل) — منفصل عن زر القلب
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(6.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Stack(
                        children: [
                          _buildNetworkImage(widget.imageUrl, height: 150.h),
                          // Positioned.fill(
                          //   child: Container(
                          //     color: Colors.black.withOpacity(0.25),
                          //   ),
                          // ),
                          Center(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ⭐ Rating (top-right)
              PositionedDirectional(
                top: 6.h,
                end: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
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
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/icons/motor.svg",
                color: AppColor.white,
                width: 15,
                height: 15,
              ),
              SizedBox(width: 4.w),
              Text(
                context.syp(widget.oldPrice, decimals: 0), // ✅
                style: TextStyle(
                  color: AppColor.LightActive,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                context.syp(widget.newPrice, decimals: 0), // ✅
                style: TextStyle(
                  color: AppColor.red,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
                  builder: (_) => BlocProvider.value(
                    value: context.read<FavoritesCubit>(),
                    child: DiscountDelevryGridPageGridPage(discounts: items),
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
              height: 180.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 2.2;

                  return ListView.builder(
                    itemExtent: null,
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
                          oldPrice: it.priceBefore,
                          newPrice: it.priceAfter,

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
