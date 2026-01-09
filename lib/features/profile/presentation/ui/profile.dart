import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/terms/terms.dart';
import 'package:breezefood/features/helpCenter/help_center.dart';
import 'package:breezefood/features/profile/presentation/widget/dialog_logout.dart';
import 'package:breezefood/features/profile/presentation/ui/info_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/language.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/listtile_profile.dart';
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
          loaded: (user, _, __, ___,____,_____) =>
              user.fullName.isEmpty ? "—" : user.fullName,
          orElse: () => "—",
        );

        final phone = state.maybeWhen(
          loaded: (user, _, __, ___,____,_____) => user.phone.isEmpty ? "" : user.phone,
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
                        // ✅ ما عاد نعتمد على asset ممكن يكون غير موجود
                        CircleAvatar(
                          radius: 60.r,
                          backgroundColor: AppColor.black,
                          child: Icon(
                            Icons.person,
                            color: AppColor.white,
                            size: 44.sp,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Text(
                          name,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (phone.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            phone,
                            style: TextStyle(
                              color: AppColor.gry,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          TextButton(
                            onPressed: () => cubit.load(),
                            child: Text(
                              "common.retry".tr(),
                              style: const TextStyle(color: Colors.white),
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
                                builder: (_) =>
                                    InfoProfile(profileCubit: cubit),
                              ),
                            );
                            if (res == true) cubit.load();
                          },
                        ),

                        ListtileProfile(
                          title: "profile.addresses".tr(),
                          svgPath: "assets/icons/location-line.svg",
                          onTap: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddressesScreen(profileCubit: cubit),
                              ),
                            );
                            if (res == true) cubit.load();
                          },
                        ),

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
