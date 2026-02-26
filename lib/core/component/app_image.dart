import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// =======================================================
/// ✅ Custom Cache Manager
/// =======================================================
class AppCacheManager {
  static final CacheManager instance = CacheManager(
    Config(
      'breezfoodCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 3000,
    ),
  );
}

/// =======================================================
/// ✅ Helper: Convert Backend Path → Full URL
/// =======================================================
class AppImageUrl {
  static const String base = "https://breezefood.cloud";

  static String? toFull(String? path) {
    if (path == null) return null;

    var p = path.trim();
    if (p.isEmpty) return null;

    // already full url
    if (p.startsWith("http://") || p.startsWith("https://")) {
      return p;
    }

    // block local paths
    if (p.contains(r":\") || p.startsWith("file:")) return null;

    // normalize slashes
    p = p.replaceAll("\\", "/");
    p = p.replaceAll(RegExp(r'/{2,}'), '/');

    // remove public prefix
    if (p.startsWith("/public/")) {
      p = p.replaceFirst("/public/", "/");
    }
    if (p.startsWith("public/")) {
      p = p.replaceFirst("public/", "/");
    }

    // ensure leading slash
    if (!p.startsWith("/")) {
      p = "/$p";
    }

    // restaurants logos fix
    if (p.startsWith("/restaurants/logos/")) {
      p = "/uploads$p";
    }

    // restaurants covers fix
    if (RegExp(r'^/restaurants/\d+/covers/').hasMatch(p)) {
      p = "/uploads$p";
    }

    return "$base$p";
  }
}

/// =======================================================
/// ✅ Generic Network Image (No Flicker Version)
/// =======================================================
class AppNetworkImage extends StatelessWidget {
  final String? path;
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

          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.grey.shade800,
          ),
          child: const Icon(Icons.restaurant, color: Colors.white),
        );

    if (url == null || url.trim().isEmpty) {
      return fb;
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: AppCacheManager.instance,
      height: height,
      width: width ?? double.infinity,
      fit: fit,

      /// 🚀 Prevent flicker
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: true,

      /// 🚀 Improve memory caching
      memCacheWidth: 1200,
      memCacheHeight: 1200,

      /// ❌ No placeholder to avoid flash
      errorWidget: (_, __, ___) => fb,
    );

    if (radius != null) {
      return ClipRRect(borderRadius: radius!, child: image);
    }

    return image;
  }
}

/// =======================================================
/// ✅ Simple AppImage (Direct URL Usage)
/// =======================================================
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
      fallbackAsset ?? "assets/images/meal_breeze.jpeg",
      width: width,
      height: height,
      fit: fit,
    );

    if (url.trim().isEmpty) {
      return borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: fallback)
          : fallback;
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: AppCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      memCacheWidth: 1200,
      memCacheHeight: 1200,
      errorWidget: (_, __, ___) => fallback,
    );

    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: image)
        : image;
  }
}
