import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'detailes_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    final jsonString = await rootBundle.loadString(
      'assets/transcripts_list.json',
    );
    final jsonData = json.decode(jsonString);

    setState(() {
      episodes = jsonData;
      isLoading = false;
    });
  }

  Future<void> openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/972592345890");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("السنة النبوية"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  "تحت إشراف الأستاذ خالد العتيبي",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            ListTile(
              title: const Text("حجم الخط"),
              subtitle: Slider(
                value: widget.fontSize,
                min: 14,
                max: 28,
                divisions: 7,
                onChanged: widget.onFontSizeChanged,
              ),
            ),

            SwitchListTile(
              title: const Text("الوضع الليلي"),
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
            ),

            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text("تواصل عبر واتساب"),
              onTap: openWhatsApp,
            ),
          ],
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF3CC), Color(0xFFFFE0A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];

                  final String episodeTitle =
                      episode["youtube_title"] ?? episode["title"] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        "${episode["number"]} - $episodeTitle",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                      trailing: Icon(
                        Icons.play_circle_fill,
                        color: Colors.orange[400],
                        size: 32,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              assetPath: episode["path"],
                              title: "${episode["number"]} - $episodeTitle",
                              fontSize: widget.fontSize,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
