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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        _dx += details.delta.dx;
      },
      onVerticalDragUpdate: (details) {
        _dy += details.delta.dy;
      },
      onHorizontalDragEnd: (_) {
        // شرط احترافي
        if (_dx > 120 && _dx.abs() > _dy.abs()) {
          Navigator.of(context).maybePop();
        }
        _dx = 0;
        _dy = 0;
      },
      onVerticalDragEnd: (_) {
        _dx = 0;
        _dy = 0;
      },
      child: widget.child,
    );
  }
}
