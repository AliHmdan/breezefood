import 'package:flutter/material.dart';

class RatingPopup extends StatefulWidget {
  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int selectedRate = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "What is your rate?",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRate = index + 1;
                    });
                  },
                  icon: Icon(
                    selectedRate >= index + 1 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 35,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please share your rate about the restaurant",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedRate);
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
