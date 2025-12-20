// presentation/widgets/home/most_popular.dart

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/discount_home.dart';
import 'package:breezefood/view/HomePage/popular_grid_Page.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/HomePage/widgets/custom_title.dart';
import 'package:breezefood/view/orders/add_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



/// --------------------------------------------------------------
/// عنوان القسم "Most Popular"
/// --------------------------------------------------------------
class CustomTitleSection extends StatelessWidget {
  final String title;
  final String? all;
  final IconData? icon;
  final VoidCallback? ontap;

  const CustomTitleSection({
    required this.title,
    this.all,
    this.icon,
    this.ontap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
            fontFamily: "Manrope",
          ),
        ),
        if (all != null && ontap != null)
          GestureDetector(
            onTap: ontap,
            child: Row(
              children: [
                Text(
                  all!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.white,
                    fontFamily: "Manrope",
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(icon, size: 12.sp, color: AppColor.white),
              ],
            ),
          ),
      ],
    );
  }
}

/// --------------------------------------------------------------
/// بطاقة المنتج (Popular Item Card)
/// --------------------------------------------------------------
class PopularItemCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final String price;
  final String? oldPrice;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PopularItemCard({
    required this.imagePath,
    required this.title,
    this.subtitle,
    required this.price,
    this.oldPrice,
    required this.isFavorite,
    required this.onFavoriteToggle,
    super.key,
  });

  @override
  State<PopularItemCard> createState() => _PopularItemCardState();
}

class _PopularItemCardState extends State<PopularItemCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _handleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(11.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11.r),
                  topRight: Radius.circular(11.r),
                ),
                child: Image.asset(
                  widget.imagePath,
                  width: double.infinity,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),

              // Overlay Dark Layer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                ),
              ),

              // Favorite Button ❤️
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _handleFavorite,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isFavorite ? 1.2 : 1.0,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: CustomTitle(title: widget.title, color: AppColor.white),
          ),
          // CustomSubTitle(subtitle:  widget.title,  color: AppColor.Dark, fontsize: 12.sp),
          // Text(
          //   widget.title,
          //   style: TextStyle(
          //     color: AppColor.Dark,
          //     fontSize: 12,
          //     fontFamily: "Manrope",
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // Price
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              widget.price,
              style: TextStyle(
                color: AppColor.white,
                fontSize: 12,
                fontFamily: "Inter",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------------------------------------------------
/// قسم Most Popular الكامل
/// --------------------------------------------------------------
class MostPopular extends StatefulWidget {
  final List<Map<String, dynamic>> popular;

  static const List<Map<String, dynamic>> _mockPopularItems = [
    {
      'name': 'Crispy Chicken ',
      'basePrice': '15.00',
      'oldPrice': '18.00',
      'isFavorite': true,
      'primaryImageUrl': 'assets/images/pourple.jpg',
      'restaurantId': 101,
    },
    {
      'name': 'Margherita Pizza',
      'basePrice': '12.00',
      'oldPrice': null,
      'isFavorite': false,
      'primaryImageUrl': 'assets/images/pourple.jpg',
      'restaurantId': 102,
    },
    {
      'name': 'Beef Shawarma ',
      'basePrice': '8.50',
      'oldPrice': null,
      'isFavorite': true,
      'primaryImageUrl': 'assets/images/pourple.jpg',
      'restaurantId': 103,
    },
    {
      'name': 'Sushi Set (12 pcs)',
      'basePrice': '25.99',
      'oldPrice': '30.00',
      'isFavorite': false,
      'primaryImageUrl': 'assets/images/pourple.jpg',
      'restaurantId': 104,
    },
  ];

  const MostPopular({super.key, List<Map<String, dynamic>>? popular})
    : popular = popular ?? _mockPopularItems;

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
  @override
  Widget build(BuildContext context) {
    final items = widget.popular;
    final count = items.length;

    final gap = 10.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    double containerWidth = switch (count) {
      0 => 0,
      1 => cardWidth + 4,
      2 => (2 * cardWidth) + gap + 4,
      _ => MediaQuery.of(context).size.width - 20,
    };

    containerWidth = containerWidth.clamp(
      0.0,
      MediaQuery.of(context).size.width - 20,
    );

    return Column(
      children: [
       Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomTitleSection(
          title: "Most Pouplar",
          all: "All",
          icon: Icons.arrow_forward_ios_outlined,
          ontap: () {
            Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const PopularGridPage(), // محاكاة التنقل
                  ),
                );
            // 🖱️ محاكاة الانتقال إلى صفحة الخصومات

          },
        ),
      ),

        const SizedBox(height: 10),

        SizedBox(
          height: 150,
          width: containerWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            physics: count <= 2
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final it = items[index];

              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: index == count - 1 ? 0 : gap),
                child: GestureDetector(
                  onTap: () {
                    showAddOrderDialog(
                      context,
                      title: it['name'],
                      price: it['basePrice'],
                      oldPrice: it['oldPrice'] ?? '',
                      imagePath: it['primaryImageUrl'],
                    );
                  },
                  child: PopularItemCard(
                    isFavorite: it['isFavorite'],
                    imagePath: it['primaryImageUrl'],
                    title: it['name'],
                    subtitle: it['restaurantId'].toString(),
                    price: it['basePrice'],
                    oldPrice: it['oldPrice'],
                    onFavoriteToggle: () {
                      setState(() {
                        it['isFavorite'] = !it['isFavorite'];
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
