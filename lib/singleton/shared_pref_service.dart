import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  late final SharedPreferences _instance;

  Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  SharedPreferences get instance => _instance;

  Future<void> saveString(String key, String value) async {
    await _instance.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _instance.getString(key);
  }
}
