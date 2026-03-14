import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunaa_app/screens/fav_screen.dart';
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

  List<Map<String, dynamic>> episodes = [];
  List<Map<String, dynamic>> filteredEpisodes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {

    final jsonString =
        await rootBundle.loadString(
      'assets/transcripts_list.json',
    );

    final List data = json.decode(jsonString);

    setState(() {

      episodes =
          data.cast<Map<String, dynamic>>();

      filteredEpisodes =
          List.from(episodes);

      isLoading = false;
    });
  }

  void searchEpisodes(String value) {

    final results = episodes.where((episode) {

      final title =
          (episode["youtube_title"] ??
                  episode["title"] ??
                  "")
              .toLowerCase();

      return title.contains(
          value.toLowerCase());

    }).toList();

    setState(() {
      filteredEpisodes = results;
    });
  }

  void openRandomEpisode() {

    if (episodes.isEmpty) return;

    final random = Random();

    final index =
        random.nextInt(episodes.length);

    final episode = episodes[index];

    final String episodeTitle =
        episode["youtube_title"] ??
            episode["title"] ??
            "";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          youtubeUrl:
              episode["youtube_url"] ?? "",
          assetPath: episode["path"],
          title:
              "${episode["number"]} - $episodeTitle",
          fontSize: widget.fontSize,
          index: index,
          episodes: episodes,
        ),
      ),
    );
  }

  Future<void> openWhatsApp() async {

    final Uri url =
        Uri.parse("https://wa.me/972592345890");

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint(
          "Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(

      appBar: AppBar(
        title: const Text("السنة النبوية"),
        centerTitle: true,

        actions: [

          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: "حديث عشوائي",
            onPressed: openRandomEpisode,
          ),

          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [

            DrawerHeader(
              decoration: BoxDecoration(
                  color: colors.primary),

              child: Center(
                child: Text(
                  "تحت إشراف الأستاذ خالد العتيبي",

                  style: theme
                      .textTheme.titleMedium
                      ?.copyWith(
                    color: colors.onPrimary,
                    fontWeight:
                        FontWeight.bold,
                  ),

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
                label: widget.fontSize
                    .round()
                    .toString(),
                onChanged:
                    widget.onFontSizeChanged,
              ),
            ),

            SwitchListTile(
              title: const Text(
                  "الوضع الليلي"),
              value: widget.isDarkMode,
              onChanged:
                  widget.onThemeChanged,
            ),

            ListTile(
              leading: Icon(
                Icons.message,
                color: colors.primary,
              ),

              title: const Text(
                  "تواصل عبر واتساب"),

              onTap: openWhatsApp,
            ),

            ListTile(
              leading: Icon(
                Icons.star,
                color: colors.primary,
              ),

              title: const Text("المفضلة"),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
              ),

              onTap: () {

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FavoritesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator())
          : Column(
              children: [

                Padding(
                  padding:
                      const EdgeInsets.all(12),

                  child: TextField(

                    decoration: InputDecoration(

                      hintText: "ابحث ...",

                      hintTextDirection:
                          TextDirection.rtl,

                      prefixIcon:
                          const Icon(Icons.search),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),

                    onChanged: searchEpisodes,
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 16),

                  child: Align(
                    alignment:
                        Alignment.centerRight,

                    child: Text(
                      "العدد الكلي : ${filteredEpisodes.length}",
                      style: const TextStyle(
                          fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Expanded(

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.all(12),

                    itemCount:
                        filteredEpisodes.length,

                    itemBuilder:
                        (context, index) {

                      final episode =
                          filteredEpisodes[index];

                      final String
                          episodeTitle =
                          episode["youtube_title"] ??
                              episode["title"] ??
                              "";

                      return Card(

                        margin:
                            const EdgeInsets.symmetric(
                                vertical: 8),

                        child: ListTile(

                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          title: Text(
                            "${episode["number"]} - $episodeTitle",

                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),

                            textAlign:
                                TextAlign.right,
                          ),

                          trailing: Icon(
                            Icons.play_circle_fill,
                            color:
                                colors.primary,
                            size: 32,
                          ),

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    DetailScreen(

                                  youtubeUrl:
                                      episode["youtube_url"] ??
                                          "",

                                  assetPath:
                                      episode["path"],

                                  title:
                                      "${episode["number"]} - $episodeTitle",

                                  fontSize:
                                      widget.fontSize,

                                  index: index,

                                  episodes:
                                      episodes,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}