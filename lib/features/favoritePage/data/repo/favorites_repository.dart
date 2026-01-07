import 'package:breezefood/features/favoritePage/data/api/favorites_api_service.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;

class FavoritesRepository {
  final FavoritesApiService api;
  FavoritesRepository(this.api);

  Future<AppResponse> getFavorites() async {
    try {
      final res = await api.getFavorites();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل المفضلة");
    }
  }

Future<AppResponse> toggleFavorite(int menuItemId) async {
  try {
    final res = await api.toggleFavorite(<String, dynamic>{
      "menu_item_id": menuItemId,
    });
    return AppResponse.ok(data: res.data);
  } on DioException catch (e) {
    return AppResponseHandler.handleError(e);
  } catch (_) {
    return AppResponse.fail(message: "فشل تحديث المفضلة");
  }
}

}
