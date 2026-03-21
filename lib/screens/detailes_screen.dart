import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';

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
  
  // متغيرات الملاحظات المحسنة
  final TextEditingController _notesController = TextEditingController();
  bool _isNotesVisible = false;

  @override
  void initState() {
    super.initState();
    loadText();
    _checkFavoriteStatus();
    _loadSavedNote(); // تحميل الملاحظات فور فتح الشاشة

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";
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
    _notesController.dispose();
    super.dispose();
  }

  // تحميل الملاحظة المحفوظة باستخدام مسار الملف كمفتاح فريد
  Future<void> _loadSavedNote() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedNote = prefs.getString('note_${widget.assetPath}');
    if (savedNote != null && mounted) {
      setState(() {
        _notesController.text = savedNote;
      });
    }
  }

  // حفظ الملاحظة تلقائياً عند الكتابة
  Future<void> _saveNote(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_${widget.assetPath}', text);
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_episodes') ?? [];
    if (mounted) {
      setState(() {
        isFavorite = favorites.contains(widget.assetPath);
      });
    }
  }

  Future<void> loadText() async {
    try {
      final loadedContent = await rootBundle.loadString(widget.assetPath);
      if (mounted) {
        setState(() {
          content = loadedContent;
        });
      }
    } catch (e) {
      if (mounted) setState(() => content = "تعذر تحميل نص الحديث.");
    }
  }

  void copyText() {
    if (content.isEmpty) return;
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم نسخ نص الحديث", textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  Future<void> shareText() async {
    if (content.isEmpty) return;
    await Share.share("$content\n\nالمصدر: ${widget.title}", subject: "السنة النبوية");
  }

  void _navigate(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.episodes.length) return;
    
    final target = widget.episodes[newIndex];
    final String targetTitle = target["youtube_title"] ?? target["title"] ?? "";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          assetPath: target['path'],
          title: "${target["number"]} - $targetTitle",
          fontSize: widget.fontSize,
          youtubeUrl: target['youtube_url'] ?? "",
          index: newIndex,
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
        progressIndicatorColor: colors.primary,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
                onPressed: toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: content.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.youtubeUrl.isNotEmpty) player,
                      
                      const SizedBox(height: 15),

                      // أزرار الأدوات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.copy_rounded, "نسخ", copyText, colors),
                            _buildActionButton(Icons.share_rounded, "مشاركة", shareText, colors),
                            _buildActionButton(
                              _isNotesVisible ? Icons.edit_note : Icons.note_add_outlined,
                              "ملاحظات",
                              () => setState(() => _isNotesVisible = !_isNotesVisible),
                              colors,
                              isActive: _isNotesVisible
                            ),
                          ],
                        ),
                      ),

                      // قسم الملاحظات الشخصية مع أنيميشن
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: colors.primary.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.edit_note, size: 20, color: colors.primary),
                                    const SizedBox(width: 8),
                                    const Text("ملاحظاتك الشخصية:", 
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesController,
                                  maxLines: 4,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: "اكتب ما استنبطته من هذا الدرس هنا...",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                  ),
                                  onChanged: _saveNote,
                                ),
                              ],
                            ),
                          ),
                        ),
                        crossFadeState: _isNotesVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      // عرض نص الحديث في بطاقة أنيقة
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Card(
                          elevation: 0,
                          color: colors.surfaceVariant.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: SelectableText(
                                content,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: widget.fontSize,
                                  height: 1.8,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // أزرار التنقل بين الأحاديث
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavigationButton(
                              label: "السابق",
                              icon: Icons.arrow_back_ios_new,
                              onPressed: widget.index > 0 ? () => _navigate(widget.index - 1) : null,
                              colors: colors,
                              isNext: false,
                            ),
                            _buildNavigationButton(
                              label: "التالي",
                              icon: Icons.arrow_forward_ios,
                              onPressed: widget.index < widget.episodes.length - 1 ? () => _navigate(widget.index + 1) : null,
                              colors: colors,
                              isNext: true,
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

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, ColorScheme colors, {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isActive ? colors.onPrimary : colors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required String label, 
    required IconData icon, 
    required VoidCallback? onPressed, 
    required ColorScheme colors,
    required bool isNext,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: colors.primary.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // نعكس ترتيب الأيقونة والنص بناءً على كونه التالي أو السابق
      icon: isNext ? const SizedBox() : Icon(icon, size: 16),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (isNext) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 16),
          ]
        ],
      ),
    );
  }
}