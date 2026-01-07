import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/share_icon.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/request_order/custom_hot.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
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
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetCtx) {
      final height = MediaQuery.of(sheetCtx).size.height * 0.75;

      // ✅ خذ CartCubit من سياق الصفحة (context) مو sheetCtx
      final cartCubit = context.read<CartCubit>();

      return AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColor.Dark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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

  const AddOrderBody({
    super.key,
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
  bool _withSpicy = false;
  final TextEditingController _noteCtrl = TextEditingController();
  String _buildShareText() {
    final price = widget.price.toStringAsFixed(0);
    final old = widget.oldPrice.toStringAsFixed(0);

    final extrasNames = widget.extras
        .where((e) => _selectedExtrasIds.contains(e.id))
        .map(
          (e) => (Directionality.of(context) == TextDirection.rtl
              ? e.nameAr
              : e.nameEn),
        )
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final extrasLine = extrasNames.isEmpty
        ? ""
        : "\nExtras: ${extrasNames.join(", ")}";

    final spicyLine = _withSpicy ? "\n🌶️ Hot: Yes" : "\n🌶️ Hot: No";

    final note = _noteCtrl.text.trim();
    final noteLine = note.isEmpty ? "" : "\n📝 Notes: $note";

    final discountLine = (widget.oldPrice > widget.price && widget.oldPrice > 0)
        ? "\n💸 Old: $old\$"
        : "";
    final productUrl = "";

    return """
${widget.title}
💰 Price: $price\$$discountLine
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

  final Set<int> _selectedExtrasIds = {};

  List<AddToCartExtraRequest> _selectedExtrasPayload() {
    return _selectedExtrasIds
        .map((id) => AddToCartExtraRequest(extraId: id, quantity: 1))
        .toList();
  }

  bool get _hasDiscount =>
      widget.oldPrice > widget.price && widget.oldPrice > 0;

  bool get _isNetworkImage {
    final s = widget.imagePathOrUrl.trim();
    return s.startsWith("http://") || s.startsWith("https://");
  }

  String _money(double v) => "${v.toStringAsFixed(0)}\$";

  double get _extrasTotal {
    double sum = 0;
    for (final e in widget.extras) {
      if (_selectedExtrasIds.contains(e.id)) sum += e.price;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        // ✅ عدّل أسماء الحالات إذا عندك مختلفة
        state.whenOrNull(
          loading: () {
            EasyLoading.show(status: "Adding...");
          },
          addedSuccess: (message) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess(message);

            // ✅ سكّر الشيت بعد النجاح فقط
            Navigator.of(context).pop(true);
          },
          error: (msg) {
            EasyLoading.dismiss();
            EasyLoading.showError(msg);
          },
        );
      },
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 8.h),

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
                        child: _isNetworkImage
                            ? Image.network(
                                widget.imagePathOrUrl,
                                width: double.infinity,
                                height: 220.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fallbackImage(),
                              )
                            : Image.asset(
                                widget.imagePathOrUrl,
                                width: double.infinity,
                                height: 220.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fallbackImage(),
                              ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        right: 10,
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
                                    _money(widget.oldPrice),
                                    style: TextStyle(
                                      color: AppColor.red,
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  _money(widget.price),
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

                        CustomSubTitle(
                          subtitle: widget.description.isEmpty
                              ? "Empty"
                              : widget.description,
                          color: AppColor.gry,
                          fontsize: 10.sp,
                        ),

                        divider(),

                        SizedBox(height: 8.h),

                        if (widget.extras.isNotEmpty) ...[
                          CustomSubTitle(
                            subtitle: "Extras",
                            color: AppColor.white,
                            fontsize: 14.sp,
                          ),
                          SizedBox(height: 6.h),
                          ExtrasList(
                            extras: widget.extras,
                            selectedIds: _selectedExtrasIds,
                            onChanged: (id, selected) {
                              setState(() {
                                if (selected) {
                                  _selectedExtrasIds.add(id);
                                } else {
                                  _selectedExtrasIds.remove(id);
                                }
                              });
                            },
                          ),
                          divider(),
                        ],

                        CustomSubTitle(
                          subtitle: "Hot?",
                          color: AppColor.white,
                          fontsize: 16.sp,
                        ),
                        CustomHot(
                          value: _withSpicy,
                          onChanged: (v) => setState(() => _withSpicy = v),
                        ),
                        CustomSubTitle(
                          subtitle: "Notes",
                          color: AppColor.white,
                          fontsize: 16.sp,
                        ),
                        SizedBox(height: 8.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.black,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: TextField(
                            controller: _noteCtrl,
                            maxLines: 3,
                            minLines: 2,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 13.sp,
                            ),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText:
                                  "اكتب ملاحظتك (مثلاً: بدون بصل، زيادة ثوم...)",
                              hintStyle: TextStyle(
                                color: Colors.white54,
                                fontSize: 12.sp,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        divider(height: 20),

                        CounterSheet(
                          basePrice: widget.price,
                          extrasTotal: _extrasTotal,
                          onAdd: (qty) {
                            final cartCubit = context.read<CartCubit>();
                            final req = AddToCartRequest(
                              restaurantId: widget.restaurantId,
                              menuItemId: widget.menuItemId,
                              quantity: qty,
                              specialNotes: _noteCtrl.text
                                  .trim(), // ✅ بدل "بدون بصل"
                              withSpicy: _withSpicy,
                              extras: _selectedExtrasPayload(),
                            );

                            // ✅ لا تعمل pop هون
                            cartCubit.add(req);
                          },
                        ),

                        SizedBox(height: 14.h),
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

  Widget divider({double height = 40}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Divider(color: AppColor.gry, thickness: 1.2, height: height),
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
                  child: Row(
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        activeColor: AppColor.primaryColor,
                        side: BorderSide(color: AppColor.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: checked,
                        onChanged: (val) => onChanged(e.id, val ?? false),
                      ),
                      Expanded(
                        child: CustomSubTitle(
                          subtitle: name,
                          color: AppColor.white,
                          fontsize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomSubTitle(
                subtitle: "${e.price.toStringAsFixed(0)}\$",
                color: AppColor.yellow,
                fontsize: 14.sp,
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

  const CounterSheet({
    super.key,
    required this.onAdd,
    required this.basePrice,
    required this.extrasTotal,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  fontsize: 18.sp,
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : () => setState(() => count++),
                    child: const CircleAvatar(
                      backgroundColor: Colors.cyan,
                      radius: 16,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: isLoading ? null : () => widget.onAdd(count),
                child: Text(
                  isLoading ? "ADDING..." : "ADD ${total.toStringAsFixed(0)}\$",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
