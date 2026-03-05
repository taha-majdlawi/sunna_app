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

  // Data Mapping (Replace with your actual links)
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

  // Remove from favorites directly from this screen
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
      appBar: AppBar(
        title: const Text("المفضلة"),
        centerTitle: true,
      ),
      body: favoritePaths.isEmpty
          ? const Center(child: Text("لا توجد حلقات في المفضلة بعد"))
          : ListView.builder(
              itemCount: favoritePaths.length,
              itemBuilder: (context, index) {
                final path = favoritePaths[index];
                final title = _getTitleFromPath(path);
                
                // 1. Get the URL from our map, or provide a fallback
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
                    leading: const Icon(Icons.play_circle_fill, color: Colors.red),
                    title: Text(
                      "حلقة: $title", 
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("اسحب للحذف من المفضلة", textDirection: TextDirection.rtl, style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            youtubeUrl: ytUrl, // 2. Pass the retrieved URL here
                            assetPath: path,
                            title: title,
                            fontSize: 18.0,
                          ),
                        ),
                      );
                      _loadFavorites(); 
                    },
                  ),
                );
              },
            ),
    );
  }
}