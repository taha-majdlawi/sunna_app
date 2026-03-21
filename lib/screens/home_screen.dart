import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // تأكد من إضافة المكتبة في pubspec.yaml
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
  String? lastReadEpisodeNumber; // لتخزين رقم آخر حلقة تم قراءتها

  final TextEditingController _searchController = TextEditingController();
  String _searchType = "الكل";

  @override
  void initState() {
    super.initState();
    loadEpisodes();
    _loadProgress(); // تحميل التقدم عند تشغيل الشاشة
  }

  // تحميل رقم آخر حلقة من الذاكرة
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadEpisodeNumber = prefs.getString('last_read_number');
    });
  }

  // حفظ التقدم
  Future<void> _saveProgress(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_number', number);
    setState(() {
      lastReadEpisodeNumber = number;
    });
  }

  Future<void> loadEpisodes() async {
    try {
      final jsonString = await rootBundle.loadString('assets/transcripts_list.json');
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

  void searchEpisodes(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() => filteredEpisodes = List.from(episodes));
      return;
    }
    setState(() {
      filteredEpisodes = episodes.where((episode) {
        final title = (episode["youtube_title"] ?? episode["title"] ?? "").toString().toLowerCase();
        final rawNumber = (episode["number"] ?? "").toString();
        final int? entryNumber = int.tryParse(rawNumber);
        final int? searchNumber = int.tryParse(query);

        if (_searchType == "الرقم") {
          return entryNumber != null && searchNumber != null && entryNumber == searchNumber;
        } else if (_searchType == "العنوان") {
          return title.contains(query.toLowerCase());
        } else {
          bool titleMatch = title.contains(query.toLowerCase());
          bool numberMatch = (entryNumber != null && searchNumber != null && entryNumber == searchNumber) || rawNumber.contains(query);
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
    // حفظ التقدم قبل الانتقال
    _saveProgress(episode["number"].toString());

    final String episodeTitle = episode["youtube_title"] ?? episode["title"] ?? "";
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
    ).then((_) => _loadProgress()); // تحديث الواجهة عند العودة
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
        title: const Text("السنة النبوية", style: TextStyle(fontWeight: FontWeight.bold)),
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
      drawer: _buildDrawer(theme, colors),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchSection(colors, theme),
                
                // --- ميزة متابعة التقدم (بطاقة الاستئناف) ---
                if (lastReadEpisodeNumber != null && _searchController.text.isEmpty)
                  _buildResumeCard(theme, colors),

                _buildListHeader(theme),
                _buildEpisodesList(colors),
              ],
            ),
    );
  }

  Widget _buildResumeCard(ThemeData theme, ColorScheme colors) {
    // البحث عن بيانات الحلقة الأخيرة من القائمة الأصلية
    final lastEpisode = episodes.firstWhere(
      (e) => e["number"].toString() == lastReadEpisodeNumber,
      orElse: () => {},
    );

    if (lastEpisode.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: colors.primary.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.primary.withOpacity(0.3)),
        ),
        child: ListTile(
          leading: Icon(Icons.history, color: colors.primary),
          title: const Text("تابع القراءة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(
            "${lastEpisode['number']} - ${lastEpisode['youtube_title'] ?? lastEpisode['title']}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            int idx = episodes.indexOf(lastEpisode);
            _navigateToDetail(idx, lastEpisode);
          },
        ),
      ),
    );
  }

  Widget _buildSearchSection(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            keyboardType: _searchType == "الرقم" ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: _searchType == "الرقم" ? "أدخل رقم الحديث..." : "ابحث في العناوين...",
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
                      searchEpisodes(_searchController.text);
                    });
                  },
                  selectedColor: colors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : colors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${filteredEpisodes.length} حديثاً", style: theme.textTheme.labelLarge),
          const Text("قائمة السلسلة", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEpisodesList(ColorScheme colors) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: filteredEpisodes.length,
        itemBuilder: (context, index) {
          final episode = filteredEpisodes[index];
          final String episodeNum = episode["number"].toString();
          final String title = episode["youtube_title"] ?? episode["title"] ?? "";
          final bool isLastRead = lastReadEpisodeNumber == episodeNum;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: isLastRead ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isLastRead ? colors.primary : colors.outlineVariant.withOpacity(0.5),
                width: isLastRead ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isLastRead ? colors.primary : colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        episodeNum,
                        style: TextStyle(
                          color: isLastRead ? Colors.white : colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isLastRead)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                textAlign: TextAlign.right,
              ),
              trailing: Icon(Icons.arrow_back_ios_new, size: 16, color: colors.primary),
              onTap: () => _navigateToDetail(index, episode),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme, ColorScheme colors) {
    return Drawer(
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
            leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
            title: const Text("تواصل عبر واتساب"),
            onTap: openWhatsApp,
          ),
        ],
      ),
    );
  }
}