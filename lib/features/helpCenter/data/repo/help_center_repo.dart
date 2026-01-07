import 'package:breezefood/features/helpCenter/data/api/help_center_api_service.dart';
import 'package:breezefood/features/helpCenter/data/model/help_center_models.dart';

class HelpCenterRepo {
  final HelpCenterApiService api;
  HelpCenterRepo(this.api);

  Future<HelpThreadResponse> getThread() async {
    final res = await api.getThread();
    return HelpThreadResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<HelpThreadResponse> sendMessage(String message) async {
    final res = await api.sendMessage({"message": message});
    return HelpThreadResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
