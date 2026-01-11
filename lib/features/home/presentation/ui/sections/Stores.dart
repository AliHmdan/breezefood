import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Stores extends StatelessWidget {
  final List<RestaurantModel> restaurants;

  const Stores({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    final height = 160.h;

    if (restaurants.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            "No stores available",
            style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: 361.w,
        child: CarouselSlider.builder(
          options: CarouselOptions(
            height: height,
            autoPlay: restaurants.length > 1,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
          ),
          itemCount: restaurants.length,
          itemBuilder: (context, index, realIndex) {
            final r = restaurants[index];

            // اختيار صورة مناسبة
            final cover = UrlHelper.toFullUrl(r.coverImage);
            final logo = UrlHelper.toFullUrl(r.logo);
            final imageUrl = (cover ?? "").trim().isNotEmpty ? cover : logo;

            return Stack(
              alignment: Alignment.center,
              children: [
                // خلفية الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _NetImage(url: imageUrl, height: height),
                ),

                // طبقة شفافة + gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "subtitle",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 3.h),

                        Text(
                          r.name ?? "Store",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // if (location.isNotEmpty) ...[
                        //   SizedBox(height: 2.h),
                        //   Container(
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: 8.w,
                        //       vertical: 3.h,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.black.withOpacity(0.35),
                        //       borderRadius: BorderRadius.circular(20.r),
                        //     ),
                        //     child: Text(
                        //       location,
                        //       style: TextStyle(
                        //         color: AppColor.gry,
                        //         fontSize: 11.sp,
                        //       ),
                        //     ),
                        //   ),
                        // ],
                        SizedBox(height: 6.h),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => getIt<FavoritesCubit>(),
                                  child: ResturantDetails(restaurant_id: r.id),
                                ),
                              ),
                            );
                            context.read<CartCubit>().loadCart();
                          },
                          child: Text(
                            "Order Now",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  final String? url;
  final double height;

  const _NetImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final u = (url ?? "").trim();

    if (u.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.blueGrey.shade900,
        alignment: Alignment.center,
        child: Icon(Icons.storefront, color: Colors.white70, size: 30.sp),
      );
    }

    return Image.network(
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
        color: Colors.blueGrey.shade900,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white70,
          size: 26.sp,
        ),
      ),
    );
  }
}
