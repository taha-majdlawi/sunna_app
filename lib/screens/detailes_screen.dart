import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final double fontSize;
  final String youtubeUrl;
  final int index;
  final List<Map<String, dynamic>> episodes;

  const DetailScreen({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.fontSize,
    required this.youtubeUrl,
    required this.index,
    required this.episodes,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  String content = "";
  bool isFavorite = false;

  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();

    loadText();
    _checkFavoriteStatus();

    final videoId =
        YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {

    final prefs =
        await SharedPreferences.getInstance();

    final favorites =
        prefs.getStringList('favorite_episodes') ?? [];

    setState(() {
      isFavorite =
          favorites.contains(widget.assetPath);
    });
  }

  Future<void> loadText() async {

    final loadedContent =
        await rootBundle.loadString(widget.assetPath);

    setState(() {
      content = loadedContent;
    });
  }

  void copyText() {

    if (content.isEmpty) return;

    Clipboard.setData(
      ClipboardData(text: content),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(content: Text("تم نسخ النص")),
    );
  }

  Future<void> toggleFavorite() async {

    final prefs =
        await SharedPreferences.getInstance();

    List<String> favorites =
        prefs.getStringList('favorite_episodes') ?? [];

    setState(() {

      if (isFavorite) {
        favorites.remove(widget.assetPath);
        isFavorite = false;
      } else {
        favorites.add(widget.assetPath);
        isFavorite = true;
      }

    });

    await prefs.setStringList(
        'favorite_episodes', favorites);
  }

  Future<void> shareText() async {

    if (content.isEmpty) return;

    await Share.share(
      "$content\n\n${widget.title}",
      subject: "السنة النبوية",
    );
  }

  Future<void> sharePdf() async {

    if (content.isEmpty) return;

    try {

      final pdf = pw.Document();

      final arabicFontData =
          await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      );

      final arabicFont =
          pw.Font.ttf(arabicFontData);

      final paragraphs = content
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();

      pdf.addPage(

        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(35),

          build: (context) => [

            pw.Header(
              child: pw.Text(
                "السنة النبوية",
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 24,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              widget.title,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 18,
              ),
            ),

            pw.Divider(),

            ...paragraphs.map(
              (p) => pw.Paragraph(
                text: p,
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          ],
        ),
      );

      final tempDir =
          await getTemporaryDirectory();

      final file =
          File('${tempDir.path}/hadith.pdf');

      await file.writeAsBytes(
        await pdf.save(),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: widget.title,
      );

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );

      }
    }
  }

  void goToNext() {

    if (widget.index >=
        widget.episodes.length - 1) return;

    final next =
        widget.episodes[widget.index + 1];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          assetPath: next['asset'],
          title: next['title'],
          fontSize: widget.fontSize,
          youtubeUrl: next['youtube'] ?? "",
          index: widget.index + 1,
          episodes: widget.episodes,
        ),
      ),
    );
  }

  void goToPrevious() {

    if (widget.index <= 0) return;

    final prev =
        widget.episodes[widget.index - 1];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          assetPath: prev['asset'],
          title: prev['title'],
          fontSize: widget.fontSize,
          youtubeUrl: prev['youtube'] ?? "",
          index: widget.index - 1,
          episodes: widget.episodes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return YoutubePlayerBuilder(

      player: YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
      ),

      builder: (context, player) {

        return Scaffold(

          appBar: AppBar(
            title: Text(widget.title),
          ),

          body: content.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator())
              : SingleChildScrollView(

                  child: Column(

                    children: [

                      if (widget.youtubeUrl.isNotEmpty)
                        player,

                      const SizedBox(height: 10),

                      /// Reading Tools
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly,
                        children: [

                          IconButton(
                            icon:
                                const Icon(Icons.copy),
                            onPressed: copyText,
                          ),

                          IconButton(
                            icon:
                                const Icon(Icons.share),
                            onPressed: shareText,
                          ),

                          IconButton(
                            icon: Icon(isFavorite
                                ? Icons.star
                                : Icons.star_border),
                            onPressed: toggleFavorite,
                          ),

                        ],
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(16),

                        child: Container(

                          width: double.infinity,

                          padding:
                              const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow
                                    .withOpacity(0.1),
                                blurRadius: 8,
                              )
                            ],
                          ),

                          child: Directionality(
                            textDirection:
                                TextDirection.rtl,

                            child: SelectableText(
                              content,
                              style: theme
                                  .textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize:
                                    widget.fontSize,
                                height: 1.9,
                              ),
                              textAlign:
                                  TextAlign.justify,
                            ),
                          ),
                        ),
                      ),

                      /// Next / Previous Buttons
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 20),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [

                            ElevatedButton.icon(
                              onPressed: goToPrevious,
                              icon: const Icon(
                                  Icons.arrow_back),
                              label:
                                  const Text("السابق"),
                            ),

                            ElevatedButton.icon(
                              onPressed: goToNext,
                              icon: const Icon(
                                  Icons.arrow_forward),
                              label:
                                  const Text("التالي"),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                    ],
                  ),
                ),
        );
      },
    );
  }
}