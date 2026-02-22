import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
      theme: isDarkMode
          ? ThemeData.dark()
          : ThemeData(
              scaffoldBackgroundColor: Colors.transparent,
              fontFamily: "Arial",
            ),
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