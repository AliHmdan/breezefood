import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/auth/presentation/verify_code.dart';
import 'package:breezefood/features/auth/presentation/ui/terms.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AuthFlowCubit cubit;

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // ✅ يترجم فقط إذا الرسالة key، غير هيك يعرضها كما هي
  String trOrRaw(String s) {
    final k = s.trim();
    if (k.isEmpty) return k;

    // keys عادة بتكون فيها نقطة: "errors.invalid_phone"
    // أو underscore: "invalid_phone"
    final looksLikeKey = k.contains('.') || k.contains('_');

    if (!looksLikeKey) return k;

    final translated = k.tr();
    // إذا ما انترجم ورجع نفس النص تماماً -> اعتبره raw
    return translated == k ? k : translated;
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    Color? background,
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: background ?? Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openTermsAndMaybeAccept() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TermsDialog(),
    );

    if (!mounted) return;

    if (ok == true) {
      setState(() => _acceptedTerms = true);
    }
  }

  void _handleLogin() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      _showSnackBar(
        context,
        message: "auth.check_required_fields".tr(),
        background: AppColor.primaryColor,
        icon: Icons.info_outline,
      );
      return;
    }

    if (!_acceptedTerms) {
      _showSnackBar(
        context,
        message: "terms.must_accept".tr(),
        background: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final phone = "+963${phoneController.text.trim()}";
    cubit.sendCode(phone: phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.primaryColor,
      body: BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (context, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "common.loading".tr()),
            error: (msg) {
              EasyLoading.dismiss();
              _showSnackBar(
                context,
                message: trOrRaw(msg), // ✅ هون الإصلاح
                background: Colors.redAccent,
                icon: Icons.error_outline,
              );
            },
            codeSent: (data) {
              EasyLoading.dismiss();

              final phone = "+963${phoneController.text.trim()}";
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VerfiyCode(phone: phone)),
              );

              final msg = (data is Map)
                  ? (data["message"]?.toString() ?? "auth.code_sent".tr())
                  : "auth.code_sent".tr();

              _showSnackBar(
                context,
                message: msg,
                background: AppColor.primaryColor,
                icon: Icons.check_circle_outline,
              );
            },
          );
        },
        child: Stack(
          children: [
            Image.asset(
              "assets/images/top-view-burgers-with-cherry-tomatoes.png",
              width: double.infinity,
              height: 265.h,
              fit: BoxFit.cover,
              cacheWidth: 600,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: Image.asset(
                  "assets/images/breeze-food2.png",
                  width: 150.w,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 228.h,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.Dark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(
                                    title: "auth.welcome_title".tr(),
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomSubTitle(
                                    subtitle: "auth.login_hint".tr(),
                                    color: AppColor.gry,
                                    fontsize: 12.sp,
                                  ),
                                  SizedBox(height: 32.h),

                                  // Phone
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.white,
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(color: AppColor.gry),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/icons/syria.png',
                                              width: 24.w,
                                              height: 24.h,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '+963',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: _CustomTextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.number,
                                          hintText: "auth.phone_number".tr(),
                                          validator: (v) {
                                            final val = (v ?? '').trim();
                                            if (val.isEmpty) {
                                              return "auth.enter_phone".tr();
                                            }
                                            if (val.length < 8) {
                                              return "auth.invalid_phone".tr();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 14.h),

                                  // Terms checkbox + tap
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _acceptedTerms,
                                        activeColor: AppColor.primaryColor,
                                        onChanged: (v) async {
                                          if (v == true) {
                                            await _openTermsAndMaybeAccept();
                                          } else {
                                            setState(() => _acceptedTerms = false);
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _openTermsAndMaybeAccept,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 12.h),
                                            child: Text(
                                              "terms.tap_to_view_and_accept".tr(),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12.sp,
                                                height: 1.4,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white38,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24.h),

                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55.h,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15.r),
                                      onTap: _acceptedTerms ? _handleLogin : () {
                                        _showSnackBar(
                                          context,
                                          message: "terms.must_accept".tr(),
                                          background: Colors.orange,
                                          icon: Icons.warning_amber_rounded,
                                        );
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _acceptedTerms
                                              ? AppColor.primaryColor
                                              : AppColor.gry,
                                          borderRadius: BorderRadius.circular(15.r),
                                        ),
                                        child: Text(
                                          "common.continue".tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Manrope',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;

  const _CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
  });

  @override
  State<_CustomTextFormField> createState() => __CustomTextFormFieldState();
}

class __CustomTextFormFieldState extends State<_CustomTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(color: AppColor.LightActive),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColor.gry,
          fontSize: 14.sp,
          fontFamily: 'Manrope',
        ),
        filled: true,
        fillColor: AppColor.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
