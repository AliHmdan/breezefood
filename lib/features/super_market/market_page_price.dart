import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/market_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketPagePrice extends StatelessWidget {
  final int marketId;
  final String title;

  const MarketPagePrice({
    super.key,
    required this.marketId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketDetailsCubit(
        repo: getIt<SuperMarketRepo>(),
        marketId: marketId,
      )..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 22.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: BlocBuilder<MarketDetailsCubit, MarketDetailsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Categories Row
                  SizedBox(
                    height: 44.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, i) {
                        final c = state.categories[i];
                        final selected = c.id == state.selectedCategoryId;

                        return InkWell(
                          onTap: () => context
                              .read<MarketDetailsCubit>()
                              .selectCategory(c.id),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  color: selected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ✅ Items Grid
                  Expanded(
                    child: state.loadingItems
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.items.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 190.w,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                  childAspectRatio: 0.80,
                                ),
                            itemBuilder: (context, index) {
                              final it = state.items[index];

                              // نستخدم ProductCard الحالي تبعك لكن نحوله من MarketItemModel
                              final product = Product(
                                title: it.nameAr.isNotEmpty
                                    ? it.nameAr
                                    : it.nameEn,
                                price: "${it.basePrice}\$",
                                image:
                                    "assets/images/bread.png", // إذا ما عندك صورة من API
                              );

                              return ProductCard(product: product);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/* ===========================
        Product Card
=========================== */

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            child: Image.asset(
              product.image,
              height: 130.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(height: 10.h),

          /// TITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              product.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50), // أخضر أنيق
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 4.h),

          /// PRICE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              product.price,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

/* ===========================
        Product Model
=========================== */

class Product {
  final String title;
  final String price;
  final String image;

  Product({required this.title, required this.price, required this.image});
}

/* ===========================
        Dummy Data
=========================== */

final List<Product> products = [
  Product(title: "Bread", price: "2.00\$", image: "assets/images/bread.png"),
  Product(title: "Milk", price: "1.50\$", image: "assets/images/mealk.png"),
  Product(title: "Chicken", price: "5.00\$", image: "assets/images/001.jpg"),
  Product(title: "Bread", price: "2.00\$", image: "assets/images/003.jpg"),
];
