import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

// استيراد الشاشات الأخرى
import 'fav_screen.dart';
import 'detailes_screen.dart';
import 'azkar_screen.dart';
import 'tasbih_screen.dart';

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
  int _selectedIndex = 0;
  List<Map<String, dynamic>> episodes = [];
  List<Map<String, dynamic>> filteredEpisodes = [];
  bool isLoading = true;
  String? lastReadEpisodeNumber;

  final TextEditingController _searchController = TextEditingController();
  String _searchType = "الكل";

  // قائمة العناوين الديناميكية للـ AppBar
  final List<String> _titles = [
    "السنة النبوية",
    "الأذكار اليومية",
    "المسبحة الإلكترونية",
    "المفضلة",
  ];

  @override
  void initState() {
    super.initState();
    loadEpisodes();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => lastReadEpisodeNumber = prefs.getString('last_read_number'));
  }

  Future<void> _saveProgress(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_number', number);
    setState(() => lastReadEpisodeNumber = number);
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
      setState(() => isLoading = false);
    }
  }

  void searchEpisodes(String value) {
    final query = value.trim();
    setState(() {
      if (query.isEmpty) {
        filteredEpisodes = List.from(episodes);
      } else {
        filteredEpisodes = episodes.where((episode) {
          final title = (episode["youtube_title"] ?? episode["title"] ?? "").toString().toLowerCase();
          final rawNum = episode["number"].toString();
          if (_searchType == "الرقم") return rawNum == query;
          if (_searchType == "العنوان") return title.contains(query.toLowerCase());
          return title.contains(query.toLowerCase()) || rawNum.contains(query);
        }).toList();
      }
    });
  }

  void openRandomEpisode() {
    if (episodes.isEmpty) return;
    final index = Random().nextInt(episodes.length);
    _navigateToDetail(index, episodes[index]);
  }

  void _navigateToDetail(int index, Map<String, dynamic> episode) {
    _saveProgress(episode["number"].toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          youtubeUrl: episode["youtube_url"] ?? "",
          assetPath: episode["path"],
          title: "${episode["number"]} - ${episode["youtube_title"] ?? episode["title"]}",
          fontSize: widget.fontSize,
          index: index,
          episodes: episodes,
        ),
      ),
    ).then((_) => _loadProgress());
  }

  Future<void> openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/972592345890");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final List<Widget> _pages = [
      _buildMainListContent(theme, colors),
      const AzkarScreen(),
      const TasbihScreen(),
      const FavoritesScreen(),
    ];

    return Scaffold(
      // --- الـ AppBar الاحترافي الموحد ---
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colors.primary, colors.primary.withOpacity(0.85)],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.casino_outlined),
              onPressed: openRandomEpisode,
            ),
        ],
      ),

      drawer: _buildDrawer(theme, colors),
      
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
  
  // 1. تكبير وبروز النصوص (Label)
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return TextStyle(
        fontSize: 15,                // حجم النص عند الاختيار
        fontWeight: FontWeight.bold,  // بروز قوي (عريض)
        color: colors.primary,       // لون هوية التطبيق
      );
    }
    return TextStyle(
      fontSize: 13,                  // حجم النص غير المختار
      fontWeight: FontWeight.w500, 
      color: colors.onSurfaceVariant,
    );
  }),

  // 2. التحكم في حجم وشكل الأيقونات بطريقة صحيحة
  // نستخدم theme لضبط iconTheme بشكل غير مباشر أو نعتمد على الإعدادات الافتراضية
  destinations: [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined, size: 26), 
      selectedIcon: Icon(Icons.home, size: 28, color: colors.primary), 
      label: 'الرئيسية',
    ),
    NavigationDestination(
      icon: const Icon(Icons.menu_book_outlined, size: 26), 
      selectedIcon: Icon(Icons.menu_book, size: 28, color: colors.primary), 
      label: 'الأذكار',
    ),
    NavigationDestination(
      icon: const Icon(Icons.ads_click, size: 26), 
      selectedIcon: Icon(Icons.ads_click_rounded, size: 28, color: colors.primary), 
      label: 'المسبحة',
    ),
    NavigationDestination(
      icon: const Icon(Icons.favorite_border, size: 26), 
      selectedIcon: Icon(Icons.favorite, size: 28, color: colors.primary), 
      label: 'المفضلة',
    ),
  ],
),
    );
  }

  // محتوى قائمة الأحاديث
  Widget _buildMainListContent(ThemeData theme, ColorScheme colors) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildSearchSection(colors, theme),
              if (lastReadEpisodeNumber != null && _searchController.text.isEmpty)
                _buildResumeCard(theme, colors),
              _buildListHeader(theme),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: filteredEpisodes.length,
                itemBuilder: (context, index) {
                  final ep = filteredEpisodes[index];
                  return _buildEpisodeItem(ep, ep["number"].toString(), ep["youtube_title"] ?? ep["title"], lastReadEpisodeNumber == ep["number"].toString(), colors, index);
                },
              ),
            ],
          );
  }

 Widget _buildEpisodeItem(
    Map ep, String num, String title, bool isLast, ColorScheme colors, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12, left: 2, right: 2), // زيادة الهامش السفلي قليلاً
    elevation: isLast ? 4 : 1, // إضافة ظل خفيف للبروز
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(
        color: isLast ? colors.primary : colors.outlineVariant.withOpacity(0.5),
        width: isLast ? 1.5 : 1,
      ),
    ),
    child: ListTile(
      // زيادة الحشوة الداخلية (Padding) لجعل البطاقة أكبر
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      
      // تكبير الدائرة التي تحتوي على الرقم
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isLast ? colors.primary : colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              color: isLast ? Colors.white : colors.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 16, // تكبير خط الرقم
            ),
          ),
        ),
      ),

      // تحسين شكل العنوان
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15, // تكبير حجم الخط قليلاً
          height: 1.3,  // تحسين المسافة بين الأسطر إذا كان العنوان طويلاً
        ),
        textAlign: TextAlign.right,
      ),

      // أيقونة الانتقال
      trailing: Icon(
        Icons.arrow_back_ios_new,
        size: 16,
        color: colors.primary,
      ),
      
      onTap: () => _navigateToDetail(index, ep.cast<String, dynamic>()),
    ),
  );
}
  Widget _buildSearchSection(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: "ابحث في السلسلة...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
            onChanged: searchEpisodes,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["الكل", "العنوان", "الرقم"].map((type) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(type),
                selected: _searchType == type,
                onSelected: (s) => setState(() { _searchType = type; searchEpisodes(_searchController.text); }),
              ),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildResumeCard(ThemeData theme, ColorScheme colors) {
    final last = episodes.firstWhere((e) => e["number"].toString() == lastReadEpisodeNumber, orElse: () => {});
    return last.isEmpty ? const SizedBox.shrink() : Card(
      margin: const EdgeInsets.all(16),
      color: colors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: colors.primary.withOpacity(0.2))),
      child: ListTile(
        leading: Icon(Icons.history, color: colors.primary),
        title: const Text("تابع من حيث توقفت", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(last["youtube_title"] ?? last["title"], maxLines: 1),
        onTap: () => _navigateToDetail(episodes.indexOf(last), last),
      ),
    );
  }

  Widget _buildListHeader(ThemeData theme) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${filteredEpisodes.length} حديثاً"), const Text("قائمة الأحاديث", style: TextStyle(fontWeight: FontWeight.bold))]),
  );

  Widget _buildDrawer(ThemeData theme, ColorScheme colors) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, colors.primary.withOpacity(0.7)])),
            child: const Center(child: Text("الإعدادات", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          ),
          ListTile(title: const Text("حجم الخط"), leading: const Icon(Icons.text_fields), subtitle: Slider(value: widget.fontSize, min: 14, max: 28, onChanged: widget.onFontSizeChanged)),
          SwitchListTile(title: const Text("الوضع الليلي"), secondary: const Icon(Icons.brightness_4), value: widget.isDarkMode, onChanged: widget.onThemeChanged),
          const Spacer(),
          ListTile(leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green), title: const Text("تواصل معنا"), onTap: openWhatsApp),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}