import 'package:flutter/material.dart';

class CustomSubTitle extends StatelessWidget {
  final String subtitle;
  final Color color;
  final double fontsize;
  const CustomSubTitle({
    super.key,
    required this.subtitle,
    required this.color,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: fontsize,
        color: color,
        fontFamily: "Manrope",
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
