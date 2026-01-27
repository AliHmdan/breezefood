import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:breezefood/features/notifications/data/models/notifications_models.dart';
import 'package:breezefood/features/notifications/data/repo/notifications_repo.dart';

part 'notification_state.dart';
part 'notification_cubit.freezed.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repo;

  NotificationCubit(this.repo) : super(const NotificationState.initial());
  Future<void> openScreen() async {
    emit(const NotificationState.loading());

    final res = await repo.getNotifications();
    if (!res.ok) {
      emit(NotificationState.error(res.message ?? "خطأ"));
      return;
    }

    final raw = res.data;
    final list = (raw is Map) ? raw["data"] : null;

    final items = (list is List)
        ? list
              .whereType<Map>()
              .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <AppNotification>[];

    // ✅ اعرضهم مباشرة
    emit(NotificationState.loaded(items: items));

    // ✅ إذا في غير مقروء -> اعمل read-all تلقائي
    final hasUnread = items.any((n) => n.readAt == null);
    if (!hasUnread) return;

    final readRes = await repo.readAll();
    if (!readRes.ok) return; // ما توقف الصفحة لو فشل

    // ✅ (اختياري) حدّث القائمة بعد القراءة
    final res2 = await repo.getNotifications();
    if (!res2.ok) return;

    final raw2 = res2.data;
    final list2 = (raw2 is Map) ? raw2["data"] : null;

    final items2 = (list2 is List)
        ? list2
              .whereType<Map>()
              .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <AppNotification>[];

    emit(NotificationState.loaded(items: items2));
  }

  Future<void> load() async {
    emit(const NotificationState.loading());

    final res = await repo.getNotifications();
    if (!res.ok) {
      emit(NotificationState.error(res.message ?? "خطأ"));
      return;
    }

    // ✅ هون حسب أسلوب ريبوّك الجديد: res.data هو raw json (Map)
    final raw = res.data;
    final list = (raw is Map) ? raw["data"] : null;

    final items = (list is List)
        ? list
              .whereType<Map>()
              .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <AppNotification>[];

    emit(NotificationState.loaded(items: items));
  }

  Future<void> markAllRead() async {
    final current = state;
    if (current is! _Loaded) return;

    emit(current.copyWith(isMarkingAll: true));

    final res = await repo.readAll();
    if (!res.ok) {
      emit(NotificationState.error(res.message ?? "خطأ"));
      emit(current.copyWith(isMarkingAll: false));
      return;
    }

    await load();
  }
}
