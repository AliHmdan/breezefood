import 'package:breezefood/features/rating/ui/RatingStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class RestaurantRatingCard extends StatelessWidget {
  final int restaurantId;

  const RestaurantRatingCard({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RatingStore>();
    final ratingData = store.getRating(restaurantId);

    double rating = ratingData?.rating ?? 4.0;
    String comment = ratingData?.comment ?? 'الأكل ممتاز والتوصيل سريع';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                allowHalfRating: true,
                itemSize: 22,
                itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  store.setRating(restaurantId, value, comment);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                final result = await _showEditDialog(
                  context,
                  rating,
                  comment,
                );

                if (result != null) {
                  store.setRating(
                    restaurantId,
                    result.$1,
                    result.$2,
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
Future<(double, String)?> _showEditDialog(
    BuildContext context,
    double initialRating,
    String initialComment,
    ) {
  double rating = initialRating;
  final controller = TextEditingController(text: initialComment);

  return showDialog<(double, String)>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('تعديل التقييم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: rating,
            allowHalfRating: true,
            itemBuilder: (_, __) =>
            const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (value) => rating = value,
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'اكتب تعليقك'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, (rating, controller.text));
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
}
