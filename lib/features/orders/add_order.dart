// import 'package:breezefood/core/component/app_image.dart';
// import 'package:breezefood/core/component/color.dart';
// import 'package:breezefood/core/component/share_icon.dart';
// import 'package:breezefood/core/services/money.dart';
// import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
// import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
// import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
// import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart' as mt;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// Future<void> showAddOrderDialog(
//   BuildContext context, {
//   required int restaurantId,
//   required int menuItemId,
//   required String title,
//   required double price,
//   required double oldPrice,
//   required String imagePathOrUrl,
//   required String description,
//   required List<MenuExtra> extraMeals,
//   required List<ExtraGrouped> extraGroups,
//   required bool isRestaurantOpen,
// }) async {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     useSafeArea: false,
//     backgroundColor: Colors.transparent,
//     barrierColor: Colors.black.withOpacity(0.6),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//     builder: (sheetCtx) {
//       final height = MediaQuery.of(sheetCtx).size.height * 0.9;

//       // ✅ خذ CartCubit من سياق الصفحة (context) مو sheetCtx
//       final cartCubit = context.read<CartCubit>();

//       return MediaQuery.removePadding(
//         context: sheetCtx,
//         removeTop: true,
//         child: AnimatedPadding(
//           duration: const Duration(milliseconds: 600),
//           // duration: Duration.zero,
//           // curve: Curves.easeOutCubic,
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
//           ),
//           child: Container(
//             height: height,
//             decoration: BoxDecoration(
//               color: AppColor.Dark,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: BlocProvider.value(
//               value: cartCubit, // ✅ نفس instance
//               child: AddOrderBody(
//                 restaurantId: restaurantId,
//                 menuItemId: menuItemId,
//                 title: title,
//                 price: price,
//                 oldPrice: oldPrice,
//                 imagePathOrUrl: imagePathOrUrl,
//                 description: description,
//                 extras: extraMeals,
//                 extraGroups: extraGroups, // ✅ NEW
//                 isRestaurantOpen: isRestaurantOpen,
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// class AddOrderBody extends StatefulWidget {
//   final String title;
//   final double price;
//   final double oldPrice;
//   final String imagePathOrUrl;
//   final String description;
//   final List<MenuExtra> extras;
//   final int restaurantId;
//   final int menuItemId;
//   final bool isRestaurantOpen;
//   final List<ExtraGrouped> extraGroups; // ✅ NEW
//   const AddOrderBody({
//     required this.isRestaurantOpen,

//     super.key,
//     required this.extraGroups, // ✅ NEW
//     required this.restaurantId,
//     required this.menuItemId,
//     required this.title,
//     required this.price,
//     required this.oldPrice,
//     required this.imagePathOrUrl,
//     required this.description,
//     required this.extras,
//   });

//   @override
//   State<AddOrderBody> createState() => _AddOrderBodyState();
// }

// class _AddOrderBodyState extends State<AddOrderBody> {
//   bool _withSpicy = false;
//   bool _highlightSizeRequired = false; // ✅ NEW
//   final Map<int, int> _selectedGroupChoice = {};

//   // ✅ NEW: groupId -> selected extraIds (إذا بدك multi لاحقاً)
//   final TextEditingController _noteCtrl = TextEditingController();
//   String _buildShareText() {
//     final price = context.money(widget.price);
//     final old = context.money(widget.oldPrice);

//     final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

//     final legacyNames = widget.extras
//         .where((e) => _selectedExtrasIds.contains(e.id))
//         .map((e) => isRTL ? e.nameAr : e.nameEn)
//         .where((s) => s.trim().isNotEmpty)
//         .toList();

//     final groupedSelectedIds = _selectedGroupChoice.values.toSet();
//     final groupedNames = widget.extraGroups
//         .expand((g) => g.items)
//         .where((e) => groupedSelectedIds.contains(e.id))
//         .map((e) => isRTL ? e.nameAr : e.nameEn)
//         .where((s) => s.trim().isNotEmpty)
//         .toList();

//     final extrasNames = [...groupedNames, ...legacyNames];

