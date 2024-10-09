import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const String HIGH_SCORE_KEY = 'highScore';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(HIGH_SCORE_KEY) ?? 0;
  }

  static Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(HIGH_SCORE_KEY, score);
  }
}
