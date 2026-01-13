import 'package:breezefood/core/component/url_helper.dart';

class AvatarModel {
  final int id;
  final String path;

  const AvatarModel({required this.id, required this.path});

  factory AvatarModel.fromJson(Map<String, dynamic> json) => AvatarModel(
        id: (json["id"] ?? 0) as int,
        path: (json["path"] ?? "").toString(),
      );

  String get fullUrl {
    // استخدم UrlHelper اللي عندك
    return UrlHelper.toFullUrl(path) ?? "";
  }
}

class AvatarsResponse {
  final List<AvatarModel> data;

  const AvatarsResponse({required this.data});

  factory AvatarsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["data"];
    final list = (raw is List)
        ? raw.whereType<Map>().map((e) => AvatarModel.fromJson(e.cast<String, dynamic>())).toList()
        : <AvatarModel>[];
    return AvatarsResponse(data: list);
  }
}
