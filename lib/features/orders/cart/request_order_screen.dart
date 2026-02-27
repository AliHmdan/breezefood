import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/services/money.dart';

import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/orders/model/cart_response.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';
import 'package:breezefood/features/orders/payment_method.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';

import 'package:breezefood/features/orders/request_order/counter_request.dart';
import 'package:breezefood/features/orders/request_order/meal_card.dart';
import 'package:breezefood/features/orders/request_order/total.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'address_section.dart';
import 'location_helper.dart';
import 'temp_address_map_picker.dart';

class RequestOrderScreen extends StatefulWidget {
  const RequestOrderScreen({super.key});

  @override
  State<RequestOrderScreen> createState() => _RequestOrderScreenState();
}

class _RequestOrderScreenState extends State<RequestOrderScreen> {
  // ✅ address (always current unless user changes)
  OrderAddress? _tempOrderAddress;
  final TextEditingController _tempDetailsCtrl = TextEditingController();
  final FocusNode _tempDetailsFocus = FocusNode();

  // ✅ order notes
  final TextEditingController _orderNotesCtrl = TextEditingController();

  // ✅ per-item notes
  final Map<int, String> _itemNotes = {}; // key = cartItemId

  // ✅ delivery type
  String _deliveryType = "delivery"; // "pickup" | "delivery"

  String _selectedPayment = 'cash';

