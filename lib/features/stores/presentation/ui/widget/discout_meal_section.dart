import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/meal_grid_page.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountMealSection extends StatelessWidget {
  final List<MenuItem> items;
  final String Function(String raw) fullImageUrl;
  final void Function(MenuItem it) onTap;

  const DiscountMealSection({
    super.key,
    required this.items,
    required this.fullImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final gap = 8.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;
    final count = items.length;

    return Column(
      children: [
        // ===== TITLE (مطابق MostPopular) =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(

            children: <Widget>[
              Icon(
              Icons.local_offer,
              color: AppColor.yellow,
              size: 18.sp,
            ),
              SizedBox(width: 2,),
              Expanded(
                child: CustomTitleSection(
                  title: "Discount",
                  icon: Icons.arrow_forward_ios,
                  all: "All",
                  ontap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiscountGridPage(
                            items: items, // 👈 نفس الليست
                            fullImageUrl: fullImageUrl,
                            onTap: onTap,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ===== LIST =====
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count > 10 ? 10 : count,
            physics: count <= 2
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final it = items[index];

              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: index == 0 ? 16.w : 0,          // 🔥 أول عنصر فقط
                    end: index == count - 1 ? 16.w : gap),
                child: SizedBox(
                  width: cardWidth,

                  child: GestureDetector(
                    onTap: () => onTap(it),
                    child:
                    DiscountItemCard(
                      item: it,
                      imageUrl: fullImageUrl(it.image ?? ""),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
