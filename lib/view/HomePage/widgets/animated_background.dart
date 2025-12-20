import 'dart:async';
import 'dart:math' as math;
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final double height;

  /// قائمة شخصيات SVG تُعرض فوق الخلفية
  final List<CartoonSvg> characters;

  /// تفعيل حركة الطفو الخفيفة للشخصيات
  final bool enableFloat;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.height = 300,
    this.characters = const [],
    this.enableFloat = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  final List<Color> colors = [
    AppColor.red,
    AppColor.yellow,
    AppColor.primaryColor,
  ];

  int currentIndex = 0;
  late Timer timer;

  late AnimationController _floatCtl;

  @override
  void initState() {
    super.initState();

    // تبديل ألوان الخلفية
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % colors.length;
      });
    });

    // حركة الطفو للشخصيات
    _floatCtl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer.cancel();
    _floatCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: widget.height,
        width: width,
        decoration: BoxDecoration(
          color: colors[currentIndex],
          borderRadius: BorderRadius.circular(11.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الزخرفة (سترايبس)
            CustomPaint(painter: StripePainter()),

            // المحتوى الذي تمرّره أنت
            Positioned.fill(child: widget.child),

            // الشخصيات (SVG) فوق المحتوى
            ...widget.characters.map(
              (c) => _SvgCharacterLayer(
                spec: c,
                controller: widget.enableFloat ? _floatCtl : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مواصفات كل شخصية SVG
class CartoonSvg {
  /// محاذاة داخل الصندوق
  final Alignment alignment;

  /// عرض الشخصية (يمكنك استخدام .w مع ScreenUtil إن أحببت)
  final double width;

  /// مسافة داخلية إضافية
  final EdgeInsets margin;

  /// مسار ملف SVG داخل الأصول
  final String assetPath;

  /// سعة حركة الطفو (بالبكسل)
  final double floatAmplitude;

  /// إزاحة طور للحركة (لجعل كل شخصية تتحرك بإيقاع مختلف)
  final double phaseShift;

  /// دوران اختياري بالدرجات
  final double rotationDeg;

  const CartoonSvg({
    required this.alignment,
    required this.width,
    required this.assetPath,
    this.margin = EdgeInsets.zero,
    this.floatAmplitude = 6,
    this.phaseShift = 0,
    this.rotationDeg = 0,
  });
}

class _SvgCharacterLayer extends StatelessWidget {
  final CartoonSvg spec;
  final AnimationController? controller;

  const _SvgCharacterLayer({
    required this.spec,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(spec.assetPath, fit: BoxFit.contain);

    Widget content = Align(
      alignment: spec.alignment,
      child: Padding(
        padding: spec.margin,
        child: SizedBox(
          width: spec.width.w, // يعمل حتى بدون ScreenUtil (يُعتبر px)
          child: spec.rotationDeg.abs() < 0.01
              ? svg
              : Transform.rotate(
                  angle: spec.rotationDeg * math.pi / 180,
                  alignment: Alignment.center,
                  child: svg,
                ),
        ),
      ),
    );

    if (controller == null || spec.floatAmplitude == 0) {
      return content;
    }

    return AnimatedBuilder(
      animation: controller!,
      child: content,
      builder: (context, child) {
        final t = controller!.value; // 0..1
        final dy = math.sin((t * 2 * math.pi) + spec.phaseShift) * spec.floatAmplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }
}

class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    const stripeWidth = 80.0;
    const gap = 40.0;

    for (double x = -size.height;
        x < size.width + size.height;
        x += stripeWidth + gap) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - size.height, size.height)
        ..lineTo(x - size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
