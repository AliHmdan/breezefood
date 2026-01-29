import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/terms/terms.dart';
import 'package:breezefood/features/help_center/help_center.dart';
import 'package:breezefood/features/profile/presentation/widget/dialog_logout.dart';
import 'package:breezefood/features/profile/presentation/ui/info_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/language.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/listtile_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/profile/presentation/ui/addresses_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final ProfileCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<ProfileCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
  }

  @override
  void dispose() {
    // ✅ لا تعمل close إذا cubit من getIt وممكن ينستخدم بصفحات أخرى
    // cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: cubit,
      builder: (context, state) {
        final name = state.maybeWhen(
          loaded: (user, _, __, ___, ____, _____) =>
              user.fullName.isEmpty ? "—" : user.fullName,
          orElse: () => "—",
        );
        final profileImage = state.maybeWhen(
          loaded: (user, _, __, ___, ____, _____) =>
              user.profileImage, // عدّل الاسم حسب موديلك
          orElse: () => null,
        );

        final phone = state.maybeWhen(
          loaded: (user, _, __, ___, ____, _____) =>
              user.phone.isEmpty ? "" : user.phone,
          orElse: () => "",
        );

        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final errorMsg = state.maybeWhen(
          error: (msg) => msg,
          orElse: () => null,
        );

        return Scaffold(
          backgroundColor: AppColor.Dark,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomAppbarProfile(
                title: "profile.title".tr(),
                icon: Icons.arrow_back_ios,
                ontap: () => Navigator.pop(context),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        _avatar(
                          profileImage,
                        ), // ✅ لأن _avatar صار يحول الرابط لحاله

                        SizedBox(height: 12.h),
                        CustomSubTitle(
                          subtitle: name,
                          color: AppColor.gry,
                          fontsize: 16.sp,
                        ),

                        // Text(
                        //   name,
                        //   style: TextStyle(
                        //     color: AppColor.white,
                        //     fontSize: 16.sp,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        if (phone.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          CustomSubTitle(
                            subtitle: phone,
                            color: AppColor.gry,
                            fontsize: 13.sp,
                          ),
                        ],

                        SizedBox(height: 10.h),

                        if (isLoading)
                          SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),

                        if (errorMsg != null && errorMsg.trim().isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            errorMsg,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily:
                                  Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar'
                                  ? 'Cairo'
                                  : 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          TextButton(
                            onPressed: () => cubit.load(),
                            child: Text(
                              "common.retry".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar'
                                    ? 'Cairo'
                                    : 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // --------- Menu 1 ----------
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.r),
                      color: AppColor.black,
                    ),
                    child: Column(
                      children: [
                        ListtileProfile(
                          iconData: Icons.person_outline,
                          title: "profile.personal_info".tr(),
                          onTap: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<HomeCubit>(),
                                    ), // ✅ مرّر الهوم
                                  ],
                                  child: InfoProfile(
                                    profileCubit: getIt<ProfileCubit>(),
                                  ),
                                ),
                              ),
                            );

                            if (res == true) {
                              await cubit.load();

                              final st = cubit.state;
                              final avatarPath = st.maybeWhen(
                                loaded: (user, _, __, ___, ____, _____) =>
                                    user.profileImage,
                                orElse: () => null,
                              );

                              final full = UrlHelper.toFullUrl(avatarPath);
                              if (full != null && full.isNotEmpty) {
                                await CachedNetworkImage.evictFromCache(full);
                              }

                              if (context.mounted) {
                                context.read<HomeCubit>().load();
                              }
                            }
                          },
                        ),

                        // ListtileProfile(
                        //   title: "profile.addresses".tr(),
                        //   svgPath: "assets/icons/location-line.svg",
                        //   onTap: () async {
                        //     final res = await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) =>
                        //             AddressesScreen(profileCubit: cubit),
                        //       ),
                        //     );
                        //     if (res == true) cubit.load();
                        //   },
                        // ),
                        ListtileProfile(
                          svgPath: "assets/icons/language.svg",
                          title: "profile.language".tr(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Language()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // --------- Menu 2 ----------
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.r),
                      color: AppColor.black,
                    ),
                    child: Column(
                      children: [
                        ListtileProfile(
                          svgPath: "assets/icons/chate.svg",
                          title: "profile.help_center".tr(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HelpCenter()),
                          ),
                        ),

                        ListtileProfile(
                          svgPath: "assets/icons/question.svg",
                          title: "profile.terms".tr(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Terms()),
                          ),
                        ),

                        ListtileProfile(
                          svgPath: "assets/icons/logout.svg",
                          title: "profile.logout".tr(),
                          onTap: () => showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _avatar(String? rawPathOrUrl) {
  final full = UrlHelper.toFullUrl(rawPathOrUrl);

  return CircleAvatar(
    radius: 60.r,
    backgroundColor: AppColor.black,
    child: ClipOval(
      child: SizedBox(
        width: 120.w,
        height: 120.w,
        child: (full == null || full.isEmpty)
            ? Icon(Icons.person, color: AppColor.white, size: 44.sp)
            : CachedNetworkImage(
                imageUrl: full,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 120),
                placeholder: (_, __) => Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) =>
                    Icon(Icons.person, color: AppColor.white, size: 44.sp),
              ),
      ),
    ),
  );
}
