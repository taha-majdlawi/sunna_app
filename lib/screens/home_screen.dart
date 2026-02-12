import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunaa_app/screens/detailes_screen.dart';

class HomeScreen extends StatefulWidget {
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
    final String jsonString =
        await rootBundle.loadString('assets/transcripts_list.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      episodes = jsonData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("السنة النبوية"),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: ListTile(
                    title: Text(
                      "${episode["number"]} - ${episode["youtube_title"] ?? episode["title"]}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(Icons.play_circle_fill,
                        color: Colors.orange, size: 32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            assetPath: episode["path"],
                            title: episode["youtube_title"] ??
                                episode["title"],
                            youtubeUrl: episode["youtube_url"],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
