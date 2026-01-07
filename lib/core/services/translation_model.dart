class TranslationModel {
  final String locale;
  final String name;
  final String description;

  TranslationModel({
    required this.locale,
    required this.name,
    required this.description,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      locale: (json["locale"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
    );
  }
}
