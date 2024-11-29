import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefProvider {
  SharedPreferences? _prefs;

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPrefProvider is not initialised');
    }
    return _prefs!;
  }

  Future<void> init() async {
    if (_prefs != null) {
      throw Exception('Pref Utils is already initialised');
    }
    _prefs = await SharedPreferences.getInstance();
  }
}