  final methods = const [
    PaymentMethod(
      id: 'cash',
      title: 'Cash',
      imageAsset: 'assets/images/cash.png',
      imageWidth: 36,
      imageHeight: 24,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillCurrentLocation();
    });
  }

  @override
  void dispose() {
    _tempDetailsCtrl.dispose();
    _tempDetailsFocus.dispose();
    _orderNotesCtrl.dispose();
    super.dispose();
  }

  // ----------------------------
  // Location behavior
  // ----------------------------

  Future<void> _prefillCurrentLocation() async {
    if (_tempOrderAddress != null) return;

    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    // 1) ✅ Try effective saved location (cart -> user)
    final saved = await AuthStorageHelper.getEffectiveCartLocation();
    if (!mounted) return;

    if (saved != null) {
      final text = (saved["text"] ?? "").toString().trim();
      final lat = (saved["lat"] as num).toDouble();
      final lon = (saved["lon"] as num).toDouble();

      final fallback = isRTL ? "موقعي الحالي" : "My current location";
      final finalText = text.isNotEmpty ? text : fallback;

      setState(() {
        _tempOrderAddress = OrderAddress(
          text: finalText,
          latitude: lat,
          longitude: lon,
        );
        _tempDetailsCtrl.text = finalText;
      });
      return;
    }

    // 2) ✅ Fallback to GPS
    try {
      final pos = await LocationHelper.getCurrentPosition();
      if (!mounted) return;

      final fallback = isRTL ? "موقعي الحالي" : "My current location";

      final text = await LocationHelper.reverseGeocodeText(
        lat: pos.latitude,
        lng: pos.longitude,
        fallback: fallback,
      );

      setState(() {
        _tempOrderAddress = OrderAddress(
          text: text,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        _tempDetailsCtrl.text = text;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? "تعذر تحديد موقعك الحالي، اضغط تغيير لاختيار موقع"
                : "Couldn't get your location. Tap Change to pick one.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeLocation({required bool isRTL}) async {
    final init = _tempOrderAddress == null
        ? null
        : LatLng(_tempOrderAddress!.latitude, _tempOrderAddress!.longitude);

    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => TempAddressMapPicker(isRTL: isRTL, initial: init),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _tempOrderAddress = OrderAddress(
        text: (result["text"] ?? "").toString(),
        latitude: (result["lat"] as num).toDouble(),
        longitude: (result["lng"] as num).toDouble(),
      );
      _tempDetailsCtrl.text = _tempOrderAddress!.text;
    });

    await AuthStorageHelper.saveCartLocation(
      text: _tempOrderAddress!.text,
      lat: _tempOrderAddress!.latitude,
      lon: _tempOrderAddress!.longitude,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tempDetailsFocus.requestFocus();
    });
  }

  // ----------------------------
  // Item note dialog
  // ----------------------------

  Future<void> _editItemNote({
    required bool isRTL,
    required CartItem item,
  }) async {
    final ctrl = TextEditingController(text: _itemNotes[item.id] ?? "");

    // final ok = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     backgroundColor: AppColor.black,
    //     title: Text(
    //       isRTL ? "ملاحظة للوجبة" : "Item note",
    //       style: const TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.w700,
    //       ),
    //     ),
    //     content: TextField(
    //       controller: ctrl,
    //       maxLines: 3,
    //       style: const TextStyle(color: Colors.white),
    //       decoration: InputDecoration(
    //         hintText: isRTL
    //             ? "مثلاً: بدون بصل، سبايسي خفيف..."
    //             : "e.g. No onion, mild spicy...",
    //         hintStyle: const TextStyle(color: Colors.white54),
    //         filled: true,
    //         fillColor: Colors.white10,
    //         border: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(12.r),
    //           borderSide: BorderSide.none,
    //         ),
    //       ),
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: Text(isRTL ? "إلغاء" : "Cancel"),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: Text(isRTL ? "حفظ" : "Save"),
    //       ),
    //     ],
    //   ),
    // );

    // if (ok == true) {
    //   setState(() {
    //     final v = ctrl.text.trim();
    //     if (v.isEmpty) {
    //       _itemNotes.remove(item.id);
    //     } else {
    //       _itemNotes[item.id] = v;
    //     }
    //   });
    // }
  }

  // ----------------------------
  // Delete confirmation
  // ----------------------------

  Future<bool> _confirmDelete(
    BuildContext context, {
    required bool isRTL,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              isRTL ? "حذف العنصر؟" : "Delete item?",
              style: TextStyle(color: colorScheme.onSurface),
            ),
            content: Text(
              isRTL
                  ? "هل تريد حذف هذا العنصر من السلة؟"
                  : "Do you want to remove this item from cart?",
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isRTL ? "إلغاء" : "Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(isRTL ? "حذف" : "Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ----------------------------
  // Build order request
  // ----------------------------

  List<OrderExtraRequest> _extrasPayload(CartItem it) {
    return it.extras
        .map((e) => OrderExtraRequest(extraId: e.extraId, quantity: e.quantity))
        .toList();
  }

  Future<void> _storeOrder(
    BuildContext context,
    CartResponse cart,
    String paymentId,
  ) async {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    final hasTemp =
        _tempOrderAddress != null &&
        _tempOrderAddress!.latitude != 0 &&
        _tempOrderAddress!.longitude != 0;

    if (_deliveryType == "delivery" && !hasTemp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? "تعذر تحديد عنوان. اضغط تغيير لاختيار موقع"
                : "No address. Tap Change to pick a location",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final addressToSend = _tempOrderAddress!;

    // items
    final items = cart.items.map((it) {
      return OrderItemRequest(
        menuItemId: it.menuItemId,
        quantity: it.quantity,
        specialNotes: (it.specialNotes ?? "").trim(),

        extras: _extrasPayload(it),
      );
    }).toList();

    final req = StoreOrderRequest(
      restaurantId: cart.restaurantId,
      deliveryType: _deliveryType,
      paymentMethod: paymentId,
      notes: _orderNotesCtrl.text.trim(),
      deliveryFee: cart.deliveryAfter,
      address: addressToSend,
      items: items,
      appetizers: const [],
    );

    context.read<OrderFlowCubit>().store(req);
  }

  // ----------------------------
  // UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final title = state.maybeWhen(
                cartLoaded: (cart, updatingIds, toast, isRefreshing) =>
                    cart.restaurantName.isNotEmpty
                    ? cart.restaurantName
                    : (isRTL ? "سلّتي" : "My Cart"),
                orElse: () => isRTL ? "سلّتي" : "My Cart",
              );

              return CustomAppbarProfile(
                title: title,
                icon: Icons.arrow_back_ios,
                ontap: () => Navigator.pop(context),
                backgroundcolor: Colors.transparent,
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_auth.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: colorScheme.surface.withOpacity(0.85)),
          ),
          SafeArea(
            child: BlocListener<OrderFlowCubit, OrderFlowState>(
              listener: (context, state) async {
                await state.maybeWhen(
                  loading: () async {
                    if (!EasyLoading.isShow) {
                      EasyLoading.show(
                        status: isRTL
                            ? "جارٍ إرسال الطلب..."
                            : "Placing order...",
                      );
                    }
                  },
                  success: (orderId, status, pricing, raw) async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                    if (!context.mounted) return;

                    await AppDialog.showSuccessDialog(
                      title: isRTL
                          ? "تم إرسال الطلب بنجاح"
                          : "Order placed successfully",
                      message: isRTL
                          ? "رقم الطلب: #$orderId\nالحالة: $status"
                          : "Order ID: #$orderId\nStatus: $status",
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  },
                  error: (msg) async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isRTL ? "❌ فشل إنشاء الطلب: $msg" : "❌ Failed: $msg",
                        ),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  orElse: () async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                  },
                );
              },
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (msg) => Center(
                      child: Text(
                        msg,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                    cartLoaded: (cart, updatingIds, toast, isRefreshing) {
                      final isPlacingOrder = context
                          .watch<OrderFlowCubit>()
                          .state
                          .maybeWhen(loading: () => true, orElse: () => false);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          child: Column(
                            children: [
                              if (toast != null && toast.trim().isNotEmpty)
                                _ToastBox(toast: toast),

                              SizedBox(height: 10.h),

                              if (cart.items.isEmpty)
                                _EmptyCart(isRTL: isRTL)
                              else
                                _CartItemsSection(
                                  cart: cart,
                                  isRTL: isRTL,
                                  updatingIds: updatingIds,
                                  itemNotes: _itemNotes,
                                  onEditNote: (it) =>
                                      _editItemNote(isRTL: isRTL, item: it),
                                  onDelete: (it) async {
                                    final ok = await _confirmDelete(
                                      context,
                                      isRTL: isRTL,
                                    );
                                    if (!ok) return;

                                    context.read<CartCubit>().removeItem(it.id);
                                    setState(() => _itemNotes.remove(it.id));
                                  },
                                  onQtyChange: (it, newQty) {
                                    context.read<CartCubit>().updateQty(
                                      cartItemId: it.id,
                                      quantity: newQty,
                                    );
                                  },
                                ),

                              SizedBox(height: 10.h),

                              _TotalsSection(cart: cart),

                              SizedBox(height: 10.h),

                              if (_deliveryType == "delivery") ...[
                                AddressSection(
                                  isRTL: isRTL,
                                  address: _tempOrderAddress,
                                  onChangeTap: () =>
                                      _changeLocation(isRTL: isRTL),
                                  detailsCtrl: _tempDetailsCtrl,
                                  detailsFocus: _tempDetailsFocus,
                                  onDetailsChanged: (v) {
                                    if (_tempOrderAddress == null) return;
                                    setState(() {
                                      _tempOrderAddress = OrderAddress(
                                        text: v.trim(),
                                        latitude: _tempOrderAddress!.latitude,
                                        longitude: _tempOrderAddress!.longitude,
                                      );
                                    });
                                  },
                                ),
                                SizedBox(height: 10.h),
                              ],

                              _OrderNotesSection(
                                ctrl: _orderNotesCtrl,
                                isRTL: isRTL,
                              ),

                              SizedBox(height: 10.h),

                              PaymentMethodSection(
                                amountText: context.money(cart.grandAfter),
                                methods: methods,
                                initialSelectedId: _selectedPayment,
                                onChanged: (id) =>
                                    setState(() => _selectedPayment = id),
                                onOrder: isPlacingOrder
                                    ? null
                                    : (paymentId) =>
                                          _storeOrder(context, cart, paymentId),
                              ),

                              SizedBox(height: 18.h),
                            ],
                          ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// Sections widgets
// ----------------------------

class _ToastBox extends StatelessWidget {
  final String toast;
  const _ToastBox({required this.toast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.error.withOpacity(0.35)),
      ),
      child: Text(
        toast,
        style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 12),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final bool isRTL;
  const _EmptyCart({required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
      child: Text(
        isRTL ? "السلة فارغة" : "Cart is empty",
        style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
      ),
    );
  }
}

class _CartItemsSection extends StatelessWidget {
  final CartResponse cart;
  final bool isRTL;
  final Set<int> updatingIds;
  final Map<int, String> itemNotes;

  final void Function(CartItem it) onEditNote;
  final void Function(CartItem it) onDelete;
  final void Function(CartItem it, int newQty) onQtyChange;

  const _CartItemsSection({
    required this.cart,
    required this.isRTL,
    required this.updatingIds,
    required this.itemNotes,
    required this.onEditNote,
    required this.onDelete,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: cart.items.map((it) {
        final isUpdating = updatingIds.contains(it.id);

        final title = isRTL
            ? (it.nameAr.trim().isNotEmpty ? it.nameAr : it.nameEn)
            : (it.nameEn.trim().isNotEmpty ? it.nameEn : it.nameAr);

        final note = (it.specialNotes ?? "").trim();

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Slidable(
            key: ValueKey("cart_item_${it.id}"),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.22,
              children: [
                SlidableAction(
                  onPressed: isUpdating ? null : (_) => onDelete(it),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  icon: Icons.delete_outline,
                  label: isRTL ? "حذف" : "Delete",
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.25),
                ),
              ),
              child: Column(
                children: [
                  MealCard(
                    key: ValueKey(it.id),
                    image: it.image,
                    name: title,
                    price: it.unitPrice,
                    counter: CounterRequest(
                      value: it.quantity,
                      loading: isUpdating,
                      onChanged: (newQty) => onQtyChange(it, newQty),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 12.w,
                  //     vertical: 8.h,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       InkWell(
                  //         onTap: () => onEditNote(it),
                  //         borderRadius: BorderRadius.circular(10.r),
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: 10.w,
                  //             vertical: 6.h,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white10,
                  //             borderRadius: BorderRadius.circular(10.r),
                  //             border: Border.all(color: Colors.white12),
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               const Icon(
                  //                 Icons.edit_note,
                  //                 color: Colors.white70,
                  //                 size: 18,
                  //               ),
                  //               SizedBox(width: 6.w),
                  //               Text(
                  //                 isRTL ? "ملاحظة" : "Note",
                  //                 style: TextStyle(
                  //                   color: Colors.white70,
                  //                   fontSize: 12.sp,
                  //                   fontWeight: FontWeight.w700,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 10.w),
                  //       Expanded(
                  //         child: Text(
                  //           note.isEmpty
                  //               ? (isRTL ? "لا توجد ملاحظة" : "No note")
                  //               : note,
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: TextStyle(
                  //             color: Colors.white54,
                  //             fontSize: 12.sp,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  final CartResponse cart;
  const _TotalsSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _totalLine(
            title: isRTL ? "المجموع الفرعي" : "Sub total",
            value: cart.itemsTotalAfter,
            before: cart.itemsTotalBefore,
            money: (n) => context.money(n),
            context: context,
          ),
          if (cart.itemsDiscount > 0)
            Total(isRTL ? "خصم العناصر" : "Items discount", cart.itemsDiscount),
          _totalLine(
            title: isRTL ? "التوصيل" : "Delivery",
            value: cart.deliveryAfter,
            before: cart.deliveryBefore,
            money: (n) => context.money(n),
            context: context,
          ),
          if (cart.deliveryDiscount > 0)
            Total(
              isRTL ? "خصم التوصيل" : "Delivery discount",
              cart.deliveryDiscount,
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: colorScheme.outline.withOpacity(0.25),
              indent: 4.w,
              endIndent: 4.w,
            ),
          ),
          _totalLine(
            title: isRTL ? "الإجمالي" : "Total",
            value: cart.grandAfter,
            before: cart.grandBefore,
            isTotal: true,
            money: (n) => context.money(n),
            context: context,
          ),
        ],
      ),
    );
  }
}

class _OrderNotesSection extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isRTL;

  const _OrderNotesSection({required this.ctrl, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 3,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: isRTL
              ? "ملاحظات للطلب (اختياري) مثال: اتصل قبل الوصول..."
              : "Order notes (optional) e.g. call before arrival...",
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12.sp,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Total line helper (كما كان)
// ----------------------------
Widget _totalLine({
  required String title,
  required double value,
  double? before,
  bool isTotal = false,
  required String Function(num v) money,
  required BuildContext context,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final hasBefore = before != null && before! > value;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withOpacity(0.8),
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        if (hasBefore) ...[
          Text(
            money(before!),
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          money(value),
          style: TextStyle(
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
