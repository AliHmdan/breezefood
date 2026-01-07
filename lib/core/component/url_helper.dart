class UrlHelper {
  static const String base = "https://breezefood.cloud";

  static String? toFullUrl(String? path) {
    if (path == null) return null;

    var p = path.trim();
    if (p.isEmpty) return null;

    if (p.startsWith("http://") || p.startsWith("https://")) return p;

    if (p.contains(r":\") || p.startsWith("file:")) return null;

    p = p.replaceAll("\\", "/");

    while (p.contains("//")) {
      p = p.replaceAll("//", "/");
    }

    if (p.startsWith("/public/")) p = p.substring("/public".length);
    if (p.startsWith("public/")) p = "/${p.substring("public".length)}";

    if (p.startsWith("logos/")) {
      p = "/public/uploads/$p";
    }

    if (!p.startsWith("/")) p = "/$p";

    return "$base$p";
  }
}
