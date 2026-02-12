class UrlHelper {
  static const String base = "https://breezefood.cloud";

  static String? toFullUrl(String? path) {
    if (path == null) return null;

    var p = path.trim();
    if (p.isEmpty) return null;

    // already full
    if (p.startsWith("http://") || p.startsWith("https://")) return p;

    // block local paths
    if (p.contains(r":\") || p.startsWith("file:")) return null;

    // normalize slashes
    p = p.replaceAll("\\", "/");
    p = p.replaceAll(RegExp(r'/{2,}'), '/');

    // remove public prefix if exists
    if (p.startsWith("/public/")) p = p.substring("/public".length);
    if (p.startsWith("public/")) p = "/${p.substring("public".length)}";

    // ensure leading slash
    if (!p.startsWith("/")) p = "/$p";

    // ====== RULES (THE IMPORTANT PART) ======

    // 1) backend sends logos/xxx.jpg
    if (p.startsWith("/logos/")) {
      p = "/public/uploads${p}";
    }

    // 2) backend sends /restaurants/logos/xxx.jpg
    if (p.startsWith("/restaurants/logos/")) {
      p = "/uploads$p"; // => /uploads/restaurants/logos/...
    }

    // 3) backend sends /restaurants/{id}/covers/xxx.png
    if (RegExp(r'^/restaurants/\d+/covers/').hasMatch(p)) {
      p = "/uploads$p"; // => /uploads/restaurants/{id}/covers/...
    }

    return "$base$p";
  }
}
