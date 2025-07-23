import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _preferences;
  // Private constructor to prevent instantiation
  SharedPrefsService._();

  /// Initialize SharedPreferences (Call this in `main.dart` before runApp)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get the instance of SharedPreferences
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception(
        "SharedPreferences not initialized. Call SharedPrefsService.init() first.",
      );
    }
    return _preferences!;
  }
}
