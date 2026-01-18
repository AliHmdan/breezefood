import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/services/money.dart';  
import 'package:breezefood/features/orders/model/cart_response.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';
import 'package:breezefood/features/orders/payment_method.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/request_order/counter_request.dart';
import 'package:breezefood/features/orders/request_order/meal_card.dart';
import 'package:breezefood/features/orders/request_order/total.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestOrderScreen extends StatefulWidget {
  const RequestOrderScreen({super.key});

  @override
  State<RequestOrderScreen> createState() => _RequestOrderScreenState();
}

class _RequestOrderScreenState extends State<RequestOrderScreen> {
  int? _selectedAddressId; // saved addresses
  OrderAddress? _tempOrderAddress; // ✅ temporary for this order only
  final TextEditingController _tempDetailsCtrl = TextEditingController();
  final FocusNode _tempDetailsFocus = FocusNode();

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
  void dispose() {
    _tempDetailsCtrl.dispose();
    _tempDetailsFocus.dispose();
    super.dispose();
  }

  String _selectedPayment = 'cash';

  String _fullUrl(String path) {
    final s = path.trim();
    if (s.isEmpty) return "";
    if (s.startsWith("http://") || s.startsWith("https://")) return s;
    final clean = s.replaceFirst(RegExp(r'^/+'), '');
    return "https://breezefood.cloud/$clean";
  }

