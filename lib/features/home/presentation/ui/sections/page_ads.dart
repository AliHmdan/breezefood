// import 'package:breezefood/core/component/color.dart';
// import 'package:breezefood/features/home/model/home_response.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
//
// class ActionPill extends StatelessWidget {
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const ActionPill({super.key, required this.onCopy, required this.onShare});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppColor.primaryColor.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildActionButton(Icons.copy, 'referral.copy'.tr(), onCopy),
//           const SizedBox(width: 20),
//           _buildActionButton(Icons.share, 'referral.share'.tr(), onShare),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String text, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: AppColor.Dark),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: const TextStyle(
//               color: AppColor.Dark,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//
//   const CircleIconButton({super.key, required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.8),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 20, color: AppColor.Dark),
//       ),
//     );
//   }
// }
//
// // 🧩 3. GradientBackground (الخلفية المتدرجة)
// class GradientBackground extends StatelessWidget {
//   final double height;
//   const GradientBackground({super.key, required this.height});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height * 0.45,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColor.primaryColor, Color(0xFFFEE7B6)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(50),
//           bottomRight: Radius.circular(50),
//         ),
//       ),
//     );
//   }
// }
//
// // 🧩 4. ReferralCodeBox (صندوق عرض الرابط)
// class ReferralCodeBox extends StatelessWidget {
//   final String url;
//   const ReferralCodeBox({super.key, required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColor.primaryColor.withOpacity(0.1),
//         border: Border.all(
//           color: AppColor.primaryColor.withOpacity(0.5),
//           width: 1.5,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'referral.your_referral_link'.tr(),
//             style: const TextStyle(
//               color: AppColor.Dark,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//           Text(
//             url,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: AppColor.black,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
