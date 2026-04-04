import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/book_store_screen.dart'; // تأكد من إنشاء هذا الملف
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
  bool isFirstTime = true; // متغير لفحص أول زيارة
  bool isLoading = true; // لحين تحميل الإعدادات

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // تحميل الإعدادات وفحص حالة الزيارة الأولى
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
      // إذا لم يجد المفتاح 'seen_books' فهذا يعني أنها أول مرة
      isFirstTime = prefs.getBool('seen_books') ?? true;
      isLoading = false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = value);
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _changeFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => fontSize = value);
    await prefs.setDouble('fontSize', value);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // المنطق: إذا كانت أول مرة نذهب للمكتبة، وإلا نذهب للرئيسية
      home: isFirstTime
          ? BookStoreScreen(
              isDarkMode: isDarkMode,
              fontSize: fontSize,
              onThemeChanged: _toggleTheme,
              onFontSizeChanged: _changeFontSize,
            )
          : HomeScreen(
              isDarkMode: isDarkMode,
              fontSize: fontSize,
              onThemeChanged: _toggleTheme,
              onFontSizeChanged: _changeFontSize,
            ),
    );
  }
}
