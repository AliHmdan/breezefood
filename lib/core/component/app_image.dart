import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// ✅ Cache Manager مخصص
class AppCacheManager {
  static final instance = CacheManager(
    Config(
      'breezfoodCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 500,
    ),
  );
}

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackAsset;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      fallbackAsset ?? "assets/images/shawarma_box.png",
      width: width,
      height: height,
      fit: fit,
    );

    if (url.trim().isEmpty) {
      return borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: fallback)
          : fallback;
    }

    final image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: AppCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );

    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: image)
        : image;
  }
}

class AppImageUrl {
  static const String base = "https://breezefood.cloud";

  static bool isNetwork(String? s) {
    if (s == null) return false;
    final p = s.trim().toLowerCase();
    return p.startsWith("http://") || p.startsWith("https://");
  }

  /// يرجع null إذا path سيء (ويندوز/فايل)
  static String? toFull(String? path) {
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
    if (p.startsWith("/public/")) p = p.replaceFirst("/public/", "/");
    if (p.startsWith("public/")) p = p.replaceFirst("public/", "/");

    // ensure leading slash
    if (!p.startsWith("/")) p = "/$p";

    // ✅ critical fix: restaurants/logos => /uploads/restaurants/logos
    if (p.startsWith("/restaurants/logos/")) {
      p = "/uploads$p";
    }
    // ✅ critical fix: restaurants/logos => /uploads/restaurants/logos
    if (p.startsWith("/restaurants/logos/")) {
      p = "/uploads$p";
    }

    // ✅ NEW: restaurants/{id}/covers => /uploads/restaurants/{id}/covers
    if (RegExp(r'^/restaurants/\d+/covers/').hasMatch(p)) {
      p = "/uploads$p";
    }

    // ✅ optional: some backends send logos/... directly
    if (p.startsWith("/logos/")) {
      p = "/public/uploads$p"; // إذا عندكم هذا المسار فعلاً
      // إذا ما عندكم public/uploads احذف هالسطر
    }

    return "$base$p";
  }
}

class AppNetworkImage extends StatelessWidget {
  final String? path; // raw or full
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? radius;
  final Widget? fallback;

  const AppNetworkImage({
    super.key,
    required this.path,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final url = AppImageUrl.toFull(path);

    final fb =
        fallback ??
        Container(
          height: height,
          width: width ?? double.infinity,
          color: Colors.grey.shade800,
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant, color: Colors.white),
        );

    Widget body;
    if (url == null || url.trim().isEmpty) {
      body = fb;
    } else {
      body = Image.network(
        url,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => fb,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width ?? double.infinity,
            color: Colors.grey.shade900,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    if (radius != null) {
      return ClipRRect(borderRadius: radius!, child: body);
    }
    return body;
  }
}
