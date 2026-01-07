import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/cubit/markets_cubit.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late final MarketsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<MarketsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(); // ✅ مرة واحدة
    });
  }

  @override
  void dispose() {
    cubit.close(); // إذا Factory (مو singleton) مثل عندك
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Market",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: BlocBuilder<MarketsCubit, MarketsState>(
        bloc: cubit, // ✅ مهم
        builder: (context, state) {
          if (state is MarketsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MarketsError) {
            return Center(
              child: Text(state.msg, style: const TextStyle(color: Colors.white)),
            );
          }
          if (state is MarketsLoaded) {
            final products = state.markets.map((m) {
              return MarketItem(
                id: m.id,
                title: m.name,
                image: (m.logo != null && m.logo!.trim().isNotEmpty)
                    ? "https://breezefood.cloud/${m.logo}"
                    : "assets/images/bread.png",
                isAsset: !(m.logo != null && m.logo!.trim().isNotEmpty),
              );
            }).toList();

            return MarketGrid(
              items: products,
              onItemTap: (i, item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarketPagePrice(
                      marketId: item.id,
                      title: item.title,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
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
    final childAspect = 0.86;

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: childAspect,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];

        return MarketCard(item: it, onTap: () => onItemTap?.call(index, it));
      },
    );
  }
}

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
                  fontFamily: "Manrope",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketItem {
  final int id;
  final String title;
  final String image;
  final bool isAsset;

  const MarketItem({
    required this.id,
    required this.title,
    required this.image,
    this.isAsset = true,
  });
}
