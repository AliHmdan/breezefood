part of 'app_cubit.dart';

sealed class AppState extends Equatable {
  const AppState();
}

final class AppInitial extends AppState {
  @override
  List<Object> get props => [];
}

class changeThemFirstStep extends AppState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class changeThemSecondStep extends AppState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
