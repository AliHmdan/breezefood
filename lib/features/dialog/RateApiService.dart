import 'package:breezefood/features/dialog/Model.dart';
import 'package:dio/dio.dart';

class RateApiService {
  final Dio dio;

  RateApiService(this.dio);

  /// POST
  Future<RateModel> createRate({
    required int restaurantId,
    required int rate,
    String? comment,
  }) async {
    final response = await dio.post(
      '/rates',
      data: {
        'restaurant_id': restaurantId,
        'rate': rate,
        'comment': comment,
      },
    );

    return RateModel.fromJson(response.data['data']);
  }

  /// PUT
  Future<RateModel> updateRate({
    required int rateId,
    required int rate,
    String? comment,
  }) async {
    final response = await dio.put(
      '/rates/$rateId',
      data: {
        'rate': rate,
        'comment': comment,
      },
    );

    return RateModel.fromJson(response.data['data']);
  }

  /// DELETE
  Future<void> deleteRate(int rateId) async {
    await dio.delete('/rates/$rateId');
  }
}