  Widget _chip(String text, {Color? bg, Color? fg}) {
    return Container(
      margin: EdgeInsetsDirectional.only(end: 6.w, bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (bg ?? Colors.white12),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required bool isRTL,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColor.black,
            title: Text(
              isRTL ? "حذف العنصر؟" : "Delete item?",
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              isRTL
                  ? "هل تريد حذف هذا العنصر من السلة؟"
                  : "Do you want to remove this item from cart?",
              style: const TextStyle(color: Colors.white70),
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

  Future<LatLng?> _openTempAddressPicker({required bool isRTL}) async {
    final init = _tempOrderAddress == null
        ? null
        : LatLng(_tempOrderAddress!.latitude, _tempOrderAddress!.longitude);

    return Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (_) => TempAddressMapPicker(isRTL: isRTL, initial: init),
      ),
    );
  }

  Future<_PickAddressAction?> _openAddressPickerSheet({
    required bool isRTL,
    required List<CartUserAddress> addresses,
    required int? selectedId,
  }) async {
    return showModalBottomSheet<_PickAddressAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddressPickerSheet(
        isRTL: isRTL,
        addresses: addresses,
        selectedId: selectedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
                cartLoaded: (cart, __, ___) => cart.restaurantName.isNotEmpty
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
          /// 🖼️ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_auth.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🌫️ Overlay (مهم جداً لقراءة النص)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
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
                        backgroundColor: Colors.red,
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    cartLoaded: (cart, updatingIds, toast) {
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
                              if (toast != null && toast.trim().isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    toast,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],

                              // _CartHeader(
                              //   restaurantName: cart.restaurantName,
                              //   restaurantLogoUrl: _fullUrl(cart.restaurantLogo),
                              //   orderId: cart.orderId,
                              //   orderStatus: cart.orderStatus,
                              // ),
                              SizedBox(height: 10.h),

                              if (cart.items.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 30.h,
                                    bottom: 10.h,
                                  ),
                                  child: Text(
                                    isRTL ? "السلة فارغة" : "Cart is empty",
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: cart.items.map((it) {
                                    final isUpdating = updatingIds.contains(
                                      it.id,
                                    );

                                    final title = isRTL
                                        ? (it.nameAr.trim().isNotEmpty
                                              ? it.nameAr
                                              : it.nameEn)
                                        : (it.nameEn.trim().isNotEmpty
                                              ? it.nameEn
                                              : it.nameAr);

                                    final extras = it.extras;

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: Dismissible(
                                        key: ValueKey("cart_item_${it.id}"),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                isRTL ? "حذف" : "Delete",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        confirmDismiss: (_) async {
                                          if (isUpdating) return false;
                                          return _confirmDelete(
                                            context,
                                            isRTL: isRTL,
                                          );
                                        },
                                        onDismissed: (_) => context
                                            .read<CartCubit>()
                                            .removeItem(it.id),
                                        child: Container(
                                          // padding: EdgeInsets.only(bottom: 10.h),
                                          decoration: BoxDecoration(
                                            color: AppColor.black,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.white10,
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
                                                  onChanged: (newQty) {
                                                    context
                                                        .read<CartCubit>()
                                                        .updateQty(
                                                          cartItemId: it.id,
                                                          quantity: newQty,
                                                        );
                                                  },
                                                ),
                                              ),

                                              // (كل الكومنتات اللي عندك ضليت كما هي - ما حذفتها)
                                              // Padding(
                                              //   padding: EdgeInsets.symmetric(horizontal: 12.w),
                                              //   child: Column(
                                              //     crossAxisAlignment: CrossAxisAlignment.start,
                                              //     children: [
                                              //       SizedBox(height: 6.h),
                                              //       Wrap(
                                              //         children: [
                                              //           if (it.isSpicy)
                                              //             _chip(
                                              //               "🌶️ ${isRTL ? "حار" : "Hot"}",
                                              //               bg: Colors.red.withOpacity(0.15),
                                              //             ),
                                              //           if (it.deliveryTime > 0)
                                              //             _chip(
                                              //               "⏱ ${it.deliveryTime} ${isRTL ? "د" : "min"}",
                                              //               bg: Colors.white10,
                                              //             ),
                                              //           if (it.hasDiscount)
                                              //             _chip(
                                              //               it.discountPercent > 0
                                              //                   ? "-${it.discountPercent}%"
                                              //                   : (isRTL ? "خصم" : "Discount"),
                                              //               bg: Colors.green.withOpacity(0.15),
                                              //             ),
                                              //         ],
                                              //       ),
                                              //       ...
                                              //     ],
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                              SizedBox(height: 10.h),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 18.h,
                                  horizontal: 12.w,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(11.r),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _totalLine(
                                      title: isRTL
                                          ? "المجموع الفرعي"
                                          : "Sub total",
                                      value: cart.itemsTotalAfter,
                                      before: cart.itemsTotalBefore,
                                      money: (n) => context.money(n),
                                    ),
                                    if (cart.itemsDiscount > 0)
                                      Total(
                                        isRTL
                                            ? "خصم العناصر"
                                            : "Items discount",
                                        cart.itemsDiscount,
                                      ),
                                    _totalLine(
                                      title: isRTL ? "التوصيل" : "Delivery",
                                      value: cart.deliveryAfter,
                                      before: cart.deliveryBefore,
                                      money: (n) => context.money(n),
                                    ),
                                    if (cart.deliveryDiscount > 0)
                                      Total(
                                        isRTL
                                            ? "خصم التوصيل"
                                            : "Delivery discount",
                                        cart.deliveryDiscount,
                                      ),
                                    const Divider(color: Colors.white30),
                                    _totalLine(
                                      title: isRTL ? "الإجمالي" : "Total",
                                      value: cart.grandAfter,
                                      before: cart.grandBefore,
                                      isTotal: true,
                                      money: (n) => context.money(n),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 10.h),

                              _AddressCard(
                                isRTL: isRTL,
                                cart: cart,
                                selectedSavedId:
                                    _selectedAddressId ??
                                    cart.defaultAddress?.id,
                                tempAddress: _tempOrderAddress,
                                onTap: () async {
                                  final action = await _openAddressPickerSheet(
                                    isRTL: isRTL,
                                    addresses: cart.addresses,
                                    selectedId:
                                        _selectedAddressId ??
                                        cart.defaultAddress?.id,
                                  );

                                  if (action == null) return;

                                  if (action.type ==
                                          _PickAddressActionType.saved &&
                                      action.savedId != null) {
                                    setState(() {
                                      _selectedAddressId = action.savedId;
                                      _tempOrderAddress = null;
                                      _tempDetailsCtrl.clear();
                                    });
                                  }

                                  if (action.type ==
                                      _PickAddressActionType.temp) {
                                    final picked = await _openTempAddressPicker(
                                      isRTL: isRTL,
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _tempOrderAddress = OrderAddress(
                                          text: _tempDetailsCtrl.text.trim(),
                                          latitude: picked.latitude,
                                          longitude: picked.longitude,
                                        );
                                        _selectedAddressId = null;
                                      });

                                      // ✅ افتح الكيبورد على الفيلد داخل الكارت
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (!mounted) return;
                                            _tempDetailsFocus.requestFocus();
                                          });
                                    }
                                  }

                                  if (action.type ==
                                      _PickAddressActionType.clearTemp) {
                                    setState(() {
                                      _tempOrderAddress = null;
                                      _tempDetailsCtrl.clear();
                                    });
                                  }
                                },
                                tempDetailsCtrl: _tempDetailsCtrl,
                                tempDetailsFocus: _tempDetailsFocus,
                                onTempDetailsChanged: (v) {
                                  setState(() {
                                    if (_tempOrderAddress != null) {
                                      _tempOrderAddress = OrderAddress(
                                        text: v.trim(),
                                        latitude: _tempOrderAddress!.latitude,
                                        longitude: _tempOrderAddress!.longitude,
                                      );
                                    }
                                  });
                                },
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
                                    : (paymentId) {
                                        _storeOrder(
                                          context,
                                          cart,
                                          paymentId,
                                          selectedAddressId: _selectedAddressId,
                                          temp: _tempOrderAddress,
                                        );
                                      },
                              ),
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

class _AddressCard extends StatelessWidget {
  final bool isRTL;
  final CartResponse cart;
  final int? selectedSavedId;
  final OrderAddress? tempAddress;
  final VoidCallback onTap;

  // ✅ جديد
  final TextEditingController tempDetailsCtrl;
  final FocusNode tempDetailsFocus;
  final ValueChanged<String> onTempDetailsChanged;

  const _AddressCard({
    required this.isRTL,
    required this.cart,
    required this.selectedSavedId,
    required this.tempAddress,
    required this.onTap,
    required this.tempDetailsCtrl,
    required this.tempDetailsFocus,
    required this.onTempDetailsChanged,
  });

  bool _canShowMapPreview(CartUserAddress? saved, OrderAddress? temp) {
    final lat = temp?.latitude ?? saved?.latitude;
    final lng = temp?.longitude ?? saved?.longitude;
    if (lat == null || lng == null) return false;
    return lat != 0 && lng != 0;
  }

  double _pickedLat(CartUserAddress? saved, OrderAddress? temp) {
    return (temp?.latitude ?? saved?.latitude ?? 0).toDouble();
  }

  double _pickedLng(CartUserAddress? saved, OrderAddress? temp) {
    return (temp?.longitude ?? saved?.longitude ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final addresses = cart.addresses;

    CartUserAddress? selectedSaved;
    if (addresses.isNotEmpty) {
      selectedSaved = addresses.firstWhere(
        (a) => a.id == (selectedSavedId ?? cart.defaultAddress?.id),
        orElse: () => cart.defaultAddress ?? addresses.first,
      );
    }

    // ✅ هذا النص للعرض داخل الصندوق
    final shownText = (tempAddress != null)
        ? tempDetailsCtrl.text.trim()
        : (selectedSaved?.address ?? "");

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: icon + title + change
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      (tempAddress != null)
                          ? (isRTL ? "عنوان مؤقت" : "Temporary address")
                          : ((selectedSaved?.address ?? "").isEmpty
                                ? (isRTL ? "اختر عنوان" : "Select address")
                                : (isRTL
                                      ? "عنوان التوصيل"
                                      : "Delivery address")),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isRTL ? "تغيير" : "Change",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              if (tempAddress != null) ...[
                SizedBox(height: 10.h),
                TextField(
                  controller: tempDetailsCtrl,
                  focusNode: tempDetailsFocus,
                  style: const TextStyle(color: Colors.white),
                  onChanged: onTempDetailsChanged,
                  decoration: InputDecoration(
                    hintText: isRTL
                        ? "تفاصيل العنوان: بناية، طابق، شقة..."
                        : "Address details: building, floor, apt...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              // Mini map preview
              if (_canShowMapPreview(selectedSaved, tempAddress)) ...[
                SizedBox(height: 10.h),
                _MiniMapPreview(
                  lat: _pickedLat(selectedSaved, tempAddress),
                  lng: _pickedLng(selectedSaved, tempAddress),
                ),
              ],

              if (tempAddress != null) ...[
                SizedBox(height: 8.h),
                Text(
                  isRTL
                      ? "هذا عنوان مؤقت للطلب فقط"
                      : "This is temporary for this order only",
                  style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMapPreview extends StatelessWidget {
  final double lat;
  final double lng;

  const _MiniMapPreview({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(lat, lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: pos, zoom: 15),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: true, // ✅ Android preview
            ),
            Center(
              child: Icon(
                Icons.location_pin,
                size: 34.sp,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PickAddressActionType { saved, temp, clearTemp }

class _PickAddressAction {
  final _PickAddressActionType type;
  final int? savedId;

  const _PickAddressAction.saved(this.savedId)
    : type = _PickAddressActionType.saved;

  const _PickAddressAction.temp()
    : type = _PickAddressActionType.temp,
      savedId = null;

  const _PickAddressAction.clearTemp()
    : type = _PickAddressActionType.clearTemp,
      savedId = null;
}

class _AddressPickerSheet extends StatelessWidget {
  final bool isRTL;
  final List<CartUserAddress> addresses;
  final int? selectedId;

  const _AddressPickerSheet({
    required this.isRTL,
    required this.addresses,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: AppColor.Dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
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
          SizedBox(height: 12.h),
          Text(
            isRTL ? "اختر عنوان" : "Choose address",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, const _PickAddressAction.temp()),
                    icon: const Icon(
                      Icons.edit_location_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      isRTL ? "إدخال عنوان مؤقت" : "Enter temporary address",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      const _PickAddressAction.clearTemp(),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: Text(
                      isRTL
                          ? "إلغاء العنوان المؤقت"
                          : "Clear temporary address",
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(color: Colors.white24),
          Expanded(
            child: addresses.isEmpty
                ? Center(
                    child: Text(
                      isRTL ? "لا يوجد عناوين محفوظة" : "No saved addresses",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (_, i) {
                      final a = addresses[i];
                      final checked = a.id == selectedId;

                      return ListTile(
                        onTap: () => Navigator.pop(
                          context,
                          _PickAddressAction.saved(a.id),
                        ),
                        leading: Icon(
                          checked
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: checked
                              ? AppColor.primaryColor
                              : Colors.white54,
                        ),
                        title: Text(
                          a.address,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _totalLine({
  required String title,
  required double value,
  double? before,
  bool isTotal = false,
  required String Function(num v) money,
}) {
  final hasBefore = before != null && before! > value;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white70,
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        if (hasBefore) ...[
          Text(
            money(before!),
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          money(value),
          style: TextStyle(
            color: isTotal ? AppColor.yellow : Colors.white,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Future<void> _storeOrder(
  BuildContext context,
  CartResponse cart,
  String paymentId, {
  required int? selectedAddressId,
  required OrderAddress? temp,
}) async {
  final isRTL = Directionality.of(context) == TextDirection.rtl;

  final hasTemp =
      temp != null &&
      temp.latitude != 0 &&
      temp.longitude != 0 &&
      temp.text.trim().isNotEmpty;

  final hasAnySaved = cart.addresses.isNotEmpty;

  if (!hasTemp &&
      !hasAnySaved &&
      (cart.primaryAddress?.address?.trim().isEmpty ?? true)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL ? "يرجى اختيار عنوان" : "Please select address"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final pickedSaved = (selectedAddressId == null)
      ? cart.defaultAddress
      : cart.addresses.firstWhere(
          (a) => a.id == selectedAddressId,
          orElse: () =>
              cart.defaultAddress ??
              (cart.addresses.isNotEmpty
                  ? cart.addresses.first
                  : cart.defaultAddress!),
        );

  final primary = cart.primaryAddress;

  final addressToSend = hasTemp
      ? temp!
      : (pickedSaved != null)
      ? OrderAddress(
          text: pickedSaved.address,
          latitude: pickedSaved.latitude,
          longitude: pickedSaved.longitude,
        )
      : OrderAddress(
          text: primary?.address ?? "",
          latitude: primary?.latitude ?? 0,
          longitude: primary?.longitude ?? 0,
        );

  final req = StoreOrderRequest(
    restaurantId: cart.restaurantId,
    deliveryType: "delivery",
    paymentMethod: paymentId,
    notes: "",
    deliveryFee: cart.deliveryAfter,
    address: addressToSend,
    items: cart.items.map((it) {
      return OrderItemRequest(
        menuItemId: it.menuItemId,
        quantity: it.quantity,
        specialNotes: "",
        extras: const [],
      );
    }).toList(),
    appetizers: const [],
  );

  context.read<OrderFlowCubit>().store(req);
}

class TempAddressMapPicker extends StatefulWidget {
  final bool isRTL;
  final LatLng? initial;

  const TempAddressMapPicker({super.key, required this.isRTL, this.initial});

  @override
  State<TempAddressMapPicker> createState() => _TempAddressMapPickerState();
}

class _TempAddressMapPickerState extends State<TempAddressMapPicker> {
  GoogleMapController? _map;
  late LatLng _picked;

  bool _locating = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // fallback لحد ما نجيب current location
    _picked = widget.initial ?? const LatLng(37.4219983, -122.084);

    _initFromCurrentLocation();
  }

  Future<void> _initFromCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      final pos = await _getCurrentPosition();
      if (!mounted) return;

      final current = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _picked = current;
        _locating = false;
      });

      await _map?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: current, zoom: 16),
        ),
      );
    } catch (e, st) {
      log("TempAddressMapPicker location error: $e\n$st");
      if (!mounted) return;

      setState(() {
        _locating = false;
        _error = widget.isRTL
            ? "تعذر تحديد موقعك الحالي، اختره يدويًا"
            : "Couldn't get your current location. Pick it manually.";
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled");

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.isRTL;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: AppBar(
        backgroundColor: AppColor.Dark,
        title: Text(isRTL ? "اختيار موقع" : "Pick location"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, null),
        ),
        actions: [
          IconButton(
            tooltip: isRTL ? "موقعي" : "My location",
            onPressed: _initFromCurrentLocation, // ✅ يرجعك لموقعك
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _picked, zoom: 16),
            onMapCreated: (c) async {
              _map = c;

              // ✅ إذا موقعك انجاب قبل إنشاء الخريطة، حرّك الكاميرا
              if (!_locating) {
                await _map?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _picked, zoom: 16),
                  ),
                );
              }
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,

            // ✅ الأفضل: لما المستخدم يحرّك الخريطة، خذ مركز الكاميرا
            onCameraMove: (pos) => _picked = pos.target,
            onCameraIdle: () => setState(() {}),

            // لو بدك tap كمان:
            // onTap: (p) => setState(() => _picked = p),
          ),

          // ✅ pin بالوسط
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                size: 46,
                color: AppColor.primaryColor,
              ),
            ),
          ),

          // ✅ رسالة خطأ (اختياري)
          if (_error != null)
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 70.h,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // ✅ Overlay تحميل
          if (_locating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),

          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _locating
                    ? null
                    : () => Navigator.pop(context, _picked),
                child: Text(
                  isRTL ? "تأكيد الموقع" : "Confirm location",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
