import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/rating.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//////////////////////////////////////////////////////////////
// ⭐ Dialog Rating
//////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
// 🔧 Helpers
//////////////////////////////////////////////////////////////

bool _isNetwork(String path) =>
    path.startsWith("http://") || path.startsWith("https://");

String? _restaurantImage(RestaurantModel r) {
  final cover = r.coverImage?.toString().trim();
  final logo = r.logo?.toString().trim();

  final picked = (cover != null && cover.isNotEmpty) ? cover : logo;

  final full = UrlHelper.toFullUrl(picked);

  // ✅ DEBUG
  debugPrint("🖼️ [RestaurantImage] id=${r.id} name=${r.name}");
  debugPrint("   cover   => ${cover ?? 'null'}");
  debugPrint("   logo    => ${logo ?? 'null'}");
  debugPrint("   picked  => ${picked ?? 'null'}");
  debugPrint("   fullUrl => ${full ?? 'null'}");

  return full;
}

Widget _buildImage(String? urlOrAsset, {required double height}) {
  final fallback = Container(
    height: height,
    width: double.infinity,
    color: Colors.grey.shade800,
    alignment: Alignment.center,
    child: Icon(Icons.restaurant, color: Colors.white, size: 36.sp),
  );

  if (urlOrAsset == null || urlOrAsset.trim().isEmpty) {
    debugPrint("🖼️ [_buildImage] EMPTY => fallback");
    return fallback;
  }

  final p = urlOrAsset.trim();
  debugPrint("🖼️ [_buildImage] input => $p | isNetwork=${_isNetwork(p)}");

  if (_isNetwork(p)) {
    return Image.network(
      p,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,

      // ✅ DEBUG error
      errorBuilder: (context, error, stack) {
        debugPrint("❌ [Image.network] FAILED => $p");
        debugPrint("   error => $error");
        return fallback;
      },

      // ✅ DEBUG loading
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          debugPrint("✅ [Image.network] LOADED => $p");
          return child;
        }

        final total = progress.expectedTotalBytes;
        final loaded = progress.cumulativeBytesLoaded;
        debugPrint(
          "⏳ [Image.network] LOADING => $p | bytes=$loaded/${total ?? '-'}",
        );

        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade900,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColor.primaryColor,
            ),
          ),
        );
      },
    );
  }

  // ✅ DEBUG asset
  debugPrint("📦 [Image.asset] try => $p");
  return Image.asset(
    p,
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) {
      debugPrint("❌ [Image.asset] FAILED => $p | error=$error");
      return fallback;
    },
  );
}

class CloserToYouCard extends StatefulWidget {
  final String? image; // network or asset
  final String name;
  final double rating;
  final int? deliveryTime; // from API
  final VoidCallback? onTap;

  const CloserToYouCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.deliveryTime,
    this.onTap,
  });

  @override
  State<CloserToYouCard> createState() => _CloserToYouCardState();
}

class _CloserToYouCardState extends State<CloserToYouCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  Future<void> _openRatingDialog() async {
    final result = await showRatingDialog(context, _rating);
    if (result != null) {
      setState(() {
        _rating = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryText =
        (widget.deliveryTime != null && widget.deliveryTime! > 0)
        ? "${widget.deliveryTime} min"
        : "--";

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildImage(widget.image, height: 100.h),
              ),

              // Gradient overlay
              Container(
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _openRatingDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 3.w),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Name center
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/motor.svg",
                width: 16.w,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(width: 4.w),
              CustomSubTitle(
                subtitle: deliveryText,
                color: AppColor.white,
                fontsize: 12.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🧩 Closer To You Section (REAL DATA)
//////////////////////////////////////////////////////////////

class CloserToYou extends StatelessWidget {
  final List<RestaurantModel> restaurants;

  /// إذا القائمة فاضية، منخفي السكشن أو منعرض Placeholder بسيط
  final bool hideWhenEmpty;

  const CloserToYou({
    super.key,
    required this.restaurants,
    this.hideWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      if (hideWhenEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Container(
          height: 100.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: CustomSubTitle(
            subtitle: "No restaurants found",
            color: AppColor.white,
            fontsize: 14.sp,
          ),
        ),
      );
    }

    final gap = 10.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    return SizedBox(
      height: 130.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              left: index == 0 ? 9.w : 0,
              right: index == restaurants.length - 1 ? 10.w : gap,
            ),
            child: CloserToYouCard(
              image: _restaurantImage(r),
              name: r.name,
              rating: r.ratingAvg <= 0 ? 4.0 : r.ratingAvg, // fallback لطيف
              deliveryTime: r.deliveryTime,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => getIt<FavoritesCubit>()),

                        // ✅ نفس CartCubit تبع الهوم
                        BlocProvider.value(value: context.read<CartCubit>()),
                      ],
                      child: ResturantDetails(restaurant_id: r.id),
                    ),
                  ),
                );

                if (context.mounted) {
                  context.read<CartCubit>().loadCart();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
