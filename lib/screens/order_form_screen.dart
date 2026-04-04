import 'package:flutter/material.dart';

class OrderFormScreen extends StatefulWidget {
  final String bookTitle;
  const OrderFormScreen({Key? key, required this.bookTitle}) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("طلب: ${widget.bookTitle}")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("يرجى إدخال بياناتك لتوصيل الكتاب إليك", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 25),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "الاسم الكامل", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "رقم الهاتف", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "العنوان بالتفصيل", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // هنا يمكنك إرسال البيانات إلى WhatsApp أو Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم استلام طلبك بنجاح، سنتواصل معك قريباً")),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("تأكيد الطلب الآن"),
            ),
          ],
        ),
      ),
    );
  }
}