import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager {
  // حفظ رقم آخر حلقة تم فتحها
  static Future<void> saveLastRead(String episodeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_episode', episodeNumber);
  }

  // استرجاع رقم آخر حلقة
  static Future<String?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_read_episode');
  }
}