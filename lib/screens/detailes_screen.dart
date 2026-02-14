import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // تم التعليق على حزمة اليوتيوب

class DetailScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  final String? youtubeUrl;

  DetailScreen({
    required this.assetPath,
    required this.title,
    this.youtubeUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String content = "";
   YoutubePlayerController? _controller; // تم التعليق على المتحكم

  @override
  void initState() {
    super.initState();
    loadText();
     initYoutube(); // تم التعليق على تهيئة اليوتيوب
  }

  Future<void> loadText() async {
    try {
      final loadedContent = await rootBundle.loadString(widget.assetPath);
      setState(() {
        content = loadedContent;
      });
    } catch (e) {
      setState(() {
        content = "حدث خطأ أثناء تحميل النص.";
      });
    }
  }

  
  void initYoutube() {
    if (widget.youtubeUrl != null && widget.youtubeUrl!.isNotEmpty) {
      final videoId =
          YoutubePlayer.convertUrlToId(widget.youtubeUrl!);

      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }
  

  @override
  void dispose() {
     _controller?.dispose(); // تم التعليق على تحرير الموارد
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orange[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 فيديو اليوتيوب (تم التعليق على العرض)
            
            if (_controller != null)
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              ),
            

            SizedBox(height: 20),

            /// 🔹 النص
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
