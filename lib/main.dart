import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // تأكد من إضافة المكتبة في pubspec.yaml
import 'screens/home_screen.dart';
import 'utils/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // تحميل الإعدادات المحفوظة فور تشغيل التطبيق
  }

  // دالة لتحميل البيانات من ذاكرة الجهاز
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  // دالة لحفظ وتغيير الوضع الليلي
  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

  // دالة لحفظ وتغيير حجم الخط
  Future<void> _changeFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = value;
    });
    await prefs.setDouble('fontSize', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: isDarkMode,
        fontSize: fontSize,
        onThemeChanged: _toggleTheme, // نمرر دالة الحفظ الجديدة
        onFontSizeChanged: _changeFontSize, // نمرر دالة الحفظ الجديدة
      ),
    );
  }
}