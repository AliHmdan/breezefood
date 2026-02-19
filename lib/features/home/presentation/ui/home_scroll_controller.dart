import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScrollController {
  HomeScrollController({this.debugEnabled = kDebugMode});

  bool debugEnabled;

  final controller = ScrollController();
  final activeIndex = ValueNotifier<int>(0);

  final sectionKeys = <GlobalKey>[];

  /// ✅ key للـ sticky tabs الحقيقي (حطّو على Container تبع الهيدر)
  final GlobalKey tabsKey = GlobalKey();

  bool isProgrammatic = false;
  int _dbgTick = 0;

  void init() {
    controller.addListener(_onScroll);
    controller.addListener(_debug);
  }

  void dispose() {
    controller.removeListener(_onScroll);
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

  double _probeY() {
    final ctx = tabsKey.currentContext;
    final ro = ctx?.findRenderObject();

    if (ro is RenderBox) {
      final dy = ro.localToGlobal(Offset.zero).dy;
      return dy + ro.size.height; // ✅ تحت التابات الحقيقي
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

    // آخر الصفحة = آخر تاب
    const endEps = 2.0;
    final pos = controller.position;
    if (pos.pixels >= (pos.maxScrollExtent - endEps)) {
      final last = sectionKeys.length - 1;
      if (last >= 0 && activeIndex.value != last) activeIndex.value = last;
      return;
    }

    final probe = _probeY() + 6.0;
    int newIndex = activeIndex.value;

    for (int i = 0; i < sectionKeys.length; i++) {
      final ctx = sectionKeys[i].currentContext;
      if (ctx == null) continue;

      final ro = ctx.findRenderObject();
      if (ro is! RenderBox) continue;

      final dy = ro.localToGlobal(Offset.zero).dy;
      if (dy <= probe) newIndex = i;
    }

    if (newIndex != activeIndex.value) activeIndex.value = newIndex;
  }

  Future<void> scrollToSection(int index) async {
    if (!controller.hasClients) return;
    if (index < 0 || index >= sectionKeys.length) return;

    final ctx = sectionKeys[index].currentContext;
    if (ctx == null) return;

    isProgrammatic = true;
    try {
      if (activeIndex.value != index) activeIndex.value = index;

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
