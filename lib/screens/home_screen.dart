import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fav_screen.dart';
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

  final TextEditingController _searchController = TextEditingController();
  String _searchType = "الكل"; // الخيارات: الكل، العنوان، الرقم

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/transcripts_list.json',
      );
      final List data = json.decode(jsonString);
      setState(() {
        episodes = data.cast<Map<String, dynamic>>();
        filteredEpisodes = List.from(episodes);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
      setState(() => isLoading = false);
    }
  }

  // منطق البحث المطور
void searchEpisodes(String value) {
  final query = value.trim();
  
  if (query.isEmpty) {
    setState(() => filteredEpisodes = List.from(episodes));
    return;
  }

  setState(() {
    filteredEpisodes = episodes.where((episode) {
      // 1. تجهيز العنوان للبحث
      final title = (episode["youtube_title"] ?? episode["title"] ?? "").toString().toLowerCase();
      
      // 2. تجهيز الرقم من الـ JSON (تحويله إلى رقم صحيح للتخلص من الأصفار الزائدة)
      final rawNumber = (episode["number"] ?? episode["id"] ?? "").toString();
      final int? entryNumber = int.tryParse(rawNumber);

      // 3. تجهيز رقم البحث المدخل من المستخدم
      final int? searchNumber = int.tryParse(query);

      if (_searchType == "الرقم") {
        // إذا نجح تحويل الطرفين إلى أرقام، نقارن القيم الحسابية
        // هذا سيجعل 1 تساوي 001 وتساوي 01
        return entryNumber != null && searchNumber != null && entryNumber == searchNumber;
      } else if (_searchType == "العنوان") {
        return title.contains(query.toLowerCase());
      } else {
        // في حالة "الكل": نبحث نصياً في العنوان، وحسابياً في الرقم
        bool titleMatch = title.contains(query.toLowerCase());
        bool numberMatch = (entryNumber != null && searchNumber != null && entryNumber == searchNumber) 
                           || rawNumber.contains(query); // لدعم البحث الجزئي بالرقم أيضاً
        return titleMatch || numberMatch;
      }
    }).toList();
  });
}

  void openRandomEpisode() {
    if (episodes.isEmpty) return;
    final index = Random().nextInt(episodes.length);
    _navigateToDetail(index, episodes[index]);
  }

  void _navigateToDetail(int index, Map<String, dynamic> episode) {
    final String episodeTitle =
        episode["youtube_title"] ?? episode["title"] ?? "";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          youtubeUrl: episode["youtube_url"] ?? "",
          assetPath: episode["path"],
          title: "${episode["number"]} - $episodeTitle",
          fontSize: widget.fontSize,
          index: index,
          episodes: episodes,
        ),
      ),
    );
  }

  Future<void> openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/972592345890");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "السنة النبوية",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: "حديث عشوائي",
            onPressed: openRandomEpisode,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 40, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      "تحت إشراف الأستاذ خالد العتيبي",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text("حجم الخط"),
              leading: const Icon(Icons.format_size),
              subtitle: Slider(
                value: widget.fontSize,
                min: 14,
                max: 28,
                divisions: 7,
                onChanged: widget.onFontSizeChanged,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text("الوضع الليلي"),
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
            ),
            const Divider(),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
              ),
              title: const Text("تواصل عبر واتساب"),
              onTap: openWhatsApp,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // منطقة البحث المتقدم
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        textAlign: TextAlign.right,
                        // تغيير لوحة المفاتيح تلقائياً إذا كان البحث بالرقم
                        keyboardType: _searchType == "الرقم"
                            ? TextInputType.number
                            : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: _searchType == "الرقم"
                              ? "أدخل رقم الحديث..."
                              : "ابحث في العناوين...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    searchEpisodes("");
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: searchEpisodes,
                      ),
                      const SizedBox(height: 12),
                      // فلاتر البحث (Chips)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ["الكل", "العنوان", "الرقم"].map((type) {
                          final isSelected = _searchType == type;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  _searchType = type;
                                  // نقوم بمسح النص عند تغيير النوع لتجنب الارتباك أو إعادة البحث بالنوع الجديد
                                  searchEpisodes(_searchController.text);
                                });
                              },
                              selectedColor: colors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : colors.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // عرض عدد النتائج
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filteredEpisodes.length} حديثاً",
                        style: theme.textTheme.labelLarge,
                      ),
                      const Text(
                        "قائمة السلسلة",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // قائمة الأحاديث
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: filteredEpisodes.length,
                    itemBuilder: (context, index) {
                      final episode = filteredEpisodes[index];
                      final String title =
                          episode["youtube_title"] ?? episode["title"] ?? "";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: colors.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                episode["number"].toString(),
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: colors.primary,
                          ),
                          onTap: () => _navigateToDetail(index, episode),
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
