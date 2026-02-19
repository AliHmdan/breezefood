import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RDTabsBar extends StatefulWidget {
  const RDTabsBar({
    super.key,
    required this.categories,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<RDTabsBar> createState() => _RDTabsBarState();
}

class _RDTabsBarState extends State<RDTabsBar> {
  int _safeIndex(int i, int len) {
    if (len <= 0) return 0;
    if (i < 0) return 0;
    if (i >= len) return len - 1;
    return i;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final safe = _safeIndex(widget.activeIndex, widget.categories.length);

    return DefaultTabController(
      key: ValueKey<int>(widget.categories.length),
      length: widget.categories.length,
      initialIndex: safe,
      child: _RDTabsBarInner(
        categories: widget.categories,
        activeIndex: safe,
        onTap: widget.onTap,
      ),
    );
  }
}

class _RDTabsBarInner extends StatefulWidget {
  const _RDTabsBarInner({
    required this.categories,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<_RDTabsBarInner> createState() => _RDTabsBarInnerState();
}

class _RDTabsBarInnerState extends State<_RDTabsBarInner> {
  static const _anim = Duration(milliseconds: 220);

  @override
  void didUpdateWidget(covariant _RDTabsBarInner oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ خليه يلحق السكرول (activeIndex جاي من scrollCtl)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ctl = DefaultTabController.of(context);

      if (ctl.index != widget.activeIndex && !ctl.indexIsChanging) {
        ctl.animateTo(
          widget.activeIndex,
          duration: _anim,
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctl = DefaultTabController.of(context);
    return SizedBox(
      height: 45.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 3.5.h, // 🔥 هون سماكة الرمادي اللي بدك ياها
              color: AppColor.white.withOpacity(0.18),
            ),
          ),

          TabBar(
            tabAlignment: Directionality.of(context) == TextDirection.rtl
                ? TabAlignment.center
                : TabAlignment.center,
            controller: ctl,
            isScrollable: true,
            padding: EdgeInsets.zero,
            onTap: widget.onTap,
            labelPadding: EdgeInsets.symmetric(horizontal: 12.w),

            labelColor: AppColor.white,
            unselectedLabelColor: AppColor.white.withOpacity(0.55),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),

            indicatorSize: TabBarIndicatorSize.tab,

            // ✅ هون بس الأبيض للأكتيف
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.h, // سماكة الأبيض
                color: AppColor.white,
              ),
              insets: EdgeInsets.symmetric(horizontal: 10.w), // طول الأبيض
            ),

            tabs: widget.categories
                .map(
                  (t) => Tab(
                    child: Text(
                      t,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _UnderlineWithTrackIndicator extends Decoration {
  const _UnderlineWithTrackIndicator({
    required this.trackThickness,
    required this.indicatorThickness,
    required this.trackColor,
    required this.indicatorColor,
    required this.radius,
    this.trackInset = 0,
    this.indicatorInset = 0,
  });

  final double trackThickness;
  final double indicatorThickness;
  final double trackInset; // ✅ NEW
  final double indicatorInset; // ✅ NEW
  final Color trackColor;
  final Color indicatorColor;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlineWithTrackPainter(
      trackThickness: trackThickness,
      indicatorThickness: indicatorThickness,
      trackInset: trackInset,
      indicatorInset: indicatorInset,
      trackColor: trackColor,
      indicatorColor: indicatorColor,
      radius: radius,
    );
  }
}

class _UnderlineWithTrackPainter extends BoxPainter {
  _UnderlineWithTrackPainter({
    required this.trackThickness,
    required this.indicatorThickness,
    required this.trackInset,
    required this.indicatorInset,
    required this.trackColor,
    required this.indicatorColor,
    required this.radius,
  });

  final double trackThickness;
  final double indicatorThickness;
  final double trackInset;
  final double indicatorInset;
  final Color trackColor;
  final Color indicatorColor;
  final double radius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size;
    if (size == null) return;

    final rect = offset & size;

    // ✅ track (رمادي) - قصّ من الطرفين
    final trackLeft = rect.left + trackInset;
    final trackW = (rect.width - 2 * trackInset).clamp(0.0, rect.width);
    final yTrack = rect.bottom - trackThickness;

    final rTrack = RRect.fromRectAndRadius(
      Rect.fromLTWH(trackLeft, yTrack, trackW, trackThickness),
      Radius.circular(radius),
    );
    canvas.drawRRect(rTrack, Paint()..color = trackColor);

    // ✅ indicator (أبيض) - قصّ من الطرفين
    final indLeft = rect.left + indicatorInset;
    final indW = (rect.width - 2 * indicatorInset).clamp(0.0, rect.width);

    final yInd = rect.bottom - indicatorThickness;
    final rInd = RRect.fromRectAndRadius(
      Rect.fromLTWH(indLeft, yInd, indW, indicatorThickness),
      Radius.circular(radius),
    );
    canvas.drawRRect(rInd, Paint()..color = indicatorColor);
  }
}
