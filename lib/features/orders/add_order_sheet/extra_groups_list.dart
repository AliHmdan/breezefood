import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExtraGroupsList extends StatelessWidget {
  final List<ExtraGrouped> groups;
  final Map<int, int> selectedChoice; // groupId -> extraId
  final void Function(int groupId, int extraId) onChanged;

  const ExtraGroupsList({
    super.key,
    required this.groups,
    required this.selectedChoice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    String groupTitle(ExtraGrouped g) {
      final t = isRTL ? (g.nameAr ?? "") : (g.nameEn ?? "");
      return t.trim().isEmpty ? (isRTL ? "إضافات" : "Extras") : t;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((g) {
        final title = groupTitle(g);
        final chosenId = selectedChoice[g.groupId];

        final useRadio = g.items.length > 1;

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSubTitle(
                subtitle: title,
                color: AppColor.Lightgry,
                fontsize: 13,
              ),
              SizedBox(height: 6.h),
              ...g.items.map((it) {
                final name = isRTL ? it.nameAr : it.nameEn;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (useRadio)
                              Radio<int>(
                                value: it.id,
                                groupValue: chosenId,
                                activeColor: AppColor.primaryColor,
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                onChanged: (val) {
                                  if (val == null) return;
                                  onChanged(g.groupId, val);
                                },
                              )
                            else
                              Checkbox(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                activeColor: AppColor.primaryColor,
                                side: BorderSide(
                                  color: AppColor.Lightgry,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                value: chosenId == it.id,
                                onChanged: (val) {
                                  if (val == true) {
                                    onChanged(g.groupId, it.id);
                                  } else {
                                    selectedChoice.remove(g.groupId);
                                  }
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
          ),
        );
      }).toList(),
    );
  }
}