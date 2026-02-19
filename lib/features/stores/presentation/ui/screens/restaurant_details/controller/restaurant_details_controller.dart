import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestaurantDetailsScrollController {
  RestaurantDetailsScrollController({
    this.debugEnabled = kDebugMode,
    double? stickyExtent,
  }) : stickyHeaderExtent = stickyExtent ?? 130.h;

  bool debugEnabled;

  final nestedKey = GlobalKey<NestedScrollViewState>();
  final outer = ScrollController();
  ScrollController? inner;

  double stickyHeaderExtent;

  double titleTopPadding = 12.0;

  final activeIndex = ValueNotifier<int>(0);

  final categoryKeys = <GlobalKey>[];
  final categoryOffsets = <double>[]; 

  bool isProgrammatic = false;
  int _dbgTick = 0;

  void init() {
    outer.addListener(_onAnyScroll);
    outer.addListener(_debugScroll);
  }

  void dispose() {
    inner?.removeListener(_onAnyScroll);
    outer.removeListener(_onAnyScroll);
    outer.removeListener(_debugScroll);
    outer.dispose();
    activeIndex.dispose();
  }

  /// إذا تغير ارتفاع الستكي حسب التصميم
  void setStickyExtent(double v) {
    if ((stickyHeaderExtent - v).abs() < 0.1) return;
    stickyHeaderExtent = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recalcOffsets();
      _onAnyScroll();
    });
  }

  void attachInner() {
    final st = nestedKey.currentState;
    if (st == null) return;

    final next = st.innerController;
    if (inner == next) return;

    inner?.removeListener(_onAnyScroll);
    inner = next;
    inner!.addListener(_onAnyScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      recalcOffsets();
      _onAnyScroll();
    });
  }

  void setCategoryKeys(int count) {
    if (categoryKeys.length == count) return;

    categoryKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));

    categoryOffsets
      ..clear()
      ..addAll(List.filled(count, double.infinity));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attachInner();
      recalcOffsets();
      _onAnyScroll();
    });
  }

  void recalcOffsets() {
    final innerCtl = inner;
    if (innerCtl == null || !innerCtl.hasClients) return;

    bool anyInfinity = false;

    for (int i = 0; i < categoryKeys.length; i++) {
      categoryOffsets[i] = double.infinity;

      final ctx = categoryKeys[i].currentContext;
      final ro = ctx?.findRenderObject();
      if (ro == null) {
        anyInfinity = true;
        continue;
      }

      final viewport = RenderAbstractViewport.of(ro);

      categoryOffsets[i] = viewport.getOffsetToReveal(ro, 0.0).offset;
    }

    _debugPrintOffsets();

    if (anyInfinity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 60), () {
          if (inner?.hasClients == true) recalcOffsets();
        });
      });
    }
  }

  void _onAnyScroll() {
    if (isProgrammatic) return;
    if (categoryKeys.isEmpty) return;

    final innerCtl = inner;
    if (innerCtl == null || !innerCtl.hasClients) return;

    final pos = innerCtl.position;

    // ✅ آخر الصفحة -> فعّل آخر tab
    const double endEps = 2.0;
    if (pos.pixels >= (pos.maxScrollExtent - endEps)) {
      final last = categoryKeys.length - 1;
      if (last >= 0 && activeIndex.value != last) {
        activeIndex.value = last;
      }
      return;
    }

    if (categoryOffsets.isEmpty || categoryOffsets.any((x) => x.isInfinite)) {
      recalcOffsets();
    }

    final double probe = innerCtl.offset + stickyHeaderExtent + 34.h;

    int newIndex = 0;
    for (int i = 0; i < categoryOffsets.length; i++) {
      final off = categoryOffsets[i];
      if (off.isInfinite) continue;

      if (off <= probe) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != activeIndex.value) {
      activeIndex.value = newIndex;
    }
  }

  Future<void> scrollToCategory(int index) async {
    attachInner();
    final innerCtl = inner;
    if (innerCtl == null || !innerCtl.hasClients) return;
    if (index < 0 || index >= categoryKeys.length) return;

    if (activeIndex.value != index) {
      activeIndex.value = index;
    }

    isProgrammatic = true;

    try {
      if (outer.hasClients) {
        final maxOuter = outer.position.maxScrollExtent;
        if ((maxOuter - outer.offset) > 0.5) {
          await outer.animateTo(
            maxOuter,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
          await Future.delayed(const Duration(milliseconds: 16));
        }
      }

      recalcOffsets();
      if (index >= categoryOffsets.length) return;

      final max = innerCtl.position.maxScrollExtent;
      final bool isLast = index == categoryKeys.length - 1;

      final raw = categoryOffsets[index] - stickyHeaderExtent - titleTopPadding;

      final target = isLast ? max : raw.clamp(0.0, max);

      await innerCtl.animateTo(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 120), () {
        isProgrammatic = false;
      });
    }
  }

  void _debugScroll() {
    if (!debugEnabled) return;
    if ((_dbgTick++ % 12) != 0) return;

    final o = outer.hasClients ? outer.offset : -1;
    final i = inner?.hasClients == true ? inner!.offset : -1;
    debugPrint(
      "🧭 [RD] outer=$o | inner=$i | sticky=$stickyHeaderExtent | active=${activeIndex.value}",
    );
  }

  void _debugPrintOffsets() {
    if (!debugEnabled) return;
    debugPrint("📌 [RD] offsets=${categoryOffsets.length}");
    for (int i = 0; i < categoryOffsets.length; i++) {
      debugPrint("   [$i] ${categoryOffsets[i]}");
    }
  }
}
