import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/share_icon.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/request_order/custom_hot.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> showAddOrderDialog(
  BuildContext context, {
  required int restaurantId,
  required int menuItemId,
  required String title,
  required double price,
  required double oldPrice,
  required String imagePathOrUrl,
  required String description,
  required List<MenuExtra> extraMeals,
  required List<ExtraGrouped> extraGroups, // ✅ NEW
  required bool isRestaurantOpen,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetCtx) {
      final height = MediaQuery.of(sheetCtx).size.height * 0.9;

      // ✅ خذ CartCubit من سياق الصفحة (context) مو sheetCtx
      final cartCubit = context.read<CartCubit>();

      return MediaQuery.removePadding(
        context: sheetCtx,
        removeTop: true,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 600),
          // duration: Duration.zero,
          // curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColor.Dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: BlocProvider.value(
              value: cartCubit, // ✅ نفس instance
              child: AddOrderBody(
                restaurantId: restaurantId,
                menuItemId: menuItemId,
                title: title,
                price: price,
                oldPrice: oldPrice,
                imagePathOrUrl: imagePathOrUrl,
                description: description,
                extras: extraMeals,
                extraGroups: extraGroups, // ✅ NEW
                isRestaurantOpen: isRestaurantOpen,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class AddOrderBody extends StatefulWidget {
  final String title;
  final double price;
  final double oldPrice;
  final String imagePathOrUrl;
  final String description;
  final List<MenuExtra> extras;
  final int restaurantId;
  final int menuItemId;
  final bool isRestaurantOpen;
  final List<ExtraGrouped> extraGroups; // ✅ NEW
  const AddOrderBody({
    required this.isRestaurantOpen,

    super.key,
    required this.extraGroups, // ✅ NEW
    required this.restaurantId,
    required this.menuItemId,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.imagePathOrUrl,
    required this.description,
    required this.extras,
  });

  @override
  State<AddOrderBody> createState() => _AddOrderBodyState();
}

class _AddOrderBodyState extends State<AddOrderBody> {
  @override
  void initState() {
    super.initState();
    final sg = _sizeGroup;
    if (sg != null && sg.items.isNotEmpty) {
      _selectedSizeExtraId ??= sg.items.first.id;
    }
  }

  int? _selectedSizeId; // ✅ Size واحد

  bool _withSpicy = false;
  final Map<int, int> _selectedGroupChoice = {};

  // ✅ NEW: groupId -> selected extraIds (إذا بدك multi لاحقاً)
  final TextEditingController _noteCtrl = TextEditingController();
  String _buildShareText() {
    final price = context.money(widget.price);
    final old = context.money(widget.oldPrice);

    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    final legacyNames = widget.extras
        .where((e) => _selectedExtrasIds.contains(e.id))
        .map((e) => isRTL ? e.nameAr : e.nameEn)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final groupedSelectedIds = _selectedGroupChoice.values.toSet();
    final groupedNames = widget.extraGroups
        .expand((g) => g.items)
        .where((e) => groupedSelectedIds.contains(e.id))
        .map((e) => isRTL ? e.nameAr : e.nameEn)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final extrasNames = [...groupedNames, ...legacyNames];

    final extrasLine = extrasNames.isEmpty
        ? ""
        : "\nExtras: ${extrasNames.join(", ")}";

    final spicyLine = _withSpicy ? "\n🌶️ Hot: Yes" : "\n🌶️ Hot: No";

    final note = _noteCtrl.text.trim();
    final noteLine = note.isEmpty ? "" : "\n📝 Notes: $note";

    final discountLine = (widget.oldPrice > widget.price && widget.oldPrice > 0)
        ? "\n💸 Old: $old"
        : "";
    final productUrl = "";

    return """
${widget.title}
💰 Price: $price$discountLine
$spicyLine
$extrasLine$noteLine
${productUrl.isEmpty ? "" : "\n$productUrl"}
"""
        .trim();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  ExtraGrouped? get _sizeGroup {
    bool isSizeGroup(ExtraGrouped g) {
      final ar = (g.nameAr ?? "").toLowerCase().trim();
      final en = (g.nameEn ?? "").toLowerCase().trim();

      // group_id أحياناً 0 وعنوانه null، فنعتمد على الاسم إذا موجود
      return en.contains("size") || ar.contains("حجم") || ar.contains("الحجم");
    }

    for (final g in widget.extraGroups) {
      if (isSizeGroup(g)) return g;
    }
    return null;
  }

  List<ExtraGrouped> get _otherGroups {
    final sg = _sizeGroup;
    if (sg == null) return widget.extraGroups;
    return widget.extraGroups.where((g) => g.groupId != sg.groupId).toList();
  }

  int? _selectedSizeExtraId; // ✅ extraId تبع الحجم (من grouped)

  final Set<int> _selectedExtrasIds = {};
  List<AddToCartExtraRequest> _selectedExtrasPayload() {
    final ids = <int>{};

    // ✅ size من grouped
    if (_selectedSizeExtraId != null) ids.add(_selectedSizeExtraId!);

    // ✅ باقي الـ grouped
    ids.addAll(_selectedGroupChoice.values);

    return ids
        .map((id) => AddToCartExtraRequest(extraId: id, quantity: 1))
        .toList();
  }

  double get _extrasTotal {
    double sum = 0;

    // ✅ size grouped
    final sg = _sizeGroup;
    if (sg != null && _selectedSizeExtraId != null) {
      final it = sg.items.firstWhere(
        (x) => x.id == _selectedSizeExtraId,
        orElse: () => sg.items.first,
      );
      sum += it.price;
    }

    // ✅ باقي الـ grouped
    final selectedGroupedIds = _selectedGroupChoice.values.toSet();
    for (final g in _otherGroups) {
      for (final it in g.items) {
        if (selectedGroupedIds.contains(it.id)) sum += it.price;
      }
    }

    return sum;
  }

  bool get _hasDiscount =>
      widget.oldPrice > widget.price && widget.oldPrice > 0;

  bool get _isNetworkImage {
    final s = widget.imagePathOrUrl.trim();
    return s.startsWith("http://") || s.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    final sg = _sizeGroup;
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        state.whenOrNull(
          addedSuccess: (message) async {
            EasyLoading.showSuccess(message);

            if (context.mounted) Navigator.of(context).pop(true);
          },
          error: (msg) {
            EasyLoading.showError(msg);
          },
        );
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24.r),
                        ),
                        child: AppNetworkImage(
                          path: widget.imagePathOrUrl,
                          width: double.infinity,
                          height: 400.h,
                          fit: BoxFit.cover,
                          // useOldImageOnUrlChange: true,
                        ),
                      ),

                      PositionedDirectional(
                        top: 5,
                        end: 1,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.black54,
                            ),
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            minimumSize: WidgetStateProperty.all(
                              const Size(30, 30),
                            ),
                            fixedSize: WidgetStateProperty.all(
                              const Size(30, 30),
                            ),
                          ),
                        ),
                      ),

                      PositionedDirectional(
                        bottom: 5,
                        end: 10,
                        child: AppShareFab(
                          text: _buildShareText(),
                          subject: "BreezeFood",
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomSubTitle(
                                subtitle: widget.title.isEmpty
                                    ? "Empty"
                                    : widget.title,
                                color: AppColor.white,
                                fontsize: 16.sp,
                              ),
                            ),
                            Row(
                              children: [
                                if (_hasDiscount) ...[
                                  Text(
                                    context.money(widget.oldPrice),
                                    style: TextStyle(
                                      color: AppColor.red,
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  context.money(widget.price),
                                  style: TextStyle(
                                    color: AppColor.yellow,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: 300.w, // 👈 حدد العرض اللي بدك ياه
                          child: CustomSubTitle(
                            subtitle: widget.description.isEmpty
                                ? "Empty"
                                : widget.description,
                            color: AppColor.gry,
                            fontsize: 10.sp,
                            // اختياري
                          ),
                        ),

                        // divider(),
                        SizedBox(height: 8.h),

                        // ✅ NEW: grouped extras
                        if (widget.extraGroups.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          ExtraGroupsList(
                            groups: widget.extraGroups,
                            selectedChoice: _selectedGroupChoice,
                            onChanged: (groupId, extraId) {
                              setState(() {
                                _selectedGroupChoice[groupId] = extraId;
                              });
                            },
                          ),
                          SizedBox(height: 8.h),
                        ],

                        if (sg != null && sg.items.isNotEmpty) ...[
                          CustomSubTitle(
                            subtitle: "Size".tr(),
                            color: AppColor.white,
                            fontsize: 14.sp,
                          ),
                          SizedBox(height: 10.h),
                          SizeChipsRowGrouped(
                            items: sg.items,
                            selectedId: _selectedSizeExtraId,
                            onSelect: (id) =>
                                setState(() => _selectedSizeExtraId = id),
                          ),
                          SizedBox(height: 8.h),
                        ],

                        if (_otherGroups.isNotEmpty) ...[
                          ExtraGroupsList(
                            groups: _otherGroups,
                            selectedChoice: _selectedGroupChoice,
                            onChanged: (groupId, extraId) {
                              setState(
                                () => _selectedGroupChoice[groupId] = extraId,
                              );
                            },
                          ),
                        ],

                        SizedBox(height: 10.h),
                        CustomSubTitle(
                          subtitle: "cart.item_notes_optional".tr(),
                          color: AppColor.white,
                          fontsize: 14.sp,
                        ),
                        SizedBox(height: 16.h),

                        TextField(
                          controller: _noteCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "cart.item_notes_hint".tr(),
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 28.h, // زيدها حسب ما بدك
                              horizontal: 12.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        CounterSheet(
                          isRestaurantOpen: widget.isRestaurantOpen, // ✅
                          basePrice: widget.price,
                          extrasTotal: _extrasTotal,
                          onAdd: (qty) {
                            final cartCubit = context.read<CartCubit>();
                            final req = AddToCartRequest(
                              restaurantId: widget.restaurantId,
                              menuItemId: widget.menuItemId,
                              quantity: qty,
                              specialNotes: _noteCtrl.text.trim(),

                              withSpicy: _withSpicy,
                              extras: _selectedExtrasPayload(),
                            );

                            // ✅ لا تعمل pop هون
                            cartCubit.add(req);
                          },
                        ),

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget divider({double height = 30}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Divider(color: AppColor.gry, thickness: 0.4, height: height),
    );
  }

  Widget _fallbackImage() {
    return Image.asset(
      "assets/images/shawarma_box.png",
      width: double.infinity,
      height: 220.h,
      fit: BoxFit.cover,
    );
  }
}

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

        final useRadio = g.items.length > 1; // ✅ assumption

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
                        child: Material(
                          color: Colors.transparent,
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
                                      // إلغاء اختيار checkbox الوحيد
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

class ExtrasList extends StatelessWidget {
  final List<MenuExtra> extras;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onChanged;

  const ExtrasList({
    super.key,
    required this.extras,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    return Column(
      children: extras.map((e) {
        final checked = selectedIds.contains(e.id);
        final name = isRTL ? e.nameAr : e.nameEn;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
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
                          value: checked,
                          onChanged: (val) => onChanged(e.id, val ?? false),
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
                ),
              ),
              CustomSubTitle(
                subtitle: context.money(e.price),
                color: AppColor.yellow,
                fontsize: 14,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CounterSheet extends StatefulWidget {
  final double basePrice;
  final double extrasTotal;
  final ValueChanged<int> onAdd;
  final bool isRestaurantOpen; // ✅

  const CounterSheet({
    super.key,
    required this.onAdd,
    required this.basePrice,
    required this.extrasTotal,
    required this.isRestaurantOpen,
  });

  @override
  State<CounterSheet> createState() => _CounterSheetState();
}

class _CounterSheetState extends State<CounterSheet> {
  int count = 1;

  double get total => (widget.basePrice + widget.extrasTotal) * count;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CartCubit>().state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final disabled = isLoading || !widget.isRestaurantOpen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLoading
                            ? null
                            : () => setState(() {
                                if (count > 1) count--;
                              }),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.remove, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomSubTitle(
                      subtitle: "$count",
                      color: AppColor.white,
                      fontsize: 18,
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLoading ? null : () => setState(() => count++),
                        child: const CircleAvatar(
                          backgroundColor: AppColor.primaryColor,
                          radius: 16,
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // button
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: disabled ? null : () => widget.onAdd(count),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            "common.AddToCart".tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 1,
                          height: 16,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          context.money(total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (!widget.isRestaurantOpen) ...[
            SizedBox(height: 8.h),
            Text(
              "restaurant.closed_cannot_add_to_cart".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}



class SizeChipsRowGrouped extends StatelessWidget {
  final List<MenuExtra>
  items; // نفس type تبع items عندك (إذا اسمها مختلف عدّلها)
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const SizeChipsRowGrouped({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  String _chipLabel(BuildContext context, MenuExtra e) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final name = (isRTL ? e.nameAr : e.nameEn).toLowerCase().trim();

    // ✅ mapping ذكي S/M/L
    if (name.contains("small") || name.contains("صغير")) return "S";
    if (name.contains("medium") || name.contains("وسط")) return "M";
    if (name.contains("large") || name.contains("كبير")) return "L";

    // fallback: أول حرف
    final raw = (isRTL ? e.nameAr : e.nameEn).trim();
    if (raw.isEmpty) return "?";
    return raw.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final d = 44.r;

    return SizedBox(
      height: d,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, i) {
          final e = items[i];
          final isSelected = e.id == selectedId;

          return Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () => onSelect(e.id),
              containedInkWell: true,
              highlightShape: BoxShape.circle,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: d,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: isSelected ? AppColor.primaryColor : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _chipLabel(context, e),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
