part of 'notification_cubit.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;
  const factory NotificationState.loading() = _Loading;
  const factory NotificationState.error(String message) = _Error;
  const factory NotificationState.loaded({
    @Default([]) List<AppNotification> items,
    @Default(false) bool isMarkingAll,
  }) = _Loaded;
}
