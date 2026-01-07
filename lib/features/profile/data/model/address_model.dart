class AddressModel {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: (json["id"] ?? 0) is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
        address: (json["address"] ?? "").toString(),
        latitude: (json["latitude"] is num)
            ? (json["latitude"] as num).toDouble()
            : double.tryParse("${json["latitude"]}") ?? 0,
        longitude: (json["longitude"] is num)
            ? (json["longitude"] as num).toDouble()
            : double.tryParse("${json["longitude"]}") ?? 0,
        isDefault: (json["is_default"] == true) || (json["is_default"] == 1),
      );
}
