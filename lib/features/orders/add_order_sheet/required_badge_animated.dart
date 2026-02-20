import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequiredBadgeAnimated extends StatefulWidget {
  final bool isRTL;
  final bool animate;
  final bool isSelected;

  final String? requiredAr;
  final String? requiredEn;
  final String? doneAr;
  final String? doneEn;

  const RequiredBadgeAnimated({
    super.key,
    required this.isRTL,
    required this.animate,
    required this.isSelected,
    this.requiredAr,
    this.requiredEn,
    this.doneAr,
    this.doneEn,
  });

  @override
  State<RequiredBadgeAnimated> createState() => _RequiredBadgeAnimatedState();
}

class _RequiredBadgeAnimatedState extends State<RequiredBadgeAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // ✅ Pulse (Required)
  late final Animation<double> _pulseScale = Tween<double>(
    begin: 1.0,
    end: 1.10,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  // ✅ Pop once (Done)
  late final Animation<double> _popScale = Tween<double>(
    begin: 0.92,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

  bool _didPopOnce = false;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _syncAnim(initial: true);
  }

  @override
  void didUpdateWidget(covariant RequiredBadgeAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ صار Done الآن؟ اعمل pop مرة وحدة
    if (!oldWidget.isSelected && widget.isSelected) {
      _startPopOnce();
      return;
    }

    // ✅ رجع Required؟ رجّع pulse
    if (oldWidget.isSelected && !widget.isSelected) {
      _didPopOnce = false;
      _isPopping = false;
      _syncPulse();
      return;
    }

    // ✅ تغيّر animate flag
    if (oldWidget.animate != widget.animate) {
      _syncAnim();
    }
  }

  void _syncAnim({bool initial = false}) {
    if (widget.isSelected) {
      // لو داخل الصفحة وهو Done أصلاً: لا pulse ولا pop (إلا إذا بتحبه)
      _ctrl.stop();
      _ctrl.value = 1.0;
      _didPopOnce = true;
      _isPopping = false;
      return;
    }
    _syncPulse();
    if (initial) {
      // ✅ أحياناً لطافة أكثر لو تبدأ بعد أول فريم
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncPulse();
      });
    }
  }

  void _syncPulse() {
    if (!widget.isSelected && widget.animate) {
      if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    } else {
      if (_ctrl.isAnimating) _ctrl.stop();
      _ctrl.value = 1.0; // scale = 1.0
    }
  }

  Future<void> _startPopOnce() async {
    if (_didPopOnce) return;

    _didPopOnce = true;
    _isPopping = true;

    _ctrl.stop();
    _ctrl.duration = const Duration(milliseconds: 520);

    await _ctrl.forward(from: 0);

    _ctrl.stop();
    _ctrl.value = 1.0;

    _ctrl.duration = const Duration(milliseconds: 900);
    _isPopping = false;

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.isSelected;

    final requiredLabel = widget.isRTL
        ? (widget.requiredAr ?? "مطلوب")
        : (widget.requiredEn ?? "Required");

    final doneLabel = widget.isRTL
        ? (widget.doneAr ?? "تم")
        : (widget.doneEn ?? "Done");

    final bg = isDone ? Colors.green : AppColor.red;

    final border = isDone
        ? Colors.green.withOpacity(0.75)
        : AppColor.red.withOpacity(widget.animate ? 0.9 : 0.6);

    final textColor = isDone ? Colors.white : AppColor.white;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final scale = isDone
            ? (_isPopping ? _popScale.value : 1.0)
            : (widget.animate ? _pulseScale.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 620),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: border,
                width: isDone ? 1.15 : (widget.animate ? 1.15 : 1.0),
              ),
              boxShadow: [
                if (!isDone && widget.animate)
                  if (isDone)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.25),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: isDone
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey("done_icon"),
                          size: 14.sp,
                          color: Colors.white,
                        )
                      : const SizedBox(
                          key: ValueKey("empty_icon"),
                          width: 0,
                          height: 0,
                        ),
                ),
                if (isDone) SizedBox(width: 6.w),
                Text(
                  isDone ? doneLabel : requiredLabel,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
