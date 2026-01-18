import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';

class ShishaHeroImage extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  /// NEW: Optional fullscreen viewer
  final bool enableViewer;

  const ShishaHeroImage({
    super.key,
    required this.tag,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 14,
    this.fit = BoxFit.cover,
    this.enableViewer = true, // Default TRUE
  });

  @override
  Widget build(BuildContext context) {
    // ================================
    //  CASE 1 — Viewer Disabled
    // ================================
    if (!enableViewer) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: height,
          width: width,
          fit: fit,
          placeholder: (_, __) => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(color: Colors.grey.shade300),
          ),
          errorWidget: (_, __, ___) => Container(
            height: height,
            width: width,
            color: Colors.black12,
            child: const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openViewer(context),
      child: Hero(
        tag: tag,
        transitionOnUserGestures: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: height,
            width: width,
            fit: fit,
            placeholder: (_, __) => Container(
              height: height,
              width: width,
              decoration: BoxDecoration(color: Colors.grey.shade300),
            ),
            errorWidget: (_, __, ___) => Container(
              height: height,
              width: width,
              color: Colors.black12,
              child: const Icon(Icons.broken_image, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.9),
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) =>
            _ImageFullScreen(tag: tag, imageUrl: imageUrl),
      ),
    );
  }
}

// ============================
// Fullscreen Hero Viewer
// ============================

class _ImageFullScreen extends StatefulWidget {
  final String tag;
  final String imageUrl;

  const _ImageFullScreen({required this.tag, required this.imageUrl});

  @override
  State<_ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<_ImageFullScreen> {
  double verticalDrag = 0;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - (verticalDrag / 300)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(opacity),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() => verticalDrag += details.delta.dy);
        },
        onVerticalDragEnd: (details) {
          if (verticalDrag > 120) {
            Navigator.pop(context);
          } else {
            setState(() => verticalDrag = 0);
          }
        },
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.tag,
                transitionOnUserGestures: true,
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(widget.imageUrl),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: 40.h,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
