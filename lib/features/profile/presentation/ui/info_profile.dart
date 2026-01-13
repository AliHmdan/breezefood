import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
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
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _didFillOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = widget.profileCubit.state;

      st.maybeWhen(
        loaded: (user, addresses, avatars, selectedAvatarId, isSaving, message) {
          _fillFromLoadedOnce(st);
        },
        orElse: () {
          widget.profileCubit.load();
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
      loaded: (user, _, __, ___, ____, _____) {
        _firstCtrl.text = user.firstName;
        _lastCtrl.text = user.lastName;
        _phoneCtrl.text = user.phone;
        _didFillOnce = true;
      },
      orElse: () {},
    );
  }

  ImageProvider _avatarImageProvider(ProfileState state) {
    // ✅ 1) إذا المستخدم مختار Avatar من القائمة -> اعرضه فوراً
    final selectedUrl = state.maybeWhen(
      loaded: (user, addresses, avatars, selectedAvatarId, isSaving, message) {
        if (selectedAvatarId == null) return null;
        final idx = avatars.indexWhere((a) => a.id == selectedAvatarId);
        if (idx == -1) return null;
        final url = avatars[idx].fullUrl;
        return (url.isEmpty) ? null : url;
      },
      orElse: () => null,
    );

    if (selectedUrl != null) return NetworkImage(selectedUrl);

    // ✅ 2) صورة من السيرفر ضمن user.profileImage
    final serverPath = state.maybeWhen(
      loaded: (user, _, __, ___, ____, _____) => user.profileImage,
      orElse: () => null,
    );

    final fullUrl = UrlHelper.toFullUrl(serverPath);
    if (fullUrl != null && fullUrl.isNotEmpty) {
      return NetworkImage(fullUrl);
    }

    // ✅ 3) fallback
    return const AssetImage('assets/images/person.jpg');
  }

  Future<void> _openAvatarPicker(ProfileState state) async {
    // ✅ حمّل avatars لو فاضيين
    final avatarsEmpty = state.maybeWhen(
      loaded: (_, __, avatars, ___, ____, _____) => avatars.isEmpty,
      orElse: () => true,
    );

    if (avatarsEmpty) {
      await widget.profileCubit.loadAvatars();
      if (!mounted) return;
    }

    final latestState = widget.profileCubit.state;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.Dark,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: latestState.maybeWhen(
            loaded: (user, addresses, avatars, selectedAvatarId, isSaving, message) {
              return Column(
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
                  SizedBox(height: 12.h),

                  if (avatars.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: avatars.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (_, i) {
                        final av = avatars[i];
                        final selected = selectedAvatarId == av.id;

                        return GestureDetector(
                          onTap: () {
                            widget.profileCubit.selectAvatar(av.id);
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
                              backgroundColor: Colors.white10,
                              backgroundImage: av.fullUrl.isNotEmpty
                                  ? NetworkImage(av.fullUrl)
                                  : const AssetImage('assets/images/person.jpg') as ImageProvider,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
            orElse: () => Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
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
        _fillFromLoadedOnce(state);

        final msg = state.maybeWhen(
          loaded: (_, __, ___, ____, _____, message) => message,
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
          loaded: (_, __, ___, ____, isSaving, _____) => isSaving,
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
            initial: () => const Center(child: CircularProgressIndicator()),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loaded: (_, __, ___, ____, _____, ______) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 70.r,
                            backgroundImage: _avatarImageProvider(state),
                          ),
                          GestureDetector(
                            onTap: () => _openAvatarPicker(state),
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
