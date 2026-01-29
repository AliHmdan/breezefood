import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:breezefood/features/notifications/presentation/ui/notifications_screen.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedAvatar extends StatelessWidget {
  final String? url; // path من API (uploads/avatars/..)
  final double size; // قطر الصورة
  final String fallbackAsset; // صورة افتراضية
  final VoidCallback? onTap;

  const CachedAvatar({
    super.key,
    required this.url,
    this.size = 40,
    this.fallbackAsset = 'assets/images/01.jpg',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final full = UrlHelper.toFullUrl(url); // ✅ استخدم UrlHelper تبعك

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: ClipOval(
        child: SizedBox(
          width: size.w,
          height: size.w,
          child: (full == null || full.isEmpty)
              ? Image.asset(fallbackAsset, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: full,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 120),
                  placeholder: (_, __) => Container(
                    color: Colors.white10,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      Image.asset(fallbackAsset, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

class CustomAppbarHome extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? image;
  final IconData? icon;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;

  final VoidCallback? onLocationTap;

  const CustomAppbarHome({
    super.key,
    this.avatarUrl,
    required this.title,
    this.subtitle,
    this.image,
    this.icon,
    this.onProfileTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onProfileTap,
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, st) {
              final path = st.maybeWhen(
                loaded: (user, _, __, ___, ____, _____) => user.profileImage,
                orElse: () => null,
              );

              final url = UrlHelper.toFullUrl(path);

              return CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColor.black,
                child: ClipOval(
                  child: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: (url == null || url.isEmpty)
                        ? Container(
                            color: Colors.grey.shade200, // خلفية للأيقونة
                            child: Center(
                              child: Icon(
                                Icons.person_outline,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),

        // ✅ النص والموقع: يفتح اختيار الموقع فقط
        Expanded(
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTitle(title: title, color: AppColor.white),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image != null)
                        SvgPicture.asset(
                          image!,
                          color: AppColor.LightActive,
                          width: 20,
                          height: 20,
                        ),
                      SizedBox(width: image != null ? 4 : 0),
                      if (subtitle != null)
                        CustomSubTitle(
                          subtitle: "$subtitle",
                          color: AppColor.LightActive,
                          fontsize: 12.sp,
                        ),
                      if (icon != null)
                        Icon(icon, color: AppColor.LightActive, size: 24.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<NotificationCubit>(),
                  child: NotificationPage(),
                ),
              ),
            );
          },
          child: Container(
            width: 35.w,
            height: 35.h,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.LightActive, width: 2),
            ),
            child: SvgPicture.asset(
              'assets/icons/notification.svg',
              color: Colors.white,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String? url;
  const _AvatarImage({this.url});

  @override
  Widget build(BuildContext context) {
    final full = UrlHelper.toFullUrl(url);

    if (full == null || full.isEmpty) {
      return Image.asset(
        'assets/images/01.jpg',
        width: 40.w,
        height: 40.h,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      full,
      width: 40.w,
      height: 40.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/01.jpg',
        width: 40.w,
        height: 40.h,
        fit: BoxFit.cover,
      ),
    );
  }
}
