import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/CategoryItemsGridPage.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RDMenuCategorySection extends StatelessWidget {
  const RDMenuCategorySection({
    super.key,
    required this.sectionKey,
    required this.restaurantId,
    required this.title,
    required this.items,
    required this.isRestaurantOpen,
    required this.onTapItem,
  });

  final GlobalKey sectionKey;
  final int restaurantId;
  final String title;
  final List<MenuItem> items;
  final bool isRestaurantOpen;

  final Future<void> Function(MenuItem it) onTapItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomTitleSection(
            title: title,
            all: "common.all".tr(),
            icon: Icons.arrow_forward_ios,
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryItemsGridPage(restaurant_id: restaurantId, title: title, items: items, isRestaurantOpen: isRestaurantOpen),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(start: 20),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];

              return GestureDetector(
                key: key,
                onTap: () => onTapItem(it),
                child: Container(
                  width: 142.w,
                  margin: EdgeInsetsDirectional.only(end: i == items.length - 1 ? 0 : 8.w),
                  child: _RDItemCardBridge(it: it, isRestaurantOpen: isRestaurantOpen),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _RDItemCardBridge extends StatelessWidget {
  const _RDItemCardBridge({required this.it, required this.isRestaurantOpen});

  final MenuItem it;
  final bool isRestaurantOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12.r)),
      alignment: Alignment.center,
      child: CustomSubTitle(
        subtitle: context.pick(ar: it.nameAr, en: it.nameEn),
        color: Colors.white,
        fontsize: 12,
      ),
    );
  }
}
