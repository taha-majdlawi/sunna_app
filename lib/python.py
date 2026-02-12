import json
import yt_dlp

# ========= الإعدادات =========
PLAYLIST_URL = "https://youtube.com/playlist?list=PLXFPGGQEPecF6S0y3Fe4lE_F3uyssc3GJ"
JSON_PATH = "assets/transcripts_list.json"
# ==============================


def fetch_playlist_videos(url):
    ydl_opts = {
        'extract_flat': True,
        'skip_download': True,
        'quiet': True,
    }

    videos = []

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)

        for entry in info.get('entries', []):
            if entry:
                video_id = entry.get('id')
                title = entry.get('title')
                videos.append({
                    "title": title,
                    "url": f"https://youtu.be/{video_id}"
                })

    return videos


def update_json_with_youtube():
    # قراءة ملف JSON الحالي
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        episodes = json.load(f)

    # جلب فيديوهات اليوتيوب
    videos = fetch_playlist_videos(PLAYLIST_URL)

    print(f"تم العثور على {len(videos)} فيديو في Playlist")
    print(f"عدد الحلقات في JSON: {len(episodes)}")

    # نربط حسب الترتيب
    for i in range(min(len(episodes), len(videos))):
        episodes[i]["youtube_title"] = videos[i]["title"]
        episodes[i]["youtube_url"] = videos[i]["url"]

    # حفظ الملف بعد التعديل
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(episodes, f, ensure_ascii=False, indent=4)

    print("✅ تم تحديث ملف transcripts_list.json بنجاح!")


if __name__ == "__main__":
    update_json_with_youtube()
