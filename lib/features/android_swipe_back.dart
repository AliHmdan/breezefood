import 'package:flutter/material.dart';

class AndroidSwipeBack extends StatefulWidget {
  final Widget child;
  const AndroidSwipeBack({super.key, required this.child});

  @override
  State<AndroidSwipeBack> createState() => _AndroidSwipeBackState();
}

class _AndroidSwipeBackState extends State<AndroidSwipeBack> {
  double _dx = 0;
  double _dy = 0;
  bool _isDragging = false;

  static const double _triggerDistance = 120; // مسافة الرجوع
  static const double _maxTranslate = 50;     // أقصى تحرك بصري

  @override
  Widget build(BuildContext context) {
    // نحسب مقدار التحريك البصري
    final translateX = (_dx / _triggerDistance * _maxTranslate)
        .clamp(0.0, _maxTranslate);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onHorizontalDragStart: (_) {
        _isDragging = true;
      },

      onHorizontalDragUpdate: (details) {
        _dx += details.delta.dx;
      },

      onVerticalDragUpdate: (details) {
        _dy += details.delta.dy;
      },

      onHorizontalDragEnd: (_) {
        _isDragging = false;

        // شرط الرجوع
        if (_dx > _triggerDistance && _dx.abs() > _dy.abs()) {
          Navigator.of(context).maybePop();
        }

        // إعادة القيم
        setState(() {
          _dx = 0;
          _dy = 0;
        });
      },

      onVerticalDragEnd: (_) {
        _isDragging = false;
        setState(() {
          _dx = 0;
          _dy = 0;
        });
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: _isDragging ? 0 : 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(translateX, 0, 0),
        child: widget.child,
      ),
    );
  }
}
