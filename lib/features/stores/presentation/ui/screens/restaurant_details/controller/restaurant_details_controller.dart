import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestaurantDetailsScrollController {
  RestaurantDetailsScrollController({this.debugEnabled = kDebugMode});

  bool debugEnabled;

  final nestedKey = GlobalKey<NestedScrollViewState>();
  final outer = ScrollController();
  ScrollController? inner;

  final activeIndex = ValueNotifier<int>(0);

  final categoryKeys = <GlobalKey>[];
  final categoryOffsets = <double>[]; // للـ scrollToCategory فقط

  bool isProgrammatic = false;
  int _dbgTick = 0;

  double get _stickyHeight => 140.h;

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
    if (innerCtl == null) return;

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
      if (viewport == null) {
        anyInfinity = true;
        continue;
      }

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

    // ✅ آخر الصفحة -> فعّل آخر tab
    const double endEps = 2.0;
    final pos = innerCtl.position;
    if (pos.pixels >= (pos.maxScrollExtent - endEps)) {
      final last = categoryKeys.length - 1;
      if (last >= 0 && activeIndex.value != last) {
        activeIndex.value = last;
      }
      return;
    }

    // ✅ إذا offsets لسا ما جاهزة
    if (categoryOffsets.isEmpty || categoryOffsets.any((x) => x.isInfinite)) {
      recalcOffsets();
    }
  

    final double probe = innerCtl.offset + _stickyHeight + 38.0.h; // 16 + 10

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
    if (innerCtl == null) return;
    if (!innerCtl.hasClients) return;
    if (index < 0 || index >= categoryKeys.length) return;

    // ✅ 1) بدّل الاكتف اندكس فوراً لحظة التاب
    if (activeIndex.value != index) {
      activeIndex.value = index;
    }

    isProgrammatic = true;

    try {
      if (index == 0) {
        await innerCtl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );

        if (outer.hasClients) {
          await outer.animateTo(
            0.0,
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
          );
        }
        return;
      }

      if (outer.hasClients) {
        final maxOuter = outer.position.maxScrollExtent;
        if ((maxOuter - outer.offset) > 0.5) {
          await outer.animateTo(
            maxOuter,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
          await Future.delayed(const Duration(milliseconds: 16));
        }
      }

      recalcOffsets();
      if (index >= categoryOffsets.length) return;

      const double titleTopPadding = 12.0;

      final max = innerCtl.position.maxScrollExtent;
      final bool isLast = index == categoryKeys.length - 1;

      final target = isLast
          ? max
          : (categoryOffsets[index] - _stickyHeight - titleTopPadding).clamp(
              0.0,
              max,
            );

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
    debugPrint("🧭 [RD] outer=$o | inner=$i | active=${activeIndex.value}");
  }

  void _debugPrintOffsets() {
    if (!debugEnabled) return;
    debugPrint("📌 [RD] offsets=${categoryOffsets.length}");
    for (int i = 0; i < categoryOffsets.length; i++) {
      debugPrint("   [$i] ${categoryOffsets[i]}");
    }
  }
}
