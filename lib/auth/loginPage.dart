import 'package:breezefood/auth/verifyCode.dart';
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // دالة عرض الإشعار
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

  // دالة التعامل مع محاولة الدخول
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // التنقل إلى شاشة التحقق (مُعلَّق)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerfiyCode(phone: phoneController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.primaryColor,
      body: Stack(
        children: [
          // Banner background
          Image.asset(
            "assets/images/top-view-burgers-with-cherry-tomatoes.png",
            width: double.infinity,
            height: 265.h,
            fit: BoxFit.cover,
            cacheWidth: 600,
          ),
          // Logo
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
          // Login container
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
                                // Title and Subtitle
                                const _CustomTitle(
                                  title: "Welcome to breeze",
                                  color: Colors.white,
                                ),
                                SizedBox(height: 2.h),
                                _CustomSubTitle(
                                  subtitle: "Please Enter your phone to login",
                                  color: AppColor.gry,
                                  fontsize: 12.sp,
                                ),
                                SizedBox(height: 32.h),

                                // Phone field
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

                                // Button or loader
                                _isLoading
                                    ? Center(
                                        child: Lottie.asset(
                                          'assets/lottie/loading.json',
                                          width: 120.w,
                                          height: 120.h,
                                        ),
                                      )
                                    : _CustomButton(
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
    );
  }
}

// ------------------------------------
// Custom Widgets (مدمجة ومختصرة)
// ------------------------------------

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

class _CustomButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const _CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColor.white,
            fontFamily: "Manrope",
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _CustomTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _CustomTitle({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Manrope',
        color: color,
      ),
    );
  }
}

class _CustomSubTitle extends StatelessWidget {
  final String subtitle;
  final Color color;
  final double fontsize;

  const _CustomSubTitle({
    super.key,
    required this.subtitle,
    required this.color,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: fontsize,
        color: color,
        fontFamily: "Manrope",
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
