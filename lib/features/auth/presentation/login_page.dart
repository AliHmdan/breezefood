import 'package:breezefood/core/services/app_notification_service.dart';
import 'package:breezefood/features/auth/presentation/verify_code.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AuthFlowCubit cubit;

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
              child: Text(message, style: const TextStyle(color: Colors.white)),
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

void _handleLogin() async {
  if (!_formKey.currentState!.validate()) {
    _showSnackBar(
      context,
      message: 'تحقق من الحقول المطلوبة',
      background: AppColor.primaryColor,
      icon: Icons.info_outline,
    );
    return;
  }

  final phone = "+963${phoneController.text.trim()}";
  cubit.sendCode(phone: phone); // ✅ بدون توكن
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
            loading: () => EasyLoading.show(status: "Loading..."),
            error: (msg) {
              EasyLoading.dismiss();
              _showSnackBar(
                context,
                message: msg,
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
                  ? (data["message"] ?? "تم إرسال الرمز")
                  : "تم إرسال الرمز";
              _showSnackBar(
                context,
                message: msg.toString(),
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
                                  const CustomTitle(
                                    title: "Welcome to breeze",
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomSubTitle(
                                    subtitle:
                                        "Please Enter your phone to login",
                                    color: AppColor.gry,
                                    fontsize: 12.sp,
                                  ),
                                  SizedBox(height: 32.h),

                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.white,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          border: Border.all(
                                            color: AppColor.gry,
                                          ),
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
                                          hintText: "Phone Number",
                                          validator: (v) {
                                            final val = (v ?? '').trim();
                                            if (val.isEmpty)
                                              return 'أدخل رقم الهاتف';
                                            if (val.length < 8)
                                              return 'رقم الهاتف غير صالح';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24.h),

                                  // زر
                                  CustomButton(
                                    title: "Continue",
                                    onPressed: _handleLogin,
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
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Image.asset(
                  _obscure ? 'assets/icons/eye.png' : 'assets/icons/hide.png',
                  width: 24,
                  height: 24,
                  color: AppColor.black,
                ),
              )
            : null,
      ),
    );
  }
}
