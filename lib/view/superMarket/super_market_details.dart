// market_grid.dart
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// موديل بسيط للعنصر
class MarketItem {
  final String title;
  final String image;     // يدعم asset أو network
  final bool isAsset;
  const MarketItem({
    required this.title,
    required this.image,
    this.isAsset = true,
  });
}

/// كرت عنصر السوق
class MarketCard extends StatelessWidget {
  final MarketItem item;
  final VoidCallback? onTap;
  const MarketCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.06);
    final border = Colors.white.withOpacity(0.10);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // مساحة الصورة
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: item.isAsset
                        ? Image.asset(item.image, height: 100.h)
                        : Image.network(item.image, height: 100.h),
                  ),
                ),
              ),
            ),
            // العنوان
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Manrope"
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شبكة العناصر (GridView.builder)
class MarketGrid extends StatelessWidget {
  final List<MarketItem> items;
  final void Function(int index, MarketItem item)? onItemTap;

  const MarketGrid({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    // نسبة العرض/الارتفاع للكرت — اضبطها بما يناسب تصميمك
    final childAspect = 0.86;

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,                // عمودين مثل الصورة
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: childAspect,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        return MarketCard(
          item: it,
          onTap: onItemTap == null ? null : () => onItemTap!(index, it),
        );
      },
    );
  }
}
