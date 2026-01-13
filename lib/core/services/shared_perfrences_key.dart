import 'package:hive/hive.dart';

class AuthStorageHelper {
  static const String _authBoxName = 'auth_box';
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _isGuestKey = 'is_guest';
  static const String _latKey = 'user_lat';
  static const String _lonKey = 'user_lon';
  static const String _prefsBoxName = 'app_prefs_box';
  static const String _zoomHintKey = 'verify_zoom_hint_dismissed_v1';
  static const String acceptConditionKey = 'accept_condition';
  static Future<void> setGuestMode(bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_isGuestKey, value);
  }

  static Future<bool> isGuest() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_isGuestKey, defaultValue: false);
  }

  static Future<void> clearGuestMode() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_isGuestKey);
  }

 

  static String? getUserRoleSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_roleKey) as String?;
    } catch (e) {
      print('⚠️ Hive not ready for getUserRoleSync: $e');
      return null;
    }
  }

  // -------------------------------------------------------------
  // 🔹 TOKEN MANAGEMENT (Generic)
  // -------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_tokenKey, token);
    print('✅ Token saved successfully');
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_tokenKey);
  }

  static String? getTokenSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_tokenKey);
    } catch (e) {
      print('⚠️ Error getting token synchronously: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_tokenKey);
    print('🗑️ Token removed successfully');
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // -------------------------------------------------------------
  // 🔹 ROLE MANAGEMENT
  // -------------------------------------------------------------
  static Future<void> saveUserRole(String role) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_roleKey, role);
  }

  static Future<String?> getUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_roleKey);
  }

  static Future<void> removeUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_roleKey);
  }





  // -------------------------------------------------------------
  // 🔹 ZOOM HINT FLAG (Existing)
  // -------------------------------------------------------------
  static Future<bool> isZoomHintDismissed() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_zoomHintKey, defaultValue: false) as bool;
  }

  static Future<void> dismissZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_zoomHintKey, true);
  }

  static Future<void> resetZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_zoomHintKey);
  }

  // -------------------------------------------------------------
  // 🔹 GENERIC FLAGS (Existing)
  // -------------------------------------------------------------
  static Future<void> setFlag(String key, bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(key, value);
  }

  static Future<bool?> getFlag(String key) async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(key) as bool?;
  }

  static Future<void> setAcceptCondition(bool accepted) async =>
      setFlag(acceptConditionKey, accepted);

  static Future<bool?> getAcceptCondition() async =>
      getFlag(acceptConditionKey);


//MAPS STUFF 

       static Future<void> saveUserLocation({
    required String lat,
    required String lon,
  }) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_latKey, lat);
    await box.put(_lonKey, lon);
    print('✅ Location saved: ($lat, $lon)');
  }

  static Future<Map<String, String?> > getUserLocation() async {
    final box = await Hive.openBox(_authBoxName);
    return {
      "lat": box.get(_latKey) as String?,
      "lon": box.get(_lonKey) as String?,
    };
  }

  static String? getUserLatSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_latKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static String? getUserLonSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_lonKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeUserLocation() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_latKey);
    await box.delete(_lonKey);
  }

}
