part of 'app_cubit.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => const [];
}

final class AppInitial extends AppState {
  @override
  List<Object> get props => [];
}

class changeThemFirstStep extends AppState {
  const changeThemFirstStep();
}

class changeThemSecondStep extends AppState {
  const changeThemSecondStep();
}
