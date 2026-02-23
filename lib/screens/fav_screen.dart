import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunaa_app/screens/detailes_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoritePaths = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritePaths = prefs.getStringList('favorite_episodes') ?? [];
    });
  }

  // دالة لاستخراج اسم الحلقة من المسار (مثال: assets/data/h1.txt تصبح h1)
  String _getTitleFromPath(String path) {
    return path.split('/').last.replaceAll('.txt', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المفضلة")),
      body: favoritePaths.isEmpty
          ? const Center(child: Text("لا توجد حلقات في المفضلة بعد"))
          : // الكود المصحح لـ ListView.builder
            ListView.builder(
              itemCount: favoritePaths.length, // هنا نستخدم length للقائمة
              itemBuilder: (context, index) {
                // أضفنا index هنا ليكون المعامل الثاني
                final path = favoritePaths[index];
                final title = _getTitleFromPath(path);

                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text("حلقة: $title", textDirection: TextDirection.rtl),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          assetPath: path,
                          title: title,
                          fontSize: 18.0,
                        ),
                      ),
                    );
                    _loadFavorites(); // تحديث القائمة عند العودة
                  },
                );
              },
            ),
    );
  }
}
