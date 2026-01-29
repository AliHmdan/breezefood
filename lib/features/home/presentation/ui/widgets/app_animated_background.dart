import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdBanner extends StatelessWidget {
  final AdModel? ad;
  final VoidCallback? onTap;

  const AdBanner({super.key, required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = ad;

    // -------------------------------
    // Fallback (no ad)
    // -------------------------------
    if (a == null) {
      return _Shell(
        onTap: onTap,
        child: Center(
          child: Text(
            'مرحباً بك مجدداً 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final imageUrl = UrlHelper.toFullUrl(a.image);
    final title = (a.title ?? '').trim().isEmpty
        ? "عرض خاص 🔥"
        : a.title!.trim();

    // -------------------------------
    // Ad Banner
    // -------------------------------
    return _Shell(
      onTap: onTap, // ✅ هون رح يروح للـ ReferralAdPage
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetworkImage(url: imageUrl, height: 100.h),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent],
              ),
            ),
          ),

          // Title
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper for radius + tap + height
class _Shell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Shell({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.r),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// Network Image Widget (Clean + Safe)
/// ===============================================================
class _NetworkImage extends StatelessWidget {
  final String? url;
  final double height;

  const _NetworkImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (url ?? '').trim();

    if (imageUrl.isEmpty) return _errorPlaceholder();

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: Colors.black12,
          alignment: Alignment.center,
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: height,
      color: Colors.blueGrey.shade900,
      alignment: Alignment.center,
      child: Text(
        'صورة الإعلان غير متوفرة',
        style: TextStyle(color: Colors.white70, fontSize: 10.sp),
      ),
    );
  }
}
