import 'package:flutter/material.dart';

///
/// here my friend if you want to detect the number
///
// String extractLocalizedText(String input, Locale locale) {
//   final lang = locale.languageCode;
//
//   final arabicRegex = RegExp(r'[\u0600-\u06FF]+');
//   final englishRegex = RegExp(r'[A-Za-z]+');
//
//   final arabicMatches = arabicRegex.allMatches(input);
//   final englishMatches = englishRegex.allMatches(input);
//
//   String arabicText = arabicMatches.map((m) => m.group(0)).join(' ').trim();
//   String englishText = englishMatches.map((m) => m.group(0)).join(' ').trim();
//
//   if (lang == 'ar') {
//     return arabicText.isNotEmpty ? arabicText : englishText;
//   } else {
//     return englishText.isNotEmpty ? englishText : arabicText;
//   }
// }
String extractLocalizedText(String input, Locale locale) {
  final lang = locale.languageCode;

  final arabicRegex = RegExp(r'[ء-ي]+');

  final englishRegex = RegExp(r'[A-Za-z]+');

  final arabicMatches = arabicRegex.allMatches(input);
  final englishMatches = englishRegex.allMatches(input);

  String arabicText = arabicMatches.map((m) => m.group(0)).join(' ').trim();
  String englishText = englishMatches.map((m) => m.group(0)).join(' ').trim();

  if (lang == 'ar') {
    return arabicText.isNotEmpty ? arabicText : englishText;
  } else {
    return englishText.isNotEmpty ? englishText : arabicText;
  }
}
