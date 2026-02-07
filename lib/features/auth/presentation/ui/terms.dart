import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsDialog extends StatefulWidget {
  const TermsDialog({super.key});

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  // 0 = AR, 1 = EN
  int _langIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.black,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: BlocProvider(
        create: (_) => getIt<TermsCubit>()..load(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Segmented language switch
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      _segButton(
                        title: "AR",
                        selected: _langIndex == 0,
                        onTap: () => setState(() => _langIndex = 0),
                      ),
                      SizedBox(width: 8.w),
                      _segButton(
                        title: "EN",
                        selected: _langIndex == 1,
                        onTap: () => setState(() => _langIndex = 1),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h),
              const Divider(color: Colors.white12, height: 1),

              // Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: BlocBuilder<TermsCubit, TermsState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (msg) => Center(
                          child: Text(
                            msg,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        loaded: (data) {
                          final ar = data.ar.replaceAll('\r\n', '\n').trim();
                          final en = data.en.replaceAll('\r\n', '\n').trim();

                          final text = (_langIndex == 0) ? ar : en;

                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Directionality(
                                  textDirection: _langIndex == 0
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Text(
                                    text.isEmpty ? "—" : text,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.88),
                                      fontSize: 13.sp,
                                      height: 1.65,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("I Agree"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColor.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
