import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefInstance {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_sharedPreferences == null) {
      throw Exception("Shared preferences not initialized");
    }
    return _sharedPreferences!;
  }
}
