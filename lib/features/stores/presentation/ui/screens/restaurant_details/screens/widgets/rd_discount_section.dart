import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/discout_meal_section.dart';
import 'package:flutter/material.dart';

class RDDiscountSection extends StatelessWidget {
  const RDDiscountSection({
    super.key,
    required this.items,
    required this.fullImageUrl,
    required this.onTap,
  });

  final List<MenuItem> items;

  final String Function(String raw) fullImageUrl;

  final void Function(MenuItem it) onTap;

  @override
  Widget build(BuildContext context) {
    return DiscountMealSection(
      items: items,
      fullImageUrl: fullImageUrl,
      onTap: onTap,
    );
  }
}
