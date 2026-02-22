import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final double fontSize;

  const DetailScreen({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.fontSize,
  }) : super(key: key);

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
    final loadedContent = await rootBundle.loadString(widget.assetPath);

    setState(() {
      content = loadedContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: widget.fontSize,
                      height: 1.9,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
    );
  }
}
