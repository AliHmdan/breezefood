import 'dart:async';
import 'package:breezefood/auth/InformationScreen.dart';
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerfiyCode extends StatefulWidget {
  final String phone;
  const VerfiyCode({super.key, required this.phone});
  @override
  State<VerfiyCode> createState() => _VerfiyCodeState();
}

class _VerfiyCodeState extends State<VerfiyCode> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _message;
  Color _messageColor = Colors.transparent;

  void _verifyCode(String code) async {
    if (code.length != 4) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (code == "1234") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InformationScreen()),
      );
      _showSuccess("Verification successful!");
      // يمكنك إضافة منطق التنقل هنا عند النجاح
    } else {
      _showError("Incorrect code. Please try again.");
    }
  }

  void _resendCode() async {
    setState(() {
      _isResending = true;
      _message = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isResending = false);
    _showSuccess("New code sent to ${widget.phone}.");
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
      body: Stack(
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
                  // CustomArrow (Simplified)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
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
                  // CustomTitle (Simplified)
                  Text(
                    "Enter the Code",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // CustomSubTitle (Simplified)
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

                  // PinCodeTextField
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
                      onCompleted: _verifyCode,
                      onChanged: (value) {},
                    ),
                  ),

                  // Message Bar (Simplified)
                  if (_message != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        _message!,
                        style: TextStyle(fontSize: 14.sp, color: _messageColor),
                      ),
                    ),

                  SizedBox(height: 20.h),

                  // Resend Code (Simplified)
                  InkWell(
                    onTap: _isResending || _isLoading ? null : _resendCode,
                    child: Text(
                      _isResending ? "Sending..." : "Resend Code",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                        color: _isResending || _isLoading
                            ? AppColor.gry
                            : AppColor.primaryColor,
                      ),
                    ),
                  ),

                  // Loading Indicator
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
