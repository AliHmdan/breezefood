import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoriesSlider extends StatelessWidget {
  final List<StoryWrapperModel> stories;
  final void Function(StoryWrapperModel story)? onTap;

  const StoriesSlider({super.key, required this.stories, this.onTap});

  bool _isAr(BuildContext context) => context.locale.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = 160.h;
    final isAr = _isAr(context);

    if (stories.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            "stories.empty".tr(),
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12.sp,
              fontFamily: isAr ? 'Cairo' : 'Inter',
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: 400.w,
        child: CarouselSlider.builder(
          options: CarouselOptions(
            height: height,
            autoPlay: stories.length > 1,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
          ),
          itemCount: stories.length,
          itemBuilder: (context, index, realIndex) {
            final w = stories[index];
            final s = w.storyData;

            // ✅ صورة الستوري
            final imageUrl = (s.imageUrl ?? "").trim();

            // ✅ عنوان القصة (من السيرفر) + fallback مترجم
            final rawTitle = (s.restaurant?.name ?? s.title).trim();
            final title = rawTitle.isEmpty
                ? "stories.story_fallback".tr()
                : rawTitle;

            return GestureDetector(
              onTap: onTap == null ? null : () => onTap!(w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: _NetImage(url: imageUrl, height: height),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  final String? url;
  final double height;

  const _NetImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final u = (url ?? "").trim();

    if (u.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image,
          color: colorScheme.onSurface.withOpacity(0.7),
          size: 30.sp,
        ),
      );
    }

    return AppNetworkImage(
      path: u, // نفس الرابط القادم من الباك بدون أي تعديل
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      fallback: Container(
        height: height,
        width: double.infinity,
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          color: colorScheme.onSurface.withOpacity(0.7),
          size: 26.sp,
        ),
      ),
    );
  }
}
