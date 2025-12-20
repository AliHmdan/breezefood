import 'package:breezefood/auth/UpdateAddressScreen.dart';
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  // 3. دالة وهمية للحفظ (تحاكي الاتصال بالخادم)
  void _saveInformation() async {
    final first = firstnameController.text.trim();
    final last = lastnameController.text.trim();

    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both first and last name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // محاكاة الاتصال بالـ API وحفظ المعلومات (تأخير 1.5 ثانية)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    setState(() => _isLoading = false);

    // محاكاة النجاح في الحفظ والانتقال إلى الشاشة التالية
    // (هنا كان يتم استخدام AuthRepository و SharedPreferences)
    
    // إظهار رسالة نجاح وهمية
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully (Mock)!'), backgroundColor: Colors.green));

    // الانتقال إلى الشاشة التالية (UpdateAddressScreen الوهمية)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UpdateAddressScreen()),
    );
  }

  // 4. دالة بناء حقل الإدخال لتقليل تكرار الكود
  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white, // خلفية الحقل بيضاء
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.Dark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: AppColor.primaryColor,
        style: TextStyle(color: AppColor.Dark, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColor.gry, fontSize: 16.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          border: InputBorder.none, // إزالة البوردر الافتراضي
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder( // إضافة بوردر عند التركيز
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(color: AppColor.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مرنة مع الشاشة
          Image.asset(
            "assets/images/background_auth.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColor.Dark, alignment: Alignment.center, child: const Text("Placeholder", style: TextStyle(color: AppColor.white))),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomArrow (مدمج ومختصر)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w, height: 40.h,
                      decoration: BoxDecoration(color: AppColor.white, shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(Icons.arrow_back_ios, color: AppColor.Dark, size: 16.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // CustomSubTitle (مدمج ومختصر)
                  Text(
                    "Please enter your information",
                    style: TextStyle(
                      fontSize: 18.sp, // تم تعديل الحجم ليكون مناسباً كعنوان
                      color: AppColor.white,
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.bold, // تعديل الوزن ليتناسب مع العنوان
                    ),
                  ),

                  SizedBox(height: 35.h),

                  // حقل الاسم الأول (CustomTextFormField مدمج)
                  _buildTextField(hint: "First Name", controller: firstnameController),

                  SizedBox(height: 20.h),
                  
                  // حقل الاسم الأخير (CustomTextFormField مدمج)
                  _buildTextField(hint: "Last Name", controller: lastnameController),

                  SizedBox(height: 30.h),

                  // الزر (CustomButton مدمج ومختصر)
                  InkWell(
                    onTap: _isLoading ? null : _saveInformation,
                    child: Container(
                      width: double.infinity,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: _isLoading ? AppColor.gry : AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColor.white)
                          : Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColor.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Manrope',
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}