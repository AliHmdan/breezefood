import 'package:breezefood/features/helpCenter/data/model/help_center_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breezefood/features/helpCenter/data/repo/help_center_repo.dart';

class HelpCenterState {
  final bool loading;
  final String? error;
  final TicketModel? ticket;
  final bool sending;

  const HelpCenterState({
    required this.loading,
    required this.sending,
    this.error,
    this.ticket,
  });

  factory HelpCenterState.initial() => const HelpCenterState(
        loading: true,
        sending: false,
      );

  HelpCenterState copyWith({
    bool? loading,
    bool? sending,
    String? error,
    TicketModel? ticket,
  }) {
    return HelpCenterState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      error: error,
      ticket: ticket ?? this.ticket,
    );
  }
}

class HelpCenterCubit extends Cubit<HelpCenterState> {
  final HelpCenterRepo repo;
  HelpCenterCubit(this.repo) : super(HelpCenterState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final res = await repo.getThread();
      emit(state.copyWith(loading: false, ticket: res.ticket));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    emit(state.copyWith(sending: true, error: null));
    try {
      final res = await repo.sendMessage(msg);
      emit(state.copyWith(sending: false, ticket: res.ticket));
    } catch (e) {
      emit(state.copyWith(sending: false, error: e.toString()));
    }
  }
}
