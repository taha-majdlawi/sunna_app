import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart'; // تأكد من المسار الصحيح
import 'order_form_screen.dart'; // تأكد من المسار الصحيح

class BookStoreScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;

  const BookStoreScreen({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  State<BookStoreScreen> createState() => _BookStoreScreenState();
}

class _BookStoreScreenState extends State<BookStoreScreen> {
  final List<Map<String, String>> books = [
    {
      "title": "رسائل من القرآن",
      "author": "أدهم شرقاوي",
      "price": "10 \$",
      "desc": "تأملات عميقة في آيات الله",
    },
    {
      "title": "على خطى الرسول",
      "author": "أدهم شرقاوي",
      "price": "12 \$",
      "desc": "مواقف نبوية بأسلوب أدبي",
    },
    {
      "title": "ليطمئن قلبي",
      "author": "أدهم شرقاوي",
      "price": "15 \$",
      "desc": "رحلة إيمانية في اليقين",
    },
  ];

  // دالة الدخول للتطبيق وحفظ الحالة لعدم الظهور مجدداً
  Future<void> _enterApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'seen_books',
      false,
    ); // نضعها false ليعرف main.dart أنها شوهدت

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          isDarkMode: widget.isDarkMode,
          fontSize: widget.fontSize,
          onThemeChanged: widget.onThemeChanged,
          onFontSizeChanged: widget.onFontSizeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("مكتبة الإصدارات المميزة"),
        actions: [
          TextButton(
            onPressed: _enterApp,
            child: const Text("تخطي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "يمكنك الآن طلب نسخ ورقية من أشهر الكتب الدينية وتصلك حتى باب بيتك",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: const Icon(
                      Icons.book,
                      size: 40,
                      color: Colors.amber,
                    ),
                    title: Text(
                      book['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${book['author']}\n${book['desc']}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book['price']!,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Icon(Icons.shopping_cart_outlined, size: 18),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderFormScreen(bookTitle: book['title']!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _enterApp,
              child: const Text("استمرار إلى التطبيق الرئيسي"),
            ),
          ),
        ],
      ),
    );
  }
}