//     final extrasLine = extrasNames.isEmpty
//         ? ""
//         : "\nExtras: ${extrasNames.join(", ")}";

//     final spicyLine = _withSpicy ? "\n🌶️ Hot: Yes" : "\n🌶️ Hot: No";

//     final note = _noteCtrl.text.trim();
//     final noteLine = note.isEmpty ? "" : "\n📝 Notes: $note";

//     final discountLine = (widget.oldPrice > widget.price && widget.oldPrice > 0)
//         ? "\n💸 Old: $old"
//         : "";
//     final productUrl = "";

//     return """
// ${widget.title}
// 💰 Price: $price$discountLine
// $spicyLine
// $extrasLine$noteLine
// ${productUrl.isEmpty ? "" : "\n$productUrl"}
// """
//         .trim();
//   }

//   @override
//   void dispose() {
//     _noteCtrl.dispose();
//     super.dispose();
//   }

//   ExtraGrouped? get _sizeGroup {
//     bool isSizeGroup(ExtraGrouped g) {
//       final ar = (g.nameAr ?? "").toLowerCase().trim();
//       final en = (g.nameEn ?? "").toLowerCase().trim();

//       // group_id أحياناً 0 وعنوانه null، فنعتمد على الاسم إذا موجود
//       return en.contains("size") || ar.contains("حجم") || ar.contains("الحجم");
//     }

//     for (final g in widget.extraGroups) {
//       if (isSizeGroup(g)) return g;
//     }
//     return null;
//   }

//   List<ExtraGrouped> get _otherGroups {
//     final sg = _sizeGroup;
//     if (sg == null) return widget.extraGroups;
//     return widget.extraGroups.where((g) => g.groupId != sg.groupId).toList();
//   }

//   int? _selectedSizeExtraId; // ✅ extraId تبع الحجم (من grouped)

//   final Set<int> _selectedExtrasIds = {};
//   List<AddToCartExtraRequest> _selectedExtrasPayload() {
//     final ids = <int>{};

//     // ✅ size من grouped
//     if (_selectedSizeExtraId != null) ids.add(_selectedSizeExtraId!);

//     // ✅ باقي الـ grouped
//     ids.addAll(_selectedGroupChoice.values);

//     return ids
//         .map((id) => AddToCartExtraRequest(extraId: id, quantity: 1))
//         .toList();
//   }

//   double get _extrasTotal {
//     double sum = 0;

//     // ✅ size grouped
//     final sg = _sizeGroup;
//     if (sg != null && _selectedSizeExtraId != null) {
//       final it = sg.items.firstWhere(
//         (x) => x.id == _selectedSizeExtraId,
//         orElse: () => sg.items.first,
//       );
//       sum += it.price;
//     }

//     // ✅ باقي الـ grouped
//     final selectedGroupedIds = _selectedGroupChoice.values.toSet();
//     for (final g in _otherGroups) {
//       for (final it in g.items) {
//         if (selectedGroupedIds.contains(it.id)) sum += it.price;
//       }
//     }

//     return sum;
//   }

//   bool get _hasDiscount =>
//       widget.oldPrice > widget.price && widget.oldPrice > 0;

//   bool get _isNetworkImage {
//     final s = widget.imagePathOrUrl.trim();
//     return s.startsWith("http://") || s.startsWith("https://");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sg = _sizeGroup;
//     return BlocListener<CartCubit, CartState>(
//       listener: (context, state) {
//         state.whenOrNull(
//           addedSuccess: (message) async {
//             EasyLoading.showSuccess(message);

//             if (context.mounted) Navigator.of(context).pop(true);
//           },
//           error: (msg) {
//             EasyLoading.showError(msg);
//           },
//         );
//       },
//       child: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(24.r),
//                         ),
//                         child: AppNetworkImage(
//                           path: widget.imagePathOrUrl,
//                           width: double.infinity,
//                           height: 400.h,
//                           fit: BoxFit.cover,
//                           // useOldImageOnUrlChange: true,
//                         ),
//                       ),

