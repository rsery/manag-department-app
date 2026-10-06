import 'package:flutter/material.dart';

class SchoolDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> school;
  const SchoolDetailsScreen({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تفاصيل المدرسة")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildItem("رقم المدرسة", school['number'] ?? ''),
            buildItem("اسم المدرسة", school['name'] ?? ''),
            buildItem("العنوان", school['address'] ?? ''),
            buildItem("الهاتف", school['phone'] ?? ''),
            buildItem("الجنس", school['gender'] ?? ''),
            buildItem("الفترة", school['interval'] ?? ''),
            buildItem("المرحلة", school['stage'] ?? ''),
            buildItem("النوع", school['type'] ?? ''),
            buildItem("اسم المدير", school['managerName'] ?? ''),
            buildItem("الملاحظات", school['notes'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget buildItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }
}
