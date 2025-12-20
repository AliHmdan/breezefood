import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:breezefood/view/profile/widget/custom_button.dart';
import 'package:breezefood/view/profile/widget/custom_textfaild_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class InfoProfile extends StatefulWidget {
  const InfoProfile({super.key});

  @override
  State<InfoProfile> createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  final Map<String, String> avatarMap = const {
    'a1': 'assets/avatars/a1.png',
    'a2': 'assets/avatars/a2.png',
  };

  String? _selectedAvatarCode;

  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  ImageProvider _avatarImageProvider() {
    if (_selectedAvatarCode != null &&
        avatarMap.containsKey(_selectedAvatarCode)) {
      return AssetImage(avatarMap[_selectedAvatarCode]!);
    }
    return const AssetImage('assets/images/person.jpg');
  }

  void _showAvatarPicker() {
    final codes = avatarMap.keys.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.Dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  'اختر صورة Avatar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: codes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final code = codes[i];
                final selected = _selectedAvatarCode == code;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatarCode = code);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColor.LightActive : Colors.white24,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(avatarMap[code]!),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomAppbarProfile(
            title: "Profile",
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
              // ---------- Avatar ----------
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70.r,
                    backgroundImage: _avatarImageProvider(),
                  ),
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColor.Dark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.LightActive,
                          width: 1.w,
                        ),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/edit.svg",
                        width: 18.w,
                        height: 18.h,
                        colorFilter: const ColorFilter.mode(
                          AppColor.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 35.h),

              // ---------- Fields ----------
              CustomTextfaildInfo(
                label: "First Name",
                hint: "First Name",
                controller: _firstCtrl,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 15.h),
              CustomTextfaildInfo(
                label: "Last Name",
                hint: "Last Name",
                controller: _lastCtrl,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 15.h),
              CustomTextfaildInfo(
                label: "Phone Number",
                hint: "0938204147",
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 30.h),

              // ---------- Save Button ----------
              CustomButton(
                title: "Save",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved locally")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
