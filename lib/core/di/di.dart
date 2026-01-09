import 'package:breezefood/core/network/dio_factory.dart';
import 'package:breezefood/features/favoritePage/data/api/favorites_api_service.dart';
import 'package:breezefood/features/favoritePage/data/repo/favorites_repository.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/helpCenter/data/api/help_center_api_service.dart';
import 'package:breezefood/features/helpCenter/data/repo/help_center_repo.dart';
import 'package:breezefood/features/helpCenter/presentation/cubit/help_center_cubit.dart';
import 'package:breezefood/features/home/data/api/home_api_service.dart';
import 'package:breezefood/features/home/data/repo/home_repository.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/orders/data/api/cart_api_service.dart';
import 'package:breezefood/features/orders/data/api/orders_api_service.dart';
import 'package:breezefood/features/orders/data/repo/cart_repository.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/profile/data/api/address_api_service.dart';
import 'package:breezefood/features/profile/data/api/profile_api_service.dart';
import 'package:breezefood/features/profile/data/repo/profile_repository.dart'
    show ProfileRepository;
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/search/data/api/search_api_service.dart';
import 'package:breezefood/features/search/data/repo/search_repo.dart';
import 'package:breezefood/features/search/presentation/cubit/search_cubit.dart';
import 'package:breezefood/features/stores/data/api/most_popular_api_service.dart';
import 'package:breezefood/features/stores/data/api/restaurant_details_api_service.dart';
import 'package:breezefood/features/stores/data/api/stores_api_service.dart';
import 'package:breezefood/features/stores/data/api/super_market_api_service.dart';
import 'package:breezefood/features/stores/data/repo/most_popular_repo.dart';
import 'package:breezefood/features/stores/data/repo/restaurant_details_repo.dart';
import 'package:breezefood/features/stores/data/repo/stores_repo.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/markets_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/most_popular_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/stores_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/super_markets_list_cubit.dart';
import 'package:breezefood/features/terms/data/api/terms_api_service.dart';
import 'package:breezefood/features/terms/data/repo/terms_repository.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:breezefood/features/auth/data/api/auth_api_service.dart';
import 'package:breezefood/features/auth/data/repo/auth_repository.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDi() async {
  await Hive.initFlutter();
  await Hive.openBox("settings");
  await Hive.openBox<String>("token");

  // 1) Dio
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());
  }

  // ...
  final dio = DioFactory.getDio();
  getIt.registerLazySingleton<AuthApiService>(() => AuthApiService(dio));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthApiService>()),
  );
  getIt.registerFactory<AuthFlowCubit>(
    () => AuthFlowCubit(getIt<AuthRepository>()),
  );

  // Api
  getIt.registerLazySingleton(() => HomeApiService(getIt()));

  // Repo
  getIt.registerLazySingleton(() => HomeRepository(getIt()));
  // في di.dart
  getIt.registerLazySingleton<StoresApiService>(
    () => StoresApiService(getIt<Dio>()),
  );
  getIt.registerFactory<MostPopularApiService>(
    () => MostPopularApiService(getIt<Dio>()),
  );
  getIt.registerFactory<MostPopularRepository>(
    () => MostPopularRepository(getIt<MostPopularApiService>()),
  );
  getIt.registerFactory<MostPopularCubit>(
    () => MostPopularCubit(getIt<MostPopularRepository>()),
  );

  getIt.registerLazySingleton<StoresRepository>(
    () => StoresRepository(getIt<StoresApiService>()),
  );
  getIt.registerLazySingleton<FavoritesApiService>(
    () => FavoritesApiService(getIt<Dio>()),
  );
  getIt.registerFactory(() => SuperMarketsListCubit(getIt<SuperMarketRepo>()));
  getIt.registerLazySingleton<SuperMarketApiService>(
    () => SuperMarketApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton(
    () => SuperMarketRepo(getIt<SuperMarketApiService>()),
  );
  getIt.registerFactory(() => MarketsCubit(getIt<SuperMarketRepo>()));

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(getIt<FavoritesApiService>()),
  );
  getIt.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(getIt<FavoritesRepository>()),
  );

  getIt.registerFactory<StoresCubit>(
    () => StoresCubit(getIt<StoresRepository>()),
  );
  getIt.registerLazySingleton<RestaurantDetailsApiService>(
    () => RestaurantDetailsApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<RestaurantDetailsRepository>(
    () => RestaurantDetailsRepository(getIt<RestaurantDetailsApiService>()),
  );

  getIt.registerFactory<RestaurantDetailsCubit>(
    () => RestaurantDetailsCubit(getIt<RestaurantDetailsRepository>()),
  );

  getIt.registerLazySingleton<HelpCenterApiService>(
    () => HelpCenterApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton(
    () => HelpCenterRepo(getIt<HelpCenterApiService>()),
  );
  getIt.registerFactory(() => HelpCenterCubit(getIt<HelpCenterRepo>()));
  getIt.registerLazySingleton<TermsApiService>(
    () => TermsApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<TermsRepository>(
    () => TermsRepository(getIt<TermsApiService>()),
  );

  getIt.registerFactory<TermsCubit>(() => TermsCubit(getIt<TermsRepository>()));

  // Cubit
  getIt.registerFactory(() => HomeCubit(getIt()));

  // OrdersApiService
  getIt.registerLazySingleton<OrdersApiService>(
    () => OrdersApiService(getIt<Dio>()),
  );

 
  // OrderFlowCubit
  getIt.registerFactory<OrderFlowCubit>(
    () => OrderFlowCubit(getIt<OrdersRepository>()),
  );

  getIt.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AddressApiService>(
    () => AddressApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      getIt<ProfileApiService>(),
      getIt<AddressApiService>(),
    ),
  );

  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<CartApiService>(
    () => CartApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(getIt<CartApiService>()),
  );
  getIt.registerFactory<CartCubit>(() => CartCubit(getIt<CartRepository>()));

  // repo
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepository(getIt<OrdersApiService>()),
  );
getIt.registerLazySingleton<SearchApiService>(() => SearchApiService(getIt<Dio>()));
getIt.registerLazySingleton(() => SearchRepo(getIt<SearchApiService>()));
getIt.registerFactory(() => SearchCubit(getIt<SearchRepo>()));

  // cubit
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(getIt<OrdersRepository>()),
  );
}
