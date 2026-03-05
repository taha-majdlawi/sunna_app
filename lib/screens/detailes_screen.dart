import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 1. Import the YouTube package
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final double fontSize;
  final String youtubeUrl; // 2. Added YouTube URL to the constructor

  const DetailScreen({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.fontSize,
    required this.youtubeUrl, // Pass this from your list screen
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String content = "";
  bool isFavorite = false;
  pw.Font? arabicFont;
  
  // 3. Define the Controller
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    loadText();
    loadArabicFont();
    _checkFavoriteStatus();

    // 4. Initialize YouTube Controller
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
      ),
    );
  }

  // 5. Important: Dispose the controller to save memory
  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorite_episodes') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.assetPath);
    });
  }

  Future<void> loadText() async {
    final loadedContent = await rootBundle.loadString(widget.assetPath);
    setState(() {
      content = loadedContent;
    });
  }

  Future<void> loadArabicFont() async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    setState(() {
      arabicFont = pw.Font.ttf(fontData);
    });
  }

  void copyText() {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نسخ النص")));
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_episodes') ?? [];
    setState(() {
      if (isFavorite) {
        favorites.remove(widget.assetPath);
        isFavorite = false;
      } else {
        favorites.add(widget.assetPath);
        isFavorite = true;
      }
    });
    await prefs.setStringList('favorite_episodes', favorites);
  }

  Future<void> sharePdf() async {
    if (content.isEmpty) return;
    try {
      final pdf = pw.Document();
      final arabicFontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      final arabicFont = pw.Font.ttf(arabicFontData);
      final paragraphs = content.split('\n').where((p) => p.trim().isNotEmpty).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          textDirection: pw.TextDirection.rtl,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text("السنة النبوية", style: pw.TextStyle(font: arabicFont, fontSize: 24, color: PdfColors.blueGrey900)),
            ),
            pw.SizedBox(height: 10),
            pw.Text(widget.title, style: pw.TextStyle(font: arabicFont, fontSize: 18, color: PdfColors.blueGrey700)),
            pw.Divider(thickness: 1, height: 20),
            ...paragraphs.map((p) => pw.Paragraph(text: p, style: pw.TextStyle(font: arabicFont, fontSize: widget.fontSize))),
          ],
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/transcript.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], subject: 'السنة النبوية - ${widget.title}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 6. Use YoutubePlayerBuilder to handle full-screen orientation automatically
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        progressColors: const ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: sharePdf),
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                onPressed: toggleFavorite,
              ),
            ],
          ),
          body: content.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 7. Display the Video Player at the top
                      player, 
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: colors.shadow.withOpacity(0.1), blurRadius: 8),
                            ],
                          ),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: SelectableText(
                              content,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: widget.fontSize,
                                height: 1.9,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: copyText,
            label: const Text("نسخ النص"),
            icon: const Icon(Icons.copy),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}