import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart'; // <-- هذا لتعريف PageFormat
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isFavorite = false;
  pw.Font? arabicFont;

  @override
  void initState() {
    super.initState();
    loadText();
    loadArabicFont();
    _checkFavoriteStatus();
  }

  // التحقق من حالة المفضلة عند فتح الشاشة
  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites =
        prefs.getStringList('favorite_episodes') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.assetPath);
    });
  }

  // تحميل النص من الملف
  Future<void> loadText() async {
    final loadedContent = await rootBundle.loadString(widget.assetPath);
    setState(() {
      content = loadedContent;
    });
  }

  // تحميل الخط العربي من assets/fonts
  Future<void> loadArabicFont() async {
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    setState(() {
      arabicFont = pw.Font.ttf(fontData);
    });
  }

  // نسخ النص
  void copyText() {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تم نسخ النص")));
  }

// تبديل حالة المفضلة وحفظها محلياً
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

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? "تمت الإضافة للمفضلة" : "تمت الإزالة من المفضلة"),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

  Future<void> sharePdf() async {
    // التأكد من وجود نص للمشاركة
    if (content.isEmpty) return;

    try {
      final pdf = pw.Document();

      // تحميل الخط العربي
      final arabicFontData = await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      );
      final arabicFont = pw.Font.ttf(arabicFontData);

      // تقسيم النص لفقرات لضمان توزيعه بشكل سليم على الصفحات
      final paragraphs = content
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          // اتجاه النص العام من اليمين لليسار
          textDirection: pw.TextDirection.rtl,
          build: (context) => [
            // الهيدر (اسم التطبيق)
            pw.Header(
              level: 0,
              child: pw.Text(
                "السنة النبوية",
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            // عنوان المحتوى
            pw.Text(
              widget.title,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey700,
              ),
            ),
            pw.Divider(thickness: 1, height: 20),
            pw.SizedBox(height: 10),

            // توزيع النص كفقرات ذكية تنتقل تلقائياً للصفحات التالية
            ...paragraphs.map(
              (p) => pw.Paragraph(
                text: p,
                textAlign: pw.TextAlign.justify,
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: widget.fontSize,
                  lineSpacing: 4,
                ),
                margin: const pw.EdgeInsets.only(bottom: 10),
              ),
            ),
          ],
          // إضافة ترقيم الصفحات في الأسفل
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
        ),
      );

      // حفظ الملف في المسار المؤقت للجهاز
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/transcript.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      // الطريقة الحديثة والموصى بها للمشاركة (SharePlus)
      // ملاحظة: subject يستخدم غالباً عند المشاركة عبر البريد الإلكتروني
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'السنة النبوية - ${widget.title}',
        text: 'مشاركة من تطبيق السنة النبوية',
      );
    } catch (e) {
      // إظهار رسالة خطأ في حال فشلت العملية (مثلاً: الخط غير موجود أو مشكلة في الذاكرة)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("فشلت عملية إنشاء الملف: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: "مشاركة PDF",
            icon: const Icon(Icons.share),
            onPressed: sharePdf,
          ),
          IconButton(
            tooltip: "المفضلة",
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
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
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: SelectableText(
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: copyText,
        label: const Text("نسخ النص"),
        icon: const Icon(Icons.copy),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
