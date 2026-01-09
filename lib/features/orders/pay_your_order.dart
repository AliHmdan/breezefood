import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/services/money.dart'; // ✅ context.money()
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestOrderScreen extends StatefulWidget {
  const RequestOrderScreen({super.key});

  @override
  State<RequestOrderScreen> createState() => _RequestOrderScreenState();
}

class _RequestOrderScreenState extends State<RequestOrderScreen> {
  int? _selectedAddressId; // للعناوين المحفوظة
  OrderAddress? _tempOrderAddress; // ✅ عنوان مؤقت للطلب الحالي فقط

  final methods = const [
    PaymentMethod(
      id: 'cash',
      title: 'Cash',
      imageAsset: 'assets/images/cash.png',
      imageWidth: 36,
      imageHeight: 24,
    ),
  ];
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
          fontSize: 11.sp,
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

  Future<OrderAddress?> _openTempAddressPicker({required bool isRTL}) async {
    final res = await Navigator.push<OrderAddress?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TempAddressMapPicker(isRTL: isRTL, initial: _tempOrderAddress),
      ),
    );
    return res;
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
      backgroundColor: AppColor.Dark,
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
              );
            },
          ),
        ),
      ),

      // ✅ feedback للطلب (loading / success / error)
      body: BlocListener<OrderFlowCubit, OrderFlowState>(
        listener: (context, state) async {
          await state.maybeWhen(
            loading: () async {
              // ✅ prevent stacking
              if (!EasyLoading.isShow) {
                EasyLoading.show(
                  status: isRTL ? "جارٍ إرسال الطلب..." : "Placing order...",
                );
              }
            },
            success: (orderId, status, pricing, raw) async {
              if (EasyLoading.isShow) await EasyLoading.dismiss();

              AppDialog.showSuccessDialog(
                title: isRTL
                    ? "تم إرسال الطلب بنجاح"
                    : "Order placed successfully",
                message: isRTL
                    ? "رقم الطلب: #$orderId\nالحالة: $status"
                    : "Order ID: #$orderId\nStatus: $status",
              );

              context.read<CartCubit>().loadCart();
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
              // ✅ ensure dismiss on unexpected state
              if (EasyLoading.isShow) await EasyLoading.dismiss();
            },
          );
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(
                child: Text(msg, style: const TextStyle(color: Colors.red)),
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
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],

                        _CartHeader(
                          restaurantName: cart.restaurantName,
                          restaurantLogoUrl: _fullUrl(cart.restaurantLogo),
                          orderId: cart.orderId,
                          orderStatus: cart.orderStatus,
                        ),
                        SizedBox(height: 10.h),

                        if (cart.items.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
                            child: Text(
                              isRTL ? "السلة فارغة" : "Cart is empty",
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: cart.items.map((it) {
                              final isUpdating = updatingIds.contains(it.id);

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
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          isRTL ? "حذف" : "Delete",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
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
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    decoration: BoxDecoration(
                                      color: AppColor.black,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Column(
                                      children: [
                                        MealCard(
                                          key: ValueKey(it.id),
                                          image: it.image,
                                          name: title,
                                          price: it
                                              .unitPrice, // widget handles formatting inside
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
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 6.h),
                                              Wrap(
                                                children: [
                                                  if (it.isSpicy)
                                                    _chip(
                                                      "🌶️ ${isRTL ? "حار" : "Hot"}",
                                                      bg: Colors.red
                                                          .withOpacity(0.15),
                                                    ),
                                                  if (it.deliveryTime > 0)
                                                    _chip(
                                                      "⏱ ${it.deliveryTime} ${isRTL ? "د" : "min"}",
                                                      bg: Colors.white10,
                                                    ),
                                                  if (it.hasDiscount)
                                                    _chip(
                                                      it.discountPercent > 0
                                                          ? "-${it.discountPercent}%"
                                                          : (isRTL
                                                                ? "خصم"
                                                                : "Discount"),
                                                      bg: Colors.green
                                                          .withOpacity(0.15),
                                                    ),
                                                ],
                                              ),

                                              // ✅ Discount prices
                                              if (it.hasDiscount) ...[
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Text(
                                                      context.money(
                                                        it.priceBefore,
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 12.sp,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      context.money(
                                                        it.priceAfter,
                                                      ),
                                                      style: TextStyle(
                                                        color: AppColor.yellow,
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],

                                              if (extras.isNotEmpty) ...[
                                                SizedBox(height: 8.h),
                                                Text(
                                                  isRTL ? "الإضافات" : "Extras",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                ...extras.map((ex) {
                                                  final arName =
                                                      ex.nameArObj?.name ?? "";
                                                  final enName =
                                                      ex.nameEnObj?.name ?? "";
                                                  final exTitle = isRTL
                                                      ? (arName.isNotEmpty
                                                            ? arName
                                                            : enName)
                                                      : (enName.isNotEmpty
                                                            ? enName
                                                            : arName);

                                                  final priceText =
                                                      ex.totalPrice > 0
                                                      ? "+${context.money(ex.totalPrice)}"
                                                      : (ex.unitPrice > 0
                                                            ? "+${context.money(ex.unitPrice)}"
                                                            : "");

                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 6.h,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.circle,
                                                          size: 6,
                                                          color: Colors.white54,
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Expanded(
                                                          child: Text(
                                                            "$exTitle  ×${ex.quantity}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 12.sp,
                                                            ),
                                                          ),
                                                        ),
                                                        if (priceText
                                                            .isNotEmpty)
                                                          Text(
                                                            priceText,
                                                            style: TextStyle(
                                                              color: AppColor
                                                                  .yellow,
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],

                                              SizedBox(height: 10.h),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      isRTL
                                                          ? "مجموع العنصر"
                                                          : "Item total",
                                                      style: TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    context.money(
                                                      it.totalPrice,
                                                    ),
                                                    style: TextStyle(
                                                      color: AppColor.yellow,
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        SizedBox(height: 10.h),

                        // totals
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
                                title: isRTL ? "المجموع الفرعي" : "Sub total",
                                value: cart.itemsTotalAfter,
                                before: cart.itemsTotalBefore,
                                money: (n) => context.money(n),
                              ),
                              if (cart.itemsDiscount > 0)
                                Total(
                                  isRTL ? "خصم العناصر" : "Items discount",
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
                                  isRTL ? "خصم التوصيل" : "Delivery discount",
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

                        // ✅ Address picker (saved OR temporary)
                        _AddressCard(
                          isRTL: isRTL,
                          cart: cart,
                          selectedSavedId:
                              _selectedAddressId ?? cart.defaultAddress?.id,
                          tempAddress: _tempOrderAddress,
                          onTap: () async {
                            final action = await _openAddressPickerSheet(
                              isRTL: isRTL,
                              addresses: cart.addresses,
                              selectedId:
                                  _selectedAddressId ?? cart.defaultAddress?.id,
                            );

                            if (action == null) return;

                            if (action.type == _PickAddressActionType.saved &&
                                action.savedId != null) {
                              setState(() {
                                _selectedAddressId = action.savedId;
                                _tempOrderAddress = null; // ✅ مسح المؤقت
                              });
                            }

                            if (action.type == _PickAddressActionType.temp) {
                              final temp = await _openTempAddressPicker(
                                isRTL: isRTL,
                              );

                              if (temp != null) {
                                setState(() {
                                  _tempOrderAddress = temp; // ✅ تعيين المؤقت
                                  _selectedAddressId = null; // ✅ تجاهل المحفوظ
                                });
                              }
                            }

                            if (action.type ==
                                _PickAddressActionType.clearTemp) {
                              setState(() {
                                _tempOrderAddress = null;
                              });
                            }
                          },
                        ),

                        SizedBox(height: 10.h),

                        PaymentMethodSection(
                          amountText: context.money(cart.grandAfter), // ✅ fixed
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
    );
  }
}

class _AddressCard extends StatelessWidget {
  final bool isRTL;
  final CartResponse cart;
  final int? selectedSavedId;
  final OrderAddress? tempAddress;
  final VoidCallback onTap;

  const _AddressCard({
    required this.isRTL,
    required this.cart,
    required this.selectedSavedId,
    required this.tempAddress,
    required this.onTap,
  });

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

    final shownText = (tempAddress?.text.trim().isNotEmpty ?? false)
        ? tempAddress!.text
        : (selectedSaved?.address ?? "");

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? "عنوان التوصيل" : "Delivery address",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      shownText.isEmpty
                          ? (isRTL ? "اختر عنوان" : "Select address")
                          : shownText,
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),
          ),
          if (tempAddress != null && (tempAddress!.text.trim().isNotEmpty)) ...[
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),

          // ✅ خيار عنوان مؤقت
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
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
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
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
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
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        if (hasBefore) ...[
          Text(
            money(before!),
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 12.sp,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          money(value),
          style: TextStyle(
            color: isTotal ? AppColor.yellow : Colors.white,
            fontSize: isTotal ? 15.sp : 13.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _CartHeader extends StatelessWidget {
  final String restaurantName;
  final String restaurantLogoUrl;
  final int orderId;
  final String orderStatus;

  const _CartHeader({
    required this.restaurantName,
    required this.restaurantLogoUrl,
    required this.orderId,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          if (restaurantLogoUrl.trim().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                restaurantLogoUrl,
                width: 46.w,
                height: 46.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isRTL
                      ? "طلب #$orderId • $orderStatus"
                      : "Order #$orderId • $orderStatus",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _storeOrder(
  BuildContext context,
  CartResponse cart,
  String paymentId, {
  required int? selectedAddressId,
  required OrderAddress? temp,
}) async {
  final isRTL = Directionality.of(context) == TextDirection.rtl;

  // ✅ لازم يكون في عنوان (مؤقت أو محفوظ أو primary)
  final hasTemp = temp != null && temp.text.trim().isNotEmpty;
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

  // saved
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

  // ✅ priority: temp -> saved -> primary
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

  // ✅ أهم سطر: لا تستخدم getIt هون
  context.read<OrderFlowCubit>().store(req);
}

class TempAddressMapPicker extends StatefulWidget {
  final bool isRTL;
  final OrderAddress? initial;

  const TempAddressMapPicker({super.key, required this.isRTL, this.initial});

  @override
  State<TempAddressMapPicker> createState() => _TempAddressMapPickerState();
}

class _TempAddressMapPickerState extends State<TempAddressMapPicker> {
  GoogleMapController? _map;

  late LatLng _pickedLatLng;
  late TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();

    // default location (اذا ما في initial)
    final initLat = widget.initial?.latitude ?? 37.4219983;
    final initLng = widget.initial?.longitude ?? -122.084;

    _pickedLatLng = LatLng(initLat, initLng);
    _textCtrl = TextEditingController(text: widget.initial?.text ?? "");
  }

  @override
  void dispose() {
    _map?.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _setPicked(LatLng p) {
    setState(() => _pickedLatLng = p);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.isRTL;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: AppBar(
        backgroundColor: AppColor.Dark,
        title: Text(isRTL ? "اختيار عنوان" : "Pick address"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLatLng,
              zoom: 16,
            ),
            onMapCreated: (c) => _map = c,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onTap: _setPicked,
            onCameraMove: (pos) => _pickedLatLng = pos.target,
            onCameraIdle: () => setState(() {}),
          ),

          // ✅ pin ثابت بالنص (أسهل UX من marker)
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                size: 46.sp,
                color: AppColor.primaryColor,
              ),
            ),
          ),

          // ✅ bottom card
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.black,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: isRTL
                          ? "اكتب العنوان (Text فقط)"
                          : "Type address (text only)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        final t = _textCtrl.text.trim();
                        if (t.isEmpty) return;

                        Navigator.pop(
                          context,
                          OrderAddress(
                            text: t,
                            latitude: _pickedLatLng.latitude,
                            longitude: _pickedLatLng.longitude,
                          ),
                        );
                      },
                      child: Text(
                        isRTL ? "تأكيد العنوان" : "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}
