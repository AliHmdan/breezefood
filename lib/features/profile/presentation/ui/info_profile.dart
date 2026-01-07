import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_textfaild_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class InfoProfile extends StatefulWidget {
  final ProfileCubit profileCubit;
  const InfoProfile({super.key, required this.profileCubit});

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
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _didFillOnce = false;

  @override
  void initState() {
    super.initState();

    // ✅ 1) إذا الداتا مش Loaded → اعمل Fetch
    // ✅ 2) إذا Loaded جاهزة → عبّي controllers فوراً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = widget.profileCubit.state;

      st.maybeWhen(
        loaded: (_, __, ___, ____) {
          _fillFromLoadedOnce(st);
        },
        orElse: () {
          widget.profileCubit.load(); // ✅ fetch latest
        },
      );
    });
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _fillFromLoadedOnce(ProfileState state) {
    if (_didFillOnce) return;

    state.maybeWhen(
      loaded: (user, _, __, ___) {
        _firstCtrl.text = user.firstName;
        _lastCtrl.text = user.lastName;
        _phoneCtrl.text = user.phone;
        _didFillOnce = true;
      },
      orElse: () {},
    );
  }

  ImageProvider _avatarImageProvider() {
    if (_selectedAvatarCode != null &&
        avatarMap.containsKey(_selectedAvatarCode)) {
      return AssetImage(avatarMap[_selectedAvatarCode]!);
    }
    return const AssetImage(
      'assets/images/person.jpg',
    ); // إذا عندك مشكلة assets، بدك تحطها بالـ pubspec
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
            Row(
              children: [
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
              ],
            ),
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

  bool _validate() {
    if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter first & last name"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: widget.profileCubit,

      listener: (context, state) {
        // ✅ أول ما تجي loaded بعد load() → عبّي controllers
        _fillFromLoadedOnce(state);

        final msg = state.maybeWhen(
          loaded: (_, __, ___, message) => message,
          orElse: () => null,
        );

        if (msg != null && msg.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
          );
        }
      },

      builder: (context, state) {
        final isSaving = state.maybeWhen(
          loaded: (_, __, isSaving, ___) => isSaving,
          orElse: () => false,
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
          body: state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () => widget.profileCubit.load(),
                      child: Text(
                        "common.retry".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loaded: (_, __, ___, ____) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    children: [
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
                        // ✅ إذا ما عندك API لتعديل رقم الهاتف خلّيه readOnly
                        // readOnly: true,
                      ),

                      SizedBox(height: 30.h),

                      CustomButton(
                        title: isSaving ? "common.saving".tr() : "common.save".tr(),

                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!_validate()) return;

                                await widget.profileCubit.saveProfile(
                                  firstName: _firstCtrl.text.trim(),
                                  lastName: _lastCtrl.text.trim(),
                                );

                                if (!mounted) return;
                                Navigator.pop(context, true);
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
