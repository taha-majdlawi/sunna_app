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

  // خريطة روابط الفيديوهات: استبدل بالمصادر الحقيقية
  final Map<String, String> videoLinks = {
    'assets/data/h1.txt': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'assets/data/h2.txt': 'https://www.youtube.com/watch?v=example2',
  };

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

  Future<void> _removeFromFavorites(String path) async {
    final prefs = await SharedPreferences.getInstance();
    favoritePaths.remove(path);
    await prefs.setStringList('favorite_episodes', favoritePaths);
    setState(() {});
  }

  String _getTitleFromPath(String path) {
    return path.split('/').last.replaceAll('.txt', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: favoritePaths.isEmpty
          ? const Center(
              child: Text(
                "لا توجد حلقات في المفضلة بعد",
                textDirection: TextDirection.rtl,
              ),
            )
          : ListView.builder(
              itemCount: favoritePaths.length,
              itemBuilder: (context, index) {
                final path = favoritePaths[index];
                final title = _getTitleFromPath(path);

                // الحصول على رابط اليوتيوب من الخريطة
                final String ytUrl = videoLinks[path] ?? "";

                return Dismissible(
                  key: Key(path),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _removeFromFavorites(path),
                  child: ListTile(
                    leading: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.red,
                    ),
                    title: Text(
                      "حلقة: $title",
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "اسحب للحذف من المفضلة",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      // بناء قائمة الحلقات من favoritePaths
                      final List<Map<String, dynamic>> favEpisodes =
                          favoritePaths.map((path) {
                            return {
                              'asset': path,
                              'title': _getTitleFromPath(path),
                              'youtube': videoLinks[path] ?? "",
                            };
                          }).toList();

                      final int currentIndex =
                          index; // index الحالي في favoritePaths

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            youtubeUrl:
                                favEpisodes[currentIndex]['youtube'] ?? "",
                            assetPath: favEpisodes[currentIndex]['asset'],
                            title: favEpisodes[currentIndex]['title'],
                            fontSize: 18.0,
                            index: currentIndex, // ⚠️ هنا نمرر index
                            episodes: favEpisodes, // ⚠️ هنا نمرر قائمة الحلقات
                          ),
                        ),
                      );

                      _loadFavorites(); // تحديث بعد العودة
                    },
                  ),
                );
              },
            ),
    );
  }
}
