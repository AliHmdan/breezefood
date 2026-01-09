import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/request_order/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<SupermarketAddToCartResult?> showSupermarketAddOrderDialog(
  BuildContext context, {
  required String title,
  required String price,
  String? oldPrice,
  required String imagePath,
}) async {
  return showModalBottomSheet<SupermarketAddToCartResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) {
      final height = MediaQuery.of(context).size.height * 0.72;

      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColor.Dark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SupermarketAddOrderBody(
          title: title,
          price: price,
          oldPrice: oldPrice,
          imagePath: imagePath,
        ),
      );
    },
  );
}

class SupermarketAddOrderBody extends StatefulWidget {
  final String title;
  final String price;
  final String imagePath;
  final String? oldPrice;

  const SupermarketAddOrderBody({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    this.oldPrice,
  });

  @override
  State<SupermarketAddOrderBody> createState() =>
      _SupermarketAddOrderBodyState();
}

class _SupermarketAddOrderBodyState extends State<SupermarketAddOrderBody> {
  int _qty = 1;
  final TextEditingController notesController = TextEditingController();

  double _parsePrice(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pricePerItem = _parsePrice(widget.price);

    return Column(
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
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ IMAGE + close
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                      child:
                          (widget.imagePath.startsWith("http://") ||
                              widget.imagePath.startsWith("https://"))
                          ? Image.network(
                              widget.imagePath,
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                "assets/images/bread.png",
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              widget.imagePath,
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
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
                  ],
                ),

                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomSubTitle(
                              subtitle: widget.title,
                              color: AppColor.white,
                              fontsize: 16,
                            ),
                          ),
                          if (widget.oldPrice != null) ...[
                            Text(
                              context.money(
                                widget.oldPrice! as num,
                                decimals: 0,
                              ),
                              style: TextStyle(
                                color: AppColor.red,
                                fontSize: 12.sp,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],

                          Text(
                            widget.price,
                            style: TextStyle(
                              color: AppColor.yellow,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),
                      CustomSubTitle(
                        subtitle: "Product details",
                        color: AppColor.gry,
                        fontsize: 10.sp,
                      ),

                      _divider(),

                      // ✅ Quantity
                      CustomSubTitle(
                        subtitle: "Quantity",
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      SizedBox(height: 10.h),

                      QtyCounter(
                        value: _qty,
                        onChanged: (v) => setState(() => _qty = v),
                        pricePerItem: pricePerItem,
                        moneyDecimals: 0, // أو 2 إذا بدك
                      ),

                      _divider(),

                      // ✅ Notes
                      CustomSubTitle(
                        subtitle: "Notes (optional)",
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Example: No damaged items",
                          hintStyle: TextStyle(
                            color: AppColor.gry,
                            fontSize: 10.sp,
                          ),
                          filled: true,
                          fillColor: AppColor.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ ADD BUTTON
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  SupermarketAddToCartResult(
                    quantity: _qty,
                    notes: notesController.text.trim(),
                  ),
                );
              },
              child: Text(
                "ADD TO CART  ${context.money(pricePerItem * _qty, decimals: 0)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 18.h),
      child: Divider(color: AppColor.gry, thickness: 1.2),
    );
  }
}

class SupermarketAddToCartResult {
  final int quantity;
  final String notes;

  const SupermarketAddToCartResult({
    required this.quantity,
    required this.notes,
  });
}
