import yt_dlp

# رابط قائمة التشغيل
playlist_url = 'https://youtube.com/playlist?list=PLXFPGGQEPecF6S0y3Fe4lE_F3uyssc3GJ'

# إعدادات الاستخراج
ydl_opts = {
    'quiet': True,
    'extract_flat': True,
    'force_generic_extractor': False,
}

print("جاري استخراج الروابط من القائمة...")
print("-" * 30)

try:
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        # استخراج معلومات القائمة
        result = ydl.extract_info(playlist_url, download=False)
        
        if 'entries' in result:
            # استخدام enumerate لتبدأ العد من رقم 1
            for index, entry in enumerate(result['entries'], start=1):
                # بناء رابط الفيديو الكامل
                video_link = f"https://www.youtube.com/watch?v={entry['id']}"
                # طباعة رقم الحلقة مع الرابط
                print(f"الحلقة {index}: {video_link}")
                
except Exception as e:
    print(f"حدث خطأ أثناء الاستخراج: {e}")