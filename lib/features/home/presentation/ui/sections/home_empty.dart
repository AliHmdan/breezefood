import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class HomeEmptyArea extends StatelessWidget {
  final String title;       // ✅ نص جاهز من السيرفر
  final String? subtitle;   // ✅ نص جاهز (اختياري)
  final VoidCallback onRefresh;

  const HomeEmptyArea({
    super.key,
    required this.title,
    this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.white70, size: 44),
            const SizedBox(height: 10),
            Text(
              title, // ✅ بدون tr()
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!, // ✅ بدون tr()
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text("common.retry".tr()), // زر فقط ترجمة عادي
              ),
            ),
          ],
        ),
      ),
    );
  }
}
