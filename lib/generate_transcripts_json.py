import os
import json
import re

folder_path = "assets/transcripts"
episodes = []

files = sorted(os.listdir(folder_path))

counter = 1

for filename in files:
    if filename.endswith(".txt"):
        old_path = os.path.join(folder_path, filename)

        # استخراج الرقم إن وجد
        match = re.match(r'(\d+)', filename)
        if match:
            number = match.group(1).zfill(3)
        else:
            number = str(counter).zfill(3)

        # استخراج العنوان بدون الرقم
        parts = filename.split('-', 1)
        if len(parts) == 2:
            title = parts[1].replace(".txt", "").strip()
        else:
            title = filename.replace(".txt", "").strip()

        # اسم جديد آمن تماماً
        new_filename = f"{number}.txt"
        new_path = os.path.join(folder_path, new_filename)

        # إعادة تسمية فعلية
        if filename != new_filename:
            os.rename(old_path, new_path)
            print(f"تمت إعادة تسمية: {filename} -> {new_filename}")

        episodes.append({
            "number": number,
            "title": title,
            "path": f"assets/transcripts/{new_filename}"
        })

        counter += 1

with open("assets/transcripts_list.json", "w", encoding="utf-8") as f:
    json.dump(episodes, f, ensure_ascii=False, indent=4)

print("تم تحويل كل الملفات إلى أسماء آمنة وإنشاء JSON بنجاح.")