//                       PositionedDirectional(
//                         top: 5,
//                         end: 1,
//                         child: IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           style: ButtonStyle(
//                             backgroundColor: WidgetStateProperty.all(
//                               Colors.black54,
//                             ),
//                             padding: WidgetStateProperty.all(EdgeInsets.zero),
//                             minimumSize: WidgetStateProperty.all(
//                               const Size(30, 30),
//                             ),
//                             fixedSize: WidgetStateProperty.all(
//                               const Size(30, 30),
//                             ),
//                           ),
//                         ),
//                       ),

//                       PositionedDirectional(
//                         bottom: 5,
//                         end: 10,
//                         child: AppShareFab(
//                           text: _buildShareText(),
//                           subject: "BreezeFood",
//                         ),
//                       ),
//                     ],
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 12,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: CustomSubTitle(
//                                 subtitle: widget.title.isEmpty
//                                     ? "Empty"
//                                     : widget.title,
//                                 color: AppColor.white,
//                                 fontsize: 16.sp,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 if (_hasDiscount) ...[
//                                   Text(
//                                     context.money(widget.oldPrice),
//                                     style: TextStyle(
//                                       color: AppColor.red,
//                                       fontSize: 12.sp,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                   SizedBox(width: 8.w),
//                                 ],
//                                 Text(
//                                   context.money(widget.price),
//                                   style: TextStyle(
//                                     color: AppColor.yellow,
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                         SizedBox(
//                           width: 300.w, // 👈 حدد العرض اللي بدك ياه
//                           child: CustomSubTitle(
//                             subtitle: widget.description.isEmpty
//                                 ? "Empty"
//                                 : widget.description,
//                             color: AppColor.gry,
//                             fontsize: 10.sp,
//                           ),
//                         ),

//                         SizedBox(height: 8.h),

//                         if (widget.extraGroups.isNotEmpty) ...[
//                           SizedBox(height: 8.h),

//                           if (sg != null && sg.items.isNotEmpty) ...[
//                             RequiredSizeGroupList(
//                               group: sg,
//                               selectedExtraId: _selectedSizeExtraId,
//                               highlightRequired:
//                                   _highlightSizeRequired, // ✅ NEW
//                               onSelect: (id) => setState(() {
//                                 _selectedSizeExtraId = id;
//                                 _highlightSizeRequired =
//                                     false; // ✅ يطفي بعد الاختيار
//                               }),
//                             ),
//                             SizedBox(height: 12.h),
//                           ],

//                           // ✅ باقي الجروبات
//                           if (_otherGroups.isNotEmpty)
//                             ExtraGroupsList(
//                               groups: _otherGroups,
//                               selectedChoice: _selectedGroupChoice,
//                               onChanged: (groupId, extraId) {
//                                 setState(
//                                   () => _selectedGroupChoice[groupId] = extraId,
//                                 );
//                               },
//                             ),

//                           SizedBox(height: 8.h),
//                         ],

//                         SizedBox(height: 10.h),
//                         CustomSubTitle(
//                           subtitle: "cart.item_notes_optional".tr(),
//                           color: AppColor.white,
//                           fontsize: 14.sp,
//                         ),
//                         SizedBox(height: 16.h),

//                         TextField(
//                           controller: _noteCtrl,
//                           maxLines: 2,
//                           style: const TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             hintText: "cart.item_notes_hint".tr(),
//                             hintStyle: TextStyle(
//                               color: Colors.white54,
//                               fontSize: 12.sp,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white10,
//                             contentPadding: EdgeInsets.symmetric(
//                               vertical: 28.h, // زيدها حسب ما بدك
//                               horizontal: 12.w,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         CounterSheet(
//                           isRestaurantOpen: widget.isRestaurantOpen,
//                           basePrice: widget.price,
//                           extrasTotal: _extrasTotal,

//                           isSizeRequired: sg != null && sg.items.isNotEmpty,
//                           isSizeSelected: _selectedSizeExtraId != null,

//                           onMissingSize: () {
//                             setState(
//                               () => _highlightSizeRequired = true,
//                             ); // ✅ هون بتشتغل حركة Required
//                           },

//                           onAdd: (qty) {
//                             final cartCubit = context.read<CartCubit>();
//                             final req = AddToCartRequest(
//                               restaurantId: widget.restaurantId,
//                               menuItemId: widget.menuItemId,
//                               quantity: qty,
//                               specialNotes: _noteCtrl.text.trim(),
//                               withSpicy: _withSpicy,
//                               extras: _selectedExtrasPayload(),
//                             );
//                             cartCubit.add(req);
//                           },
//                         ),

//                         SizedBox(height: 8.h),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget divider({double height = 30}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       child: Divider(color: AppColor.gry, thickness: 0.4, height: height),
//     );
//   }
// }

// class ExtraGroupsList extends StatelessWidget {
//   final List<ExtraGrouped> groups;
//   final Map<int, int> selectedChoice; // groupId -> extraId
//   final void Function(int groupId, int extraId) onChanged;

//   const ExtraGroupsList({
//     super.key,
//     required this.groups,
//     required this.selectedChoice,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

//     String groupTitle(ExtraGrouped g) {
//       final t = isRTL ? (g.nameAr ?? "") : (g.nameEn ?? "");
//       return t.trim().isEmpty ? (isRTL ? "إضافات" : "Extras") : t;
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: groups.map((g) {
//         final title = groupTitle(g);
//         final chosenId = selectedChoice[g.groupId];

//         final useRadio = g.items.length > 1; // ✅ assumption

//         return Padding(
//           padding: EdgeInsets.only(bottom: 10.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomSubTitle(
//                 subtitle: title,
//                 color: AppColor.Lightgry,
//                 fontsize: 13,
//               ),
//               SizedBox(height: 6.h),

//               ...g.items.map((it) {
//                 final name = isRTL ? it.nameAr : it.nameEn;

//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: 3.h),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Material(
//                           color: Colors.transparent,
//                           child: Row(
//                             children: [
//                               if (useRadio)
//                                 Radio<int>(
//                                   value: it.id,
//                                   groupValue: chosenId,
//                                   activeColor: AppColor.primaryColor,
//                                   visualDensity: const VisualDensity(
//                                     horizontal: -4,
//                                     vertical: -4,
//                                   ),
//                                   onChanged: (val) {
//                                     if (val == null) return;
//                                     onChanged(g.groupId, val);
//                                   },
//                                 )
//                               else
//                                 Checkbox(
//                                   materialTapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                   visualDensity: const VisualDensity(
//                                     horizontal: -4,
//                                     vertical: -4,
//                                   ),
//                                   activeColor: AppColor.primaryColor,
//                                   side: BorderSide(
//                                     color: AppColor.Lightgry,
//                                     width: 1.5,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   value: chosenId == it.id,
//                                   onChanged: (val) {
//                                     if (val == true) {
//                                       onChanged(g.groupId, it.id);
//                                     } else {
//                                       selectedChoice.remove(g.groupId);
//                                     }
//                                   },
//                                 ),

//                               Expanded(
//                                 child: CustomSubTitle(
//                                   subtitle: name,
//                                   color: AppColor.Lightgry,
//                                   fontsize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       CustomSubTitle(
//                         subtitle: context.money(it.price),
//                         color: AppColor.yellow,
//                         fontsize: 14,
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class ExtrasList extends StatelessWidget {
//   final List<MenuExtra> extras;
//   final Set<int> selectedIds;
//   final void Function(int id, bool selected) onChanged;

//   const ExtrasList({
//     super.key,
//     required this.extras,
//     required this.selectedIds,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

//     return Column(
//       children: extras.map((e) {
//         final checked = selectedIds.contains(e.id);
//         final name = isRTL ? e.nameAr : e.nameEn;

//         return Padding(
//           padding: EdgeInsets.symmetric(vertical: 3.h),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: 2.h),
//                     child: Row(
//                       children: [
//                         Checkbox(
//                           materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                           visualDensity: const VisualDensity(
//                             horizontal: -4,
//                             vertical: -4,
//                           ),
//                           activeColor: AppColor.primaryColor,
//                           side: BorderSide(
//                             color: AppColor.Lightgry,
//                             width: 1.5,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           value: checked,
//                           onChanged: (val) => onChanged(e.id, val ?? false),
//                         ),
//                         Expanded(
//                           child: CustomSubTitle(
//                             subtitle: name,
//                             color: AppColor.Lightgry,
//                             fontsize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               CustomSubTitle(
//                 subtitle: context.money(e.price),
//                 color: AppColor.yellow,
//                 fontsize: 14,
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class CounterSheet extends StatefulWidget {
//   final double basePrice;
//   final double extrasTotal;
//   final ValueChanged<int> onAdd;
//   final bool isRestaurantOpen;

//   final bool isSizeRequired;
//   final bool isSizeSelected;

//   // ✅ NEW: لتشغيل badge required فوق
//   final VoidCallback? onMissingSize;

//   const CounterSheet({
//     super.key,
//     required this.onAdd,
//     required this.basePrice,
//     required this.extrasTotal,
//     required this.isRestaurantOpen,
//     required this.isSizeRequired,
//     required this.isSizeSelected,
//     this.onMissingSize,
//   });

//   @override
//   State<CounterSheet> createState() => _CounterSheetState();
// }

// class _CounterSheetState extends State<CounterSheet>
//     with SingleTickerProviderStateMixin {
//   int count = 1;

//   late final AnimationController _shakeCtrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 420),
//   );

//   late final Animation<double> _shake = TweenSequence<double>([
//     TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
//     TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
//     TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
//     TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
//     TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
//   ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

//   bool _showSizeHint = false;

//   double get total => (widget.basePrice + widget.extrasTotal) * count;

//   @override
//   void didUpdateWidget(covariant CounterSheet oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isSizeSelected && _showSizeHint) {
//       setState(() => _showSizeHint = false);
//     }
//   }

//   @override
//   void dispose() {
//     _shakeCtrl.dispose();
//     super.dispose();
//   }

//   void _requireSizeFeedback() {
//     if (!_showSizeHint) setState(() => _showSizeHint = true);
//     _shakeCtrl.forward(from: 0);
//     widget.onMissingSize?.call(); // ✅ هون بنشغل انيميشن الـ Required
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = context.watch<CartCubit>().state.maybeWhen(
//       loading: () => true,
//       orElse: () => false,
//     );

//     final baseDisabled = isLoading || !widget.isRestaurantOpen;

//     final sizeBlocked = widget.isSizeRequired && !widget.isSizeSelected;
//     final canAdd = !baseDisabled && !sizeBlocked;

//     final btnColor = canAdd ? AppColor.primaryColor : AppColor.red;

//     final btnText = sizeBlocked
//         ? (context.locale.languageCode == "ar"
//               ? "اختر الحجم (مطلوب)"
//               : "Select size (required)")
//         : "common.AddToCart".tr();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               // ✅ COUNTER (رجعناه)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColor.black,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: isLoading
//                             ? null
//                             : () => setState(() {
//                                 if (count > 1) count--;
//                               }),
//                         child: const CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 16,
//                           child: Icon(Icons.remove, color: Colors.black),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     CustomSubTitle(
//                       subtitle: "$count",
//                       color: AppColor.white,
//                       fontsize: 18,
//                     ),
//                     const SizedBox(width: 10),
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: isLoading ? null : () => setState(() => count++),
//                         child: const CircleAvatar(
//                           backgroundColor: AppColor.primaryColor,
//                           radius: 16,
//                           child: Icon(Icons.add, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 8),

//               // ✅ BUTTON (مع shake)
//               Expanded(
//                 child: SizedBox(
//                   height: 50.h,
//                   child: AnimatedBuilder(
//                     animation: _shakeCtrl,
//                     builder: (context, child) {
//                       return Transform.translate(
//                         offset: Offset(_shake.value, 0),
//                         child: child,
//                       );
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 220),
//                       curve: Curves.easeOutCubic,
//                       decoration: BoxDecoration(
//                         color: btnColor,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(12.r),
//                           onTap: () {
//                             if (baseDisabled) return;

//                             if (sizeBlocked) {
//                               _requireSizeFeedback();
//                               return;
//                             }

//                             widget.onAdd(count);
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 10.w),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Flexible(
//                                   child: AnimatedSwitcher(
//                                     duration: const Duration(milliseconds: 180),
//                                     transitionBuilder: (c, a) =>
//                                         FadeTransition(opacity: a, child: c),
//                                     child: Text(
//                                       btnText,
//                                       key: ValueKey(btnText),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: AppColor.white,
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w700,
//                                         letterSpacing: 0.3,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 6.w),
//                                 Container(
//                                   width: 1,
//                                   height: 16,
//                                   color: Colors.white.withOpacity(0.5),
//                                 ),
//                                 SizedBox(width: 6.w),
//                                 Text(
//                                   context.money(total),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     color: AppColor.white,
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // ✅ hint under button
//           if (_showSizeHint && sizeBlocked) ...[
//             SizedBox(height: 8.h),
//             Text(
//               context.locale.languageCode == "ar"
//                   ? "اختيار الحجم مطلوب"
//                   : "Size selection is required",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColor.red,
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],

//           // ✅ restaurant closed message
//           if (!widget.isRestaurantOpen) ...[
//             SizedBox(height: 8.h),
//             Text(
//               "restaurant.closed_cannot_add_to_cart".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColor.red,
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class RequiredSizeGroupList extends StatelessWidget {
//   final ExtraGrouped group;
//   final int? selectedExtraId;
//   final ValueChanged<int> onSelect;

//   final bool highlightRequired; // ✅ NEW

//   const RequiredSizeGroupList({
//     super.key,
//     required this.group,
//     required this.selectedExtraId,
//     required this.onSelect,
//     required this.highlightRequired, // ✅ NEW
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

//     String title() {
//       final t = isRTL ? (group.nameAr ?? "") : (group.nameEn ?? "");
//       return t.trim().isEmpty ? (isRTL ? "الحجم" : "Size") : t;
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             CustomSubTitle(
//               subtitle: title(),
//               color: AppColor.Lightgry,
//               fontsize: 13,
//             ),
//             SizedBox(width: 8.w),

//             RequiredBadgeAnimated(
//               isRTL: isRTL,
//               animate: highlightRequired && (selectedExtraId == null),
//               isSelected: selectedExtraId != null,
//             ),
//           ],
//         ),
//         SizedBox(height: 6.h),

//         ...group.items.map((it) {
//           final name = isRTL ? it.nameAr : it.nameEn;

//           return Padding(
//             padding: EdgeInsets.symmetric(vertical: 3.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Material(
//                     color: Colors.transparent,
//                     child: Row(
//                       children: [
//                         Radio<int>(
//                           value: it.id,
//                           groupValue: selectedExtraId,
//                           activeColor: AppColor.primaryColor,
//                           visualDensity: const VisualDensity(
//                             horizontal: -4,
//                             vertical: -4,
//                           ),
//                           onChanged: (val) {
//                             if (val == null) return;
//                             onSelect(val);
//                           },
//                         ),
//                         Expanded(
//                           child: CustomSubTitle(
//                             subtitle: name,
//                             color: AppColor.Lightgry,
//                             fontsize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 CustomSubTitle(
//                   subtitle: context.money(it.price),
//                   color: AppColor.yellow,
//                   fontsize: 14,
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }

// class RequiredBadgeAnimated extends StatefulWidget {
//   final bool isRTL;

//   /// ✅ شغّل الانيميشن التحذيري فقط لما لازم يختار (مثلاً بعد ضغط Add بدون size)
//   final bool animate;

//   /// ✅ إذا اختار: تتحول لـ Done + ✅ أخضر
//   final bool isSelected;

//   final String? requiredAr;
//   final String? requiredEn;
//   final String? doneAr;
//   final String? doneEn;

//   const RequiredBadgeAnimated({
//     super.key,
//     required this.isRTL,
//     required this.animate,
//     required this.isSelected,
//     this.requiredAr,
//     this.requiredEn,
//     this.doneAr,
//     this.doneEn,
//   });

//   @override
//   State<RequiredBadgeAnimated> createState() => _RequiredBadgeAnimatedState();
// }

// class _RequiredBadgeAnimatedState extends State<RequiredBadgeAnimated>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 900),
//   );

//   late final Animation<double> _scale = Tween<double>(
//     begin: 1.0,
//     end: 1.08,
//   ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

//   late final Animation<double> _pop = Tween<double>(
//     begin: 0.94,
//     end: 1.0,
//   ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

//   bool _didPopOnce = false;

//   @override
//   void initState() {
//     super.initState();
//     if (!widget.isSelected && widget.animate) {
//       _ctrl.repeat(reverse: true);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant RequiredBadgeAnimated oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // ✅ إذا صار مختار: وقف الانيميشن التحذيري واعمل pop مرة وحدة
//     if (!oldWidget.isSelected && widget.isSelected) {
//       _ctrl.stop();
//       _ctrl.value = 0;
//       _didPopOnce = false;
//       _playPopOnce();
//       return;
//     }

//     // ✅ لو مو مختار ولسا بدنا تحذير
//     if (!widget.isSelected && widget.animate) {
//       if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
//     } else {
//       if (_ctrl.isAnimating) {
//         _ctrl.stop();
//         _ctrl.value = 0;
//       }
//     }
//   }

//   Future<void> _playPopOnce() async {
//     if (_didPopOnce) return;
//     _didPopOnce = true;

//     // play a quick pop using the same controller
//     _ctrl.duration = const Duration(milliseconds: 520);
//     await _ctrl.forward(from: 0);
//     _ctrl.value = 0;

//     // restore default duration for future warning pulse
//     _ctrl.duration = const Duration(milliseconds: 900);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDone = widget.isSelected;

//     final requiredLabel = widget.isRTL
//         ? (widget.requiredAr ?? "مطلوب")
//         : (widget.requiredEn ?? "Required");

//     final doneLabel = widget.isRTL
//         ? (widget.doneAr ?? "تم")
//         : (widget.doneEn ?? "Done");

//     // ✅ ألوان حسب الحالة
//     final bg = isDone
//         ? Colors.green.withOpacity(0.14)
//         : AppColor.red.withOpacity(0.12);

//     final border = isDone
//         ? Colors.green.withOpacity(0.75)
//         : AppColor.red.withOpacity(widget.animate ? 0.9 : 0.6);

//     final textColor = isDone ? Colors.green : AppColor.red;

//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (context, _) {
//         // تحذير = pulse، تم = pop خفيف
//         final scale = isDone
//             ? (_didPopOnce ? 1.0 : _pop.value)
//             : (widget.animate ? _scale.value : 1.0);

//         return Transform.scale(
//           scale: scale,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 220),
//             curve: Curves.easeOutCubic,
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//             decoration: BoxDecoration(
//               color: bg,
//               borderRadius: BorderRadius.circular(999),
//               border: Border.all(
//                 color: border,
//                 width: isDone ? 1.15 : (widget.animate ? 1.15 : 1.0),
//               ),
//               boxShadow: [
//                 if (!isDone && widget.animate)
//                   BoxShadow(
//                     color: AppColor.red.withOpacity(0.35),
//                     blurRadius: 14,
//                     spreadRadius: 0.5,
//                   ),
//                 if (isDone)
//                   BoxShadow(
//                     color: Colors.green.withOpacity(0.25),
//                     blurRadius: 12,
//                     spreadRadius: 0.4,
//                   ),
//               ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (isDone) ...[
//                   Icon(Icons.check_circle, size: 14.sp, color: Colors.green),
//                   SizedBox(width: 6.w),
//                 ],
//                 Text(
//                   isDone ? doneLabel : requiredLabel,
//                   style: TextStyle(
//                     color: textColor,
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
