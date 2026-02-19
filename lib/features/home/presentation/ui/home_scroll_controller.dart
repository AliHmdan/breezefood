import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HomeScrollController {
  HomeScrollController({this.debugEnabled = kDebugMode});
  int? _raf;

  bool debugEnabled;

  final controller = ScrollController();
  final activeIndex = ValueNotifier<int>(0);

  final sectionKeys = <GlobalKey>[];

  /// ✅ key للـ sticky tabs الحقيقي
  final GlobalKey tabsKey = GlobalKey();

  bool isProgrammatic = false;
  int _dbgTick = 0;

  // ==============================
  // 🔧 PROBE CONFIG (عدّل هون براحتك)
  // ==============================

  /// كم بيكسل من فوق نعتبر حالنا "أول الصفحة"
  static const double topEdgeProbe = 4.0;

  /// كم بيكسل قبل آخر الصفحة نعتبر حالنا "آخر الصفحة"
  static const double bottomEdgeProbe = 4.0;

  /// مسافة إضافية تحت التابات لتفعيل السيكشن قبل عنوانه
  static const double sectionActivationOffset = 8.0;

  // ==============================

  void init() {
    controller.addListener(_onScrollThrottled);
    controller.addListener(_debug);
  }

  void _onScrollThrottled() {
    if (isProgrammatic) return;
    if (_raf != null) return;

    _raf = SchedulerBinding.instance.scheduleFrameCallback((_) {
      _raf = null;
      _onScroll();
    });
  }

  void dispose() {
    controller.removeListener(_onScrollThrottled);
    controller.removeListener(_debug);
    controller.dispose();
    activeIndex.dispose();
  }

  void setKeysCount(int count) {
    if (sectionKeys.length == count) return;

    sectionKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  /// 🔎 مكان القياس الحقيقي تحت التابات
  double _tabsBottomY() {
    final ctx = tabsKey.currentContext;
    final ro = ctx?.findRenderObject();

    if (ro is RenderBox) {
      final dy = ro.localToGlobal(Offset.zero).dy;
      return dy + ro.size.height;
    }

    // fallback إذا ما كان جاهز
    final top = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).padding.top;

    return top + 85.0;
  }

  void _onScroll() {
    if (isProgrammatic) return;
    if (!controller.hasClients) return;
    if (sectionKeys.isEmpty) return;

    final pos = controller.position;

    // ==============================
    // 🔝 أول الصفحة
    // ==============================
    if (pos.pixels <= pos.minScrollExtent + topEdgeProbe) {
      if (activeIndex.value != 0) {
        activeIndex.value = 0;
      }
      return;
    }

    // ==============================
    // 🔚 آخر الصفحة
    // ==============================
    if (pos.pixels >= pos.maxScrollExtent - bottomEdgeProbe) {
      final last = sectionKeys.length - 1;
      if (last >= 0 && activeIndex.value != last) {
        activeIndex.value = last;
      }
      return;
    }

    // ==============================
    // 🎯 Section Activation Probe
    // ==============================

    final probeY = _tabsBottomY() + sectionActivationOffset;

    int newIndex = 0;

    for (int i = 0; i < sectionKeys.length; i++) {
      final ctx = sectionKeys[i].currentContext;
      if (ctx == null) continue;

      final ro = ctx.findRenderObject();
      if (ro is! RenderBox) continue;

      final dy = ro.localToGlobal(Offset.zero).dy;
      if (dy <= probeY) newIndex = i;
    }

    if (newIndex != activeIndex.value) {
      activeIndex.value = newIndex;
    }
    if (controller.position.isScrollingNotifier.value == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  Future<void> scrollToSection(int index) async {
    if (!controller.hasClients) return;
    if (index < 0 || index >= sectionKeys.length) return;

    final ctx = sectionKeys[index].currentContext;
    if (ctx == null) return;

    isProgrammatic = true;
    try {
      if (activeIndex.value != index) {
        activeIndex.value = index;
      }

      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );

      await Future.delayed(const Duration(milliseconds: 16));
      if (!controller.hasClients) return;

      final target = (controller.offset - 8.0).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );

      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 120), () {
        isProgrammatic = false;
      });
    }
  }

  void _debug() {
    if (!debugEnabled) return;
    if ((_dbgTick++ % 14) != 0) return;

    final o = controller.hasClients ? controller.offset : -1;
    debugPrint("🏠 [HOME] scroll=$o | active=${activeIndex.value}");
  }
}
