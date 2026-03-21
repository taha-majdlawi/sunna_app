import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyLastRead = 'last_read_episode';

  // حفظ رقم الحلقة
  static Future<void> saveLastRead(String episodeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRead, episodeNumber);
  }

  // استرجاع رقم الحلقة
  static Future<String?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastRead);
  }
}