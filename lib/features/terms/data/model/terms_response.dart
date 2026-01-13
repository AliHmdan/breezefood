class TermsResponse {
  final String ar;
  final String en;

  TermsResponse({required this.ar, required this.en});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      ar: (json['ar'] ?? '').toString(),
      en: (json['en'] ?? '').toString(),
    );
  }

  String byLocale(String localeCode) {
    // easy_localization: ar / en
    if (localeCode.toLowerCase().startsWith('ar')) return ar;
    return en;
  }
}
