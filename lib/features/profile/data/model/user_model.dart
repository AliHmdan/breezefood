class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? profileImage;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profileImage,
  });

  String get fullName => "${firstName.trim()} ${lastName.trim()}".trim();

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _toInt(json["id"]),
        firstName: (json["first_name"] ?? "").toString(),
        lastName: (json["last_name"] ?? "").toString(),
        phone: (json["phone"] ?? "").toString(),
        profileImage: json["profile_image"] as String?,
      );
}
