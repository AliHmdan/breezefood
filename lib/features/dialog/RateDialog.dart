import 'package:flutter/material.dart';

class RateDialog extends StatefulWidget {
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  int selectedRate = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2F2F2F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What is your rate?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            /// ⭐ Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRate = starIndex;
                    });
                  },
                  icon: Icon(
                    starIndex <= selectedRate
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),
            const Text(
              'Please share your rate\nabout the restaurant',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedRate == 0
                        ? null
                        : () {
                      /// 🔹 هنا فقط نغلق الـ dialog
                      /// (أو ترجع القيمة إذا حبيت)
                      Navigator.pop(context, selectedRate);
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
