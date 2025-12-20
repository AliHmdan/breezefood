// presentation/pages/referral_ad_page_standalone.dart

import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 🗑️ تم إزالة Bloc و BlocProvider
// import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:share_plus/share_plus.dart';

// 🗑️ تم إزالة الاعتمادات الخارجية على الباكيند/المنطق
// import 'package:freeza_food/blocs/referral/bloc/referral_bloc.dart';
// import 'package:freeza_food/data/repositories/referral_repository.dart';

// *************************************************************
// ⚠️ تعريفات وهمية (Mocked Dependencies)
// *************************************************************

// 🧩 1. ActionPill (ويدجت الأزرار - نسخ ومشاركة)
class ActionPill extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const ActionPill({super.key, required this.onCopy, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(Icons.copy, 'Copy', onCopy),
          const SizedBox(width: 20),
          _buildActionButton(Icons.share, 'Share', onShare),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.Dark),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColor.Dark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// 🧩 2. CircleIconButton (زر العودة)
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColor.Dark,
        ),
      ),
    );
  }
}

// 🧩 3. GradientBackground (الخلفية المتدرجة)
class GradientBackground extends StatelessWidget {
  final double height;
  const GradientBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.45,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            Color(0xFFFEE7B6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }
}

// 🧩 4. ReferralCodeBox (صندوق عرض الرابط)
class ReferralCodeBox extends StatelessWidget {
  final String url;
  const ReferralCodeBox({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Referral Link',
            style: TextStyle(
              color: AppColor.Dark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


// *************************************************************
// 📄 الـ Widget الرئيسية المجردة: ReferralAdPage
// *************************************************************

class ReferralAdPage extends StatelessWidget {
  // 🗑️ تم الاحتفاظ بالـ adId لأغراض العرض فقط، ولكن لم يعد مستخدماً للـ API
  final int adId; 
  const ReferralAdPage({super.key, required this.adId});

  // 📝 بيانات ثابتة (Mock Data) تحاكي حالة ReferralLoaded
  static const String mockTitle = 'invite a friend\nAnd get 🎁';
  static const String mockDescription =
      'You get \$10 on your friend\'s first order\nAnd an additional \$10 on his second order';
  static const String mockUrl = 'https://mock.example.com/referral/BF-7X2K9';
  
  // 📝 يمكن تبديل هذا المتغير لـ "محاكاة" حالة الخطأ أو التحميل
  // static const bool simulateError = true;
  static const bool simulateLoading = false;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // 🗑️ تم إزالة BlocProvider و BLoC
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 💡 الخلفية المتدرجة
          GradientBackground(height: h), 
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // 🗑️ تم إزالة BlocConsumer واستبداله بمنطق الـ Mock
              child: Builder(
                builder: (context) {
                  if (simulateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 📝 استخدام القيم الثابتة (Mock Data)
                  final String title = mockTitle;
                  final String description = mockDescription;
                  final String url = mockUrl;

                  // 💡 منطق تقسيم العنوان (كما في الكود الأصلي)
                  final titleParts = title.split('\n');
                  final List<TextSpan> titleSpanChildren = [];
                  if (titleParts.isNotEmpty) {
                    titleSpanChildren.add(TextSpan(
                      text: '${titleParts[0]}\n',
                      style: const TextStyle(fontWeight: FontWeight.normal), // تخفيف وزن السطر الأول
                    ));
                    if (titleParts.length > 1) {
                      titleSpanChildren.add(TextSpan(
                        text: titleParts.sublist(1).join('\n'),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColor.red), // تمييز السطر الثاني
                      ));
                    }
                  } else {
                    titleSpanChildren.add(TextSpan(text: title));
                  }

                  // 💡 طريقة العرض الرئيسية
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () {
                              // 🖱️ محاكاة العودة
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mock Action: Navigating back')),
                              );
                              // Navigator.of(context).maybePop();
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: h * 0.02),

                      // العنوان
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColor.Dark,
                            height: 1.2,
                          ),
                          children: titleSpanChildren,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColor.black,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: h * 0.035),

                      // أيقونة وسطية (صندوق الهدايا)
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.primaryColor.withOpacity(.35),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 38,
                            color: AppColor.Dark,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      // مكوّن يعرض الرابط (url)
                      ReferralCodeBox(url: url),

                      const SizedBox(height: 16),

                      Center(
                        child: ActionPill(
                          onCopy: () async {
                            await Clipboard.setData(ClipboardData(text: url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral url copied (Mocked)'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          onShare: () async {
                            final shareText = 'جرّب تطبيقنا: $url';
                            // 🖱️ محاكاة عملية المشاركة
                            await Share.share(shareText); 
                          },
                        ),
                      ),

                      const Spacer(),

                      // زر المشاركة الكبير
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final shareText = 'دعوتك جاهزة! استخدم هذا الرابط: $url';
                            // 🖱️ محاكاة عملية المشاركة
                            await Share.share(shareText); 
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'Share invite link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: AppColor.red, // لون النص والأيقونة
                            backgroundColor: AppColor.primaryColor, // لون الخلفية
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🗑️ تم حذف _buildErrorView لأنه يعتمد على BLoC
}