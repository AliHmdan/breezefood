import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateDialog extends StatefulWidget {
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  double selectedRate = 3.0; // ⭐ double (يدعم 3.5)

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
            const SizedBox(height: 20),

            /// ⭐ RatingBar (DOUBLE – 3.5 SAFE)
            RatingBar.builder(
              initialRating: selectedRate, // 🔹 مهم
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true, // ⭐ يدعم 0.5
              itemCount: 5,
              itemSize: 32,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (double rating) {
                setState(() {
                  selectedRate = rating; // 🔹 حفظ القيمة المختارة
                });
              },
            ),

            const SizedBox(height: 8),

            /// عرض القيمة المختارة (3.5 مثلًا)
            Text(
              selectedRate.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 🔹 يرجّع double (مثل 3.5)
                      Navigator.of(context).pop<double>(selectedRate);
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
