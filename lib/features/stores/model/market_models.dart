class MarketModel {
  final int id;
  final String name;
  final String? logo;

  MarketModel({required this.id, required this.name, this.logo});

  factory MarketModel.fromJson(Map<String, dynamic> json) => MarketModel(
        id: (json['id'] ?? 0) as int,
        name: (json['name'] ?? '') as String,
        logo: json['logo'] as String?,
      );
}

class CategoryModel {
  final int id;
  final String name;
  final String? image;

  CategoryModel({required this.id, required this.name, this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] ?? 0) as int,
        name: (json['name'] ?? '') as String,
        image: json['image'] as String?,
      );
}

class MarketItemModel {
  final int id;
  final int categoryId;
  final String basePrice;
  final bool isAvailable;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  MarketItemModel({
    required this.id,
    required this.categoryId,
    required this.basePrice,
    required this.isAvailable,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  factory MarketItemModel.fromJson(Map<String, dynamic> json) => MarketItemModel(
        id: (json['id'] ?? 0) as int,
        categoryId: (json['category_id'] ?? 0) as int,
        basePrice: (json['base_price'] ?? '0') as String,
        isAvailable: (json['is_available'] ?? false) as bool,
        nameAr: (json['name_ar'] ?? '') as String,
        nameEn: (json['name_en'] ?? '') as String,
        descriptionAr: (json['description_ar'] ?? '') as String,
        descriptionEn: (json['description_en'] ?? '') as String,
      );
}
