// 📁 File: favorite_page_standalone.dart
// (ملف FavoritePage بدون Backend)

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_appbar_home.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';


class FavoriteItem {
  final int id;
  final String nameAr;
  final String restaurantName;
  final double price;
  final String image;

  const FavoriteItem({
    required this.id,
    required this.nameAr,
    required this.restaurantName,
    required this.price,
    required this.image,
  });
}

// 📝 بيانات ثابتة (Mock Data)
final List<FavoriteItem> mockFavorites = const [
  FavoriteItem(
    id: 1,
    nameAr: "وجبة شاورما دجاج مميزة",
    restaurantName: "مطعم أبو العز",
    price: 15000.0,
    image: "assets/images/003.jpg", // يجب توفير هذا المسار
  ),
  FavoriteItem(
    id: 2,
    nameAr: "برجر لحم مشوي حار",
    restaurantName: "Burger House",
    price: 18500.0,
    image: "assets/images/002.jpg", // يجب توفير هذا المسار
  ),
  FavoriteItem(
    id: 3,
    nameAr: "بيتزا مارغريتا كلاسيك",
    restaurantName: "Italian Corner",
    price: 22000.0,
    image: "assets/images/001.jpg", // يجب توفير هذا المسار
  ),
];

// *************************************************************
// 🏠 الـ Widget الرئيسية: FavoritePage (Standalone)
// *************************************************************

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // 🗑️ تم إزالة الاعتماد على Cubit
  List<FavoriteItem> _favorites = mockFavorites;

  Future<void> _handleRefresh() async {
    // 🖱️ محاكاة تحديث القائمة (لإثبات أن RefreshIndicator يعمل)
    setState(() {
      _favorites = List.from(mockFavorites); // إعادة تحميل البيانات الثابتة
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("القائمة تم تحديثها (Mock Refresh)")),
      );
    }
  }

  // 🗑️ تم تغيير الدالة لتقبل العنصر المراد حذفه
  Future<void> _deleteFavorite(FavoriteItem item) async {
    // 🖱️ محاكاة عملية الحذف
    setState(() {
      _favorites.removeWhere((f) => f.id == item.id);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حذف ${item.nameAr}")),
      );
    }
  }

  Widget _buildOrderCard(FavoriteItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h), // مسافة بين البطاقات
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (context) => _deleteFavorite(item), // ربط دالة الحذف
              backgroundColor: AppColor.red,
              borderRadius: BorderRadius.circular(15.r), // تم تعديل Radius ليتناسب مع البطاقة
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/delete.svg", // يجب توفير هذا المسار
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 10),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // صورة الوجبة
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Image.asset(
                    item.image,
                    width: 120.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 111.w,
                      height: 100.h,
                      color: AppColor.Dark,
                      child: Center(
                          child: Icon(Icons.fastfood,
                              color: AppColor.white, size: 30.sp)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // تفاصيل الوجبة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSubTitle(
                        subtitle: item.nameAr,
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: item.restaurantName,
                        color: AppColor.white,
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Price : ",
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: "Manrope",
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              // 💡 استخدام سعر العنصر الوهمي
                              text: "${item.price.toStringAsFixed(0)} ل.س",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: RefreshIndicator(
        onRefresh: _handleRefresh, // ربط دالة التحديث الوهمية
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 30, bottom: 8),
          child: Column(
            children: [
              // العنوان
              const CustomAppbarHome(title: "Favorite"),
              SizedBox(height: 20.h),
              // قائمة العناصر (باستخدام بيانات وهمية)
              Expanded(
                child: _favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border,
                                color: AppColor.white, size: 50),
                            SizedBox(height: 10.h),
                            const Text(
                              "لا توجد عناصر في المفضلة",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // 🚀 إنشاء بطاقات لكل عنصر في قائمة البيانات الوهمية
                          for (final f in _favorites) _buildOrderCard(f),
                          const SizedBox(height: 40),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}