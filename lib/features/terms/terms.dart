import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  late final TermsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<TermsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermsCubit, TermsState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColor.Dark,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomAppbarProfile(
                icon: Icons.arrow_back_ios,
                ontap: () => Navigator.pop(context),
              ),
            ),
          ),
          body: state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  msg,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            loaded: (data) {
              final locale = context.locale.languageCode; // ar / en
              final text = data
                  .byLocale(locale)
                  .replaceAll('\r\n', '\n')
                  .trim();

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Actions (Copy / Share)
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.copy_rounded,
                            title: "Copy",
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: text),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.share_rounded,
                            title: "Share",
                            onTap: () async {
                              await Share.share(text);
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // ✅ Text Box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            text.isEmpty ? "—" : text,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 14.sp,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: AppColor.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
