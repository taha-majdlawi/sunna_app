import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, String>> allNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNotes();
  }

  Future<void> _loadAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<Map<String, String>> tempNotes = [];

    for (String key in keys) {
      // نحن نستخدم مفتاح note_ في شاشة التفاصيل
      if (key.startsWith('note_')) {
        String? noteValue = prefs.getString(key);
        if (noteValue != null && noteValue.trim().isNotEmpty) {
          tempNotes.add({
            'key': key,
            'content': noteValue,
          });
        }
      }
    }

    setState(() {
      allNotes = tempNotes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ملاحظاتي الشخصية"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allNotes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: colors.primary.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          allNotes[index]['content']!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.right,
                        ),
                        leading: Icon(Icons.edit_note, color: colors.primary),
                        // إضافة زر حذف للملاحظة إذا أراد المستخدم
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove(allNotes[index]['key']!);
                            _loadAllNotes(); // إعادة التحميل
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "لا توجد ملاحظات محفوظة حالياً.\nيمكنك إضافة ملاحظاتك من داخل الدروس.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}