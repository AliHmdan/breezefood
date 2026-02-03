import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_delevry_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef AsyncVoidCallback = Future<void> Function();

class DiscountPriceCard extends StatelessWidget {
  final String imageUrl; // صورة (بدك تخليها صورة المطعم)
  final String restaurantName;
  final double? rating; // ✅ optional

  final dynamic oldPrice;
  final dynamic newPrice;
  final void Function()? onTap;

  const DiscountPriceCard({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    this.rating,
    required this.oldPrice,
    required this.newPrice,
    this.onTap,
  });

  Widget _buildNetworkImage(String url, {double? height}) {
    final u = url.trim();
    if (u.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(Icons.store, color: Colors.white70, size: 26.sp),
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
        child: Icon(Icons.store, color: Colors.white70, size: 26.sp),
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
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(6.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Stack(
                        children: [
                          _buildNetworkImage(imageUrl, height: 150.h),

                          // ✅ Gradient خفيف ليطلع النص واضح
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.80),
                                    Colors.black.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // ✅ Overlay: اسم المطعم + تقييم (إن وجد)
                          PositionedDirectional(
                            start: 8.w,
                            end: 8.w,
                            bottom: 8.h,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    restaurantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      fontFamily:
                                          Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                ),
                                if (rating != null && rating! > 0) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.30),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 12.sp,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          rating!.toStringAsFixed(1),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // prices
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
                context.syp(oldPrice, decimals: 0),
                style: TextStyle(
                  color: AppColor.LightActive,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                context.syp(newPrice, decimals: 0),
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
  final List<MenuItemModel> discounts;

  const DiscountDelvery({super.key, required this.discounts});

  bool _hasDiscount(MenuItemModel it) =>
      it.hasDiscount && (it.priceBefore > it.priceAfter);

  /// ✅ صورة المطعم أولاً
  String _restaurantLogo(MenuItemModel it) =>
      UrlHelper.toFullUrl(it.restaurant?.logo) ?? "";

  String _restaurantName(MenuItemModel it) =>
      (it.restaurant?.name.isNotEmpty == true)
      ? it.restaurant!.name
      : "Restaurant";

  /// ✅ العنوان = اسم المطعم
  String _title(MenuItemModel it) {
    return it.restaurant?.name.isNotEmpty == true
        ? it.restaurant!.name
        : "Restaurant";
  }

  @override
  Widget build(BuildContext context) {
    final items = discounts.where(_hasDiscount).toList();

    if (items.isEmpty) return const SizedBox.shrink();

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

        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final it = items[index];

              return Container(
                width: 160.w,
                margin: EdgeInsets.only(right: 10.w),
                child: DiscountPriceCard(
                  imageUrl: _restaurantLogo(it), // ✅ صورة المطعم
                  restaurantName: _restaurantName(it), // ✅ اسم المطعم
                  rating: it.restaurant?.ratingAvg,

                  oldPrice: it.priceBefore,
                  newPrice: it.priceAfter,
                  onTap: () => openDiscountFlow(context, it),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
