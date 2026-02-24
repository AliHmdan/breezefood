import 'package:bloc/bloc.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart' show AuthStorageHelper;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  static AppCubit get(context) => BlocProvider.of(context);
  AppCubit() : super(AppInitial());

  ///
  /// here for them light/dark
  ///

  String? them;

  void getThem() async {
    emit(changeThemFirstStep());
    them = await AuthStorageHelper.getThem() ?? 'light';
    String? ali = await AuthStorageHelper.getThem();

    print('////////////////////////////////////////////');
    print('////////////////////////////////////////////');
    print('////////////////////////////////////////////');
    print(" the them of the app is : $them");
    print(" the them of the app is : $ali");
    print('////////////////////////////////////////////');
    print('////////////////////////////////////////////');
    emit(changeThemSecondStep());
  }

  void changeThem() async {
    emit(changeThemFirstStep());
    them = them == "dark" ? 'light' : 'dark';
    await AuthStorageHelper.saveThem(them);
    emit(changeThemSecondStep());
  }

  bool isThemDark() {
    return them == 'dark' ? true : false;
  }
}
