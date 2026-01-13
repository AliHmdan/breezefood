import 'package:breezefood/features/terms/data/model/terms_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/terms/data/repo/terms_repository.dart';

part 'terms_state.dart';
part 'terms_cubit.freezed.dart';

class TermsCubit extends Cubit<TermsState> {
  final TermsRepository repo;
  TermsCubit(this.repo) : super(const TermsState.initial());

  Future<void> load() async {
    emit(const TermsState.loading());

    final res = await repo.getTerms();
    if (!res.ok) {
      emit(TermsState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = TermsResponse.fromJson(
        (res.data as Map).cast<String, dynamic>(),
      );
      emit(TermsState.loaded(parsed));
    } catch (_) {
      emit(const TermsState.error("فشل قراءة بيانات الشروط"));
    }
  }
}
