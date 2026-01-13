import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breezefood/features/search/data/repo/search_repo.dart';
import 'package:breezefood/features/search/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo repo;
  Timer? _debounce;

  int? _restaurantId; // ✅ filter

  SearchCubit(this.repo) : super(const SearchState());

  // ✅ call this from Search screen initState
  void setRestaurantId(int? id) {
    _restaurantId = (id != null && id != 0) ? id : null;
  }

  int? get restaurantId => _restaurantId;

  Future<void> loadHistory() async {
    try {
      final res = await repo.history();

      final raw = res.history
          .where((h) => h.deletedAt == null)
          .map((h) => h.query.trim())
          .where((q) => q.isNotEmpty)
          .toList();

      final latestFirst = raw.reversed.toList();

      final seen = <String>{};
      final history = <String>[];
      for (final q in latestFirst) {
        final key = q.toLowerCase();
        if (seen.add(key)) history.add(q);
      }

      emit(state.copyWith(history: history));
    } catch (_) {
      // history optional
    }
  }

  void searchDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(results: [], error: null, provinceDetected: null));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      // ✅ pass restaurant filter
      final res = await repo.search(q, restaurantId: _restaurantId);

      emit(
        state.copyWith(
          loading: false,
          results: res.data,
          provinceDetected: res.provinceDetected,
        ),
      );

      await loadHistory();
    } catch (_) {
      emit(state.copyWith(loading: false, error: "حدث خطأ أثناء البحث"));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
