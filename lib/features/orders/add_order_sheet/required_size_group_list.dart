import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'required_badge_animated.dart';

class RequiredSizeGroupList extends StatelessWidget {
  final ExtraGrouped group;
  final int? selectedExtraId;
  final ValueChanged<int> onSelect;

  final bool highlightRequired;

  const RequiredSizeGroupList({
    super.key,
    required this.group,
    required this.selectedExtraId,
    required this.onSelect,
    required this.highlightRequired,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    String title() {
      final t = isRTL ? (group.nameAr ?? "") : (group.nameEn ?? "");
      return t.trim().isEmpty ? (isRTL ? "الحجم" : "Size") : t;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSubTitle(
              subtitle: title(),
              color: AppColor.Lightgry,
              fontsize: 13,
            ),
            RequiredBadgeAnimated(
              isRTL: isRTL,
              animate: highlightRequired && (selectedExtraId == null),
              isSelected: selectedExtraId != null,
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ...group.items.map((it) {
          final name = isRTL ? it.nameAr : it.nameEn;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<int>(
                        value: it.id,
                        groupValue: selectedExtraId,
                        activeColor: AppColor.primaryColor,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        onChanged: (val) {
                          if (val == null) return;
                          HapticFeedback.vibrate();
                          onSelect(val);
                        },
                      ),
                      Expanded(
                        child: CustomSubTitle(
                          subtitle: name,
                          color: AppColor.Lightgry,
                          fontsize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomSubTitle(
                  subtitle: context.money(it.price),
                  color: AppColor.yellow,
                  fontsize: 14,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}