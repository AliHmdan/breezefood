// import 'package:breezefood/core/component/color.dart';
// import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// // ------------------------------------------------------------
// // 🧩 Discount Widget - (أبعاد وألوان محسّنة)
// // ------------------------------------------------------------

// class Discount extends StatefulWidget {
//   final String imagePath;
//   final String title;
//   final String subtitle;
//   final String price;
//   final String discount;
//   final bool initialIsFavorite;
//   final VoidCallback onFavoriteToggle;
//   final void Function()? onTap;

//   Discount({
//     Key? key,
//     required this.imagePath,
//     required this.title,
//     required this.subtitle,
//     required this.price,
//     required this.discount,
//     required this.onFavoriteToggle,
//     this.initialIsFavorite = false,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   State<Discount> createState() => _DiscountState();
// }

// class _DiscountState extends State<Discount>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late bool _isFavorite;

//   @override
//   void initState() {
//     super.initState();
//     _isFavorite = widget.initialIsFavorite;
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.3,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//   }

//   Widget buildImage(String path, {double? height}) {
//     return Image.asset(
//       path,
//       height: height,
//       width: double.infinity,
//       cacheWidth: 600,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) => Container(
//         height: height,
//         color: AppColor.light, // لون فاتح للخلفية البديلة
//         child: Center(
//           child: Icon(Icons.fastfood, color: AppColor.Dark, size: 24.sp),
//         ),
//       ),
//     );
//   }

//   void _toggleFavorite() {
//     setState(() {
//       _isFavorite = !_isFavorite;
//     });
//     widget.onFavoriteToggle();
//     _controller.forward().then((_) => _controller.reverse());
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 💡 تم إزالة الـ SizedBox ذو العرض الثابت هنا، ليأخذ عرض الـ Grid
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         // 💡 استخدام BoxDecoration لتطبيق Radius ولون الخلفية
//         decoration: BoxDecoration(
//           color: AppColor.white, // خلفية بيضاء واضحة للبطاقة
//           borderRadius: BorderRadius.circular(10.r), // تدوير حواف البطاقة
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼️ الصورة + المفضلة + الخصم (ارتفاع ثابت ونسبة أفضل)
//             Stack(
//               children: [
//                 // 💡 الحاوية الرئيسية للصورة
//                 Container(
//                   constraints: BoxConstraints(
//                     // ارتفاع تم تحسينه ليناسب بطاقة GridView بشكل عام
//                     maxHeight: 120.h,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(
//                       10.r,
//                     ), // تدوير حواف الصورة
//                     child: buildImage(widget.imagePath, height: 120.h),
//                   ),
//                 ),

//                 // ⭐⭐⭐ Rating
//                 Positioned(
//                   top: 8.h,
//                   left: 8.w,
//                   child: GestureDetector(
//                     onTap: () {
//                       showRatingPopup(context);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 3.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(
//                           0.6,
//                         ), // تعتيم أفضل للخلفية
//                         borderRadius: BorderRadius.circular(15.r),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 14.sp,
//                           ), // حجم النجم أصغر
//                           SizedBox(width: 4.w),
//                           Text(
//                             "4.9",
//                             style: TextStyle(
//                               color: AppColor.white,
//                               fontSize: 12.sp, // حجم خط أصغر
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // 🍽️ Resturant Name Gradient (Subtitle) - تم تبسيط التدرج لعدم إخفاء اسم المطعم
//                 // 🍽️ Restaurant Name (Centered on Image)
//                 Positioned.fill(
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.25),
//                           Colors.black.withOpacity(0.55),
//                         ],
//                       ),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8.w),
//                       child: Text(
//                         widget.subtitle,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: AppColor.white,
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.bold,
//                           shadows: const [
//                             Shadow(
//                               blurRadius: 6,
//                               color: Colors.black,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // 🔖 الخصم
//                 Positioned(
//                   top: 0, // تم تغيير مكان الخصم ليصبح في الأعلى
//                   right: 0,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColor.red, // اللون الأحمر للخصم
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(
//                           10.r,
//                         ), // يتطابق مع تدوير الصورة
//                         bottomLeft: Radius.circular(10.r),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "${widget.discount}%", // تم إضافة %
//                           style: TextStyle(
//                             color: AppColor.white,
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(width: 4.w),
//                         SvgPicture.asset(
//                           'assets/icons/nspah.svg', // تأكد من مسار الـ SVG
//                           width: 16.w,
//                           height: 16.h,
//                           colorFilter: const ColorFilter.mode(
//                             AppColor.white,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ❤️ زر المفضلة
//                 // Positioned(
//                 //   bottom: 40.h, // تم تغيير مكانه ليطفو على الصورة
//                 //   right: 8.w,
//                 //   child: ScaleTransition(
//                 //     scale: _scaleAnimation,
//                 //     child: GestureDetector(
//                 //       onTap: _toggleFavorite,
//                 //       child: Container(
//                 //         padding: EdgeInsets.all(4.w),
//                 //         decoration: BoxDecoration(
//                 //             color: Colors.black.withOpacity(0.5),
//                 //             shape: BoxShape.circle),
//                 //         child: Icon(
//                 //           _isFavorite ? Icons.favorite : Icons.favorite_border,
//                 //           color: _isFavorite
//                 //               ? AppColor.red
//                 //               : AppColor.white, // استخدام الأحمر للمفضلة
//                 //           size: 20.sp,
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),

//             // 🏷️ اسم الوجبة (Title) والسعر
//             // Padding(
//             //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
//             //   child: Column(
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //       // Text(
//             //       //   widget.title,
//             //       //   style: TextStyle(
//             //       //     color: AppColor.Dark, // لون النص الداكن
//             //       //     fontSize: 14.sp,
//             //       //     fontWeight: FontWeight.bold,
//             //       //   ),
//             //       //   maxLines: 1,
//             //       //   overflow: TextOverflow.ellipsis,
//             //       // ),
//             //       SizedBox(height: 2.h),
//             //       CustomSubTitle(subtitle: widget.price, color: AppColor.primaryColor, fontsize: 13.sp)
//             //
//             //     ],
//             //   ),
//             // ),
//             // 💰 Price (Centered)
//             Positioned.fill(
//               child: Align(
//                 alignment: Alignment.center,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 4.h,
//                   ),

//                   child: Text(
//                     widget.price,
//                     style: TextStyle(
//                       color: AppColor.primaryColor,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ------------------------------------------------------------
// // 🪟 Rating Popup (تم الاحتفاظ به كما هو مع تحسين بسيط للأبعاد)
// // ------------------------------------------------------------

// void showRatingPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         backgroundColor: const Color(0xFF2F2F2F),
//         child: Padding(
//           padding: EdgeInsets.all(20.0.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Align(
//                 alignment: Alignment.topRight,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(Icons.close, color: Colors.white),
//                 ),
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 "What is you rate?",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 15.h),

//               // ⭐⭐⭐⭐⭐ النجوم
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   5,
//                   (index) => Icon(
//                     index < 4 ? Icons.star : Icons.star_border,
//                     color: Colors.amber,
//                     size: 35.sp,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 15.h),

//               Text(
//                 "Please share your rate about the restaurant",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.white70, fontSize: 13.sp),
//               ),
//               SizedBox(height: 20.h),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
