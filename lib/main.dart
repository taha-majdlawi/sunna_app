import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/themes.dart'; // استدعاء الملف الجديد

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
  double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(), // <-- هذه الدالة موجودة في themes.dart
      darkTheme: darkTheme(), // <-- هذه كذلك
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: isDarkMode,
        fontSize: fontSize,
        onThemeChanged: (value) {
          setState(() {
            isDarkMode = value;
          });
        },
        onFontSizeChanged: (value) {
          setState(() {
            fontSize = value;
          });
        },
      ),
    );
  }
}
