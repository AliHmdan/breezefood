
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:breezefood/view/orders/add_order.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ----------------------------------------------------------------------
// ⚠️ موديل وهمي بديل لموديل الـ API
// ----------------------------------------------------------------------
class PopularItemDummy {
  final int id;
  final String nameAr;
  final String restaurantName;
  final String price;
  final String image; // مسار Asset وهمي
  final bool isFavorite;

  PopularItemDummy({
    required this.id,
    required this.nameAr,
    required this.restaurantName,
    required this.price,
    required this.image,
    this.isFavorite = false,
  });
}

// ----------------------------------------------------------------------
// ✅ قائمة بيانات وهمية ثابتة (Dummy Data List)
// ----------------------------------------------------------------------
final List<PopularItemDummy> _dummyPopularItems = [
  PopularItemDummy(
    id: 1,
    nameAr: "وجبة شاورما دجاج (وهمي)",
    restaurantName: "مطعم السعادة",
    price: "75000 ل.س",
    image: "assets/images/shawarma_box.png",
    isFavorite: true,
  ),
  PopularItemDummy(
    id: 2,
    nameAr: "برجر لحم بالجبنة",
    restaurantName: "الزاوية الغربية",
    price: "90000 ل.س",
    image: "assets/images/004.jpg",
    isFavorite: false,
  ),
  PopularItemDummy(
    id: 3,
    nameAr: "سلطة فواكه طازجة",
    restaurantName: "حلويات الشام",
    price: "35000 ل.س",
    image: "assets/images/shesh.jpg",
    isFavorite: false,
  ),
  PopularItemDummy(
    id: 4,
    nameAr: "طبق سوشي حار",
    restaurantName: "المذاق الآسيوي",
    price: "120000 ل.س",
    image: "assets/images/shesh.jpg",
    isFavorite: true,
  ),
  PopularItemDummy(
    id: 5,
    nameAr: "بيتزا مارجريتا",
    restaurantName: "مطعم البيتزا",
    price: "60000 ل.س",
    image: "assets/images/shesh.jpg",
    isFavorite: false,
  ),
];
// ----------------------------------------------------------------------

class PopularGridPage extends StatelessWidget {
  const PopularGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ تم حذف BlocProvider
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Most popular (Offline)", // تم التعديل للإشارة إلى الوضع غير المتصل
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // ❌ تم حذف BlocBuilder واستبداله بـ Builder عادي أو تركه كما هو مع استخدام البيانات الثابتة
          child: Builder(
            builder: (context) {
              final items = _dummyPopularItems; // ✅ استخدام البيانات الوهمية الثابتة

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    "No popular items found (Offline Data)",
                    style: TextStyle(color: AppColor.white),
                  ),
                );
              }

              int getCrossAxisCount(double width) {
                if (width < 600) return 2;
                if (width < 1000) return 3;
                return 4;
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = getCrossAxisCount(constraints.maxWidth);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.LightActive,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 5.h,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                     AddOrderBody(title: 'SheSh', price: '500', imagePath: 'assets/images/shesh.jpg', oldPrice: '100',)
                          ),
                              );
                              
                            },
                            child: PopularItemCard(
                              isFavorite: item.isFavorite,
                              // ❌ لا يوجد ربط بسيرفر
                              imagePath: item.image,
                              title: item.nameAr,
                              subtitle: item.restaurantName,
                              price: item.price,
                              oldPrice: null, // لا يوجد سعر قديم وهمي
                              onFavoriteToggle: () {
                                // ❌ منطق الإعجاب يتم تنفيذه محليًا في حالة الحاجة
                                print("Toggled favorite for ${item.nameAr}");
                              },
                            
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}