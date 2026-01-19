import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:easy_localization/easy_localization.dart';
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
          child: CustomTitleSection(
            title: "Discount",

            ontap: () {

            },
          ),
        ),

        const SizedBox(height: 10),

        // ===== LIST =====
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count > 10 ? 10 : count,
              physics: count <= 2
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final it = items[index];

                return Container(
                  width: cardWidth,
                  margin: EdgeInsetsDirectional.only(
                    end: index == count - 1 ? 0 : gap,
                  ),
                  child: GestureDetector(
                    onTap: () => onTap(it),
                    child: DiscountItemCard(
                      item: it,
                      imageUrl: fullImageUrl(it.image ?? ""),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
