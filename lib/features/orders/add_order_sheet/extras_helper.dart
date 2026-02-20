import 'package:breezefood/features/stores/model/restaurant_details_model.dart';

class ExtrasHelper {
  static ExtraGrouped? findSizeGroup(List<ExtraGrouped> groups) {
    bool isSizeGroup(ExtraGrouped g) {
      final ar = (g.nameAr ?? "").toLowerCase().trim();
      final en = (g.nameEn ?? "").toLowerCase().trim();
      return en.contains("size") || ar.contains("حجم") || ar.contains("الحجم");
    }

    for (final g in groups) {
      if (isSizeGroup(g)) return g;
    }
    return null;
  }

  static List<ExtraGrouped> otherGroups(
    List<ExtraGrouped> groups,
    ExtraGrouped? sizeGroup,
  ) {
    if (sizeGroup == null) return groups;
    return groups.where((g) => g.groupId != sizeGroup.groupId).toList();
  }

  static double computeExtrasTotal({
    required ExtraGrouped? sizeGroup,
    required int? selectedSizeExtraId,
    required List<ExtraGrouped> otherGroups,
    required Map<int, int> selectedGroupChoice,
  }) {
    double sum = 0;

    // size group
    if (sizeGroup != null && selectedSizeExtraId != null) {
      final it = sizeGroup.items.firstWhere(
        (x) => x.id == selectedSizeExtraId,
        orElse: () => sizeGroup.items.first,
      );
      sum += it.price;
    }

    // other groups
    final selectedIds = selectedGroupChoice.values.toSet();
    for (final g in otherGroups) {
      for (final it in g.items) {
        if (selectedIds.contains(it.id)) sum += it.price;
      }
    }

    return sum;
  }
}