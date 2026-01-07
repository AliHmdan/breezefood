import 'dart:async';
import 'package:breezefood/features/auth/presentation/information_screen.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';

class VerfiyCode extends StatefulWidget {
  final String phone;
  const VerfiyCode({super.key, required this.phone});

  @override
  State<VerfiyCode> createState() => _VerfiyCodeState();
}

class _VerfiyCodeState extends State<VerfiyCode> {
  late final AuthFlowCubit cubit;

  bool _isResending = false;
  bool _isVerifying = false; // ✅ لمنع double submit
  String? _message;
  Color _messageColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();
  }

  @override
  void dispose() {
    // ✅ مهم إذا cubit مو جاي من BlocProvider
    cubit.close();
    super.dispose();
  }

  void _verifyCode(String code) {
    final c = code.trim();
    if (c.length != 4) return;

    // ✅ منع التكرار (PinCode sometimes fires twice)
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _message = null;
    });

    cubit.verify(phone: widget.phone, code: c); // ✅ /verify-phone (token داخله)
  }

  void _resendCode() {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _message = null;
    });

    cubit.resend(phone: widget.phone); // ✅ /resend-code (بدون await)
  }

  void _showSuccess(String msg) {
    setState(() {
      _message = msg;
      _messageColor = Colors.greenAccent;
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _showError(String msg) {
    setState(() {
      _message = msg;
      _messageColor = Colors.redAccent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (context, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "Verifying..."),

            error: (msg) {
              EasyLoading.dismiss();
              if (mounted) {
                setState(() {
                  _isVerifying = false; // ✅ فك القفل
                  _isResending = false; // ✅ فك القفل
                });
              }
              _showError(msg);
            },

            codeResent: (data) {
              EasyLoading.dismiss();
              if (mounted) setState(() => _isResending = false);

              final msg = (data is Map)
                  ? (data["message"] ?? "تم إرسال الرمز")
                  : "تم إرسال الرمز";
              _showSuccess(msg.toString());
            },

            verified: (data) {
              EasyLoading.dismiss();
              if (mounted) setState(() => _isVerifying = false);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InformationScreen()),
              );
            },
          );
        },
        child: Stack(
          children: [
            Image.asset(
              "assets/images/background_auth.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColor.Dark,
                alignment: Alignment.center,
                child: const Text(
                  "Placeholder",
                  style: TextStyle(color: AppColor.white),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: AppColor.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColor.Dark,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Enter the Code",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Enter the verification code we just sent to ${widget.phone}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.gry,
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 45.h),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: PinCodeTextField(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        appContext: context,
                        length: 4,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 70,
                          fieldWidth: 70,
                          activeColor: AppColor.primaryColor,
                          selectedColor: AppColor.primaryColor,
                          inactiveColor: AppColor.gry,
                          activeBorderWidth: 4,
                          selectedBorderWidth: 4,
                          inactiveBorderWidth: 4,
                          activeFillColor: AppColor.white,
                          selectedFillColor: AppColor.white,
                          inactiveFillColor: AppColor.gry,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,

                        // ✅ منع إدخال/تأكيد أثناء verify
                        enabled: !_isVerifying,

                        onCompleted: _verifyCode,
                        onChanged: (_) {},
                      ),
                    ),

                    if (_message != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          _message!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: _messageColor,
                          ),
                        ),
                      ),

                    SizedBox(height: 20.h),

                    InkWell(
                      onTap: (_isResending || _isVerifying)
                          ? null
                          : _resendCode,
                      child: Text(
                        _isResending ? "Sending..." : "Resend Code",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w400,
                          color: (_isResending || _isVerifying)
                              ? AppColor.gry
                              : AppColor.primaryColor,
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
    );
  }
}
