import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/CategoryItemsGridPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/restaurant_details_mapper.dart';

class RDMostPopularSection extends StatelessWidget {
  const RDMostPopularSection({
    super.key,
    required this.restaurantId,
    required this.items,
    required this.isRestaurantOpen,
    required this.imageUrl,
  });

  final int restaurantId;
  final List<MenuItem> items;
  final bool isRestaurantOpen;
  final String Function(String? raw) imageUrl;

  Future<void> _openItem(BuildContext context, MenuItem item) async {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final desc = context.pick(
      ar: item.descriptionAr ?? "",
      en: item.descriptionEn ?? "",
    );
    final img = imageUrl(item.image);

    await showAddOrderDialog(
      context,
      isRestaurantOpen: isRestaurantOpen,
      restaurantId: restaurantId,
      menuItemId: item.id,
      title: title,
      price: item.effectivePrice,
      oldPrice: (item.priceBefore > 0 ? item.priceBefore : item.price),
      imagePathOrUrl: img.isNotEmpty ? img : "assets/images/shawarma_box.png",
      description: desc,
      extraMeals: item.mealExtras,
      extraGroups: item.extrasGrouped,
    );

    if (context.mounted) {
      try { context.read<CartCubit>().loadCart(); } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final title = context.pick(ar: "الأكثر طلباً", en: "Most Popular");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
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
                  builder: (_) => CategoryItemsGridPage(
                    restaurant_id: restaurantId,
                    title: title,
                    items: items,
                    isRestaurantOpen: isRestaurantOpen,
                  ),
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
              final img = imageUrl(it.image);

              final mapped = RestaurantDetailsMapper.mapMenuItemToHomeModel(
                it: it,
                imageUrl: img,
              );

              return GestureDetector(
                onTap: () => _openItem(context, it),
                child: Container(
                  width: 142.w,
                  margin: EdgeInsetsDirectional.only(
                    end: i == items.length - 1 ? 0 : 8.w,
                  ),
                  child: PopularItemCard(
                    item: mapped,
                    isRestaurantOpen: isRestaurantOpen,
                  ),
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
