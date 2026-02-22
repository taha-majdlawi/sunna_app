import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final double fontSize;

  DetailScreen({
    required this.assetPath,
    required this.title,
    required this.fontSize,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String content = "";

  @override
  void initState() {
    super.initState();
    loadText();
  }

  Future<void> loadText() async {
    final loadedContent =
        await rootBundle.loadString(widget.assetPath);
    setState(() {
      content = loadedContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orange[300],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFDE7),
              Color(0xFFFFF3CC),
              Color(0xFFFFE0A3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  height: 1.8,
                  color: Colors.brown[900],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
      ),
    );
  }
}