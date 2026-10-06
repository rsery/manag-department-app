import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class MyTaskEmplyeeScreen extends StatelessWidget {
  final String requestNumber;
  final Map school;
  MyTaskEmplyeeScreen({
    super.key,
    required this.requestNumber,
    required this.school,
  });

  final TextEditingController noteController = TextEditingController();
  final SharedData sharedData = SharedData.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        final request = sharedData.requests.firstWhere(
          (r) => r['requestNumber'] == requestNumber,
          orElse: () => {},
        );
        final taskComments = sharedData.taskCommentsByRequest(requestNumber);
        final userData = sharedData.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xffF3F5F9),
          appBar: AppBar(
            title: const Text("تفاصيل المهمة"),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                // ===== Header =====
                Container(
                  width: double.infinity,
                  color: const Color(0xff2342B4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${school['name']}", // ✅ تصحيح
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _statusChip(
                            "${request['status']}",
                            getStatusColor("${request['status']}"),
                          ),
                          const SizedBox(width: 5),
                          _statusChip(
                            "${request['priority']}",
                            getPriorityColor("${request['priority']}"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        SharedData.formatDate(request['date']),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      (request['status'] == 'مكتملة')
                          ? Text(
                              "مكتملة: ${SharedData.formatDate(request['expiryDate'])}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),

                // ===== Request Details =====
                _sectionTitle("تفاصيل الطلب"),
                _infoCard(
                  children: [
                    _InfoRow(
                      title: "رقم الطلب",
                      value: "${request['requestNumber']}",
                    ),
                    _InfoRow(
                      title: "نوع الطلب",
                      value: "${request['requestType']}",
                    ),
                    _InfoRow(
                      title: "المدرسة/القسم",
                      value: "${school['name']}",
                    ),
                    request['requestType'] == 'فنية'
                        ? _InfoRow(
                            title: "الجهاز المعطل",
                            value: "${request['devicNumber']}",
                          )
                        : const SizedBox(),
                  ],
                  description: "${request['description']}",
                ),

                const SizedBox(height: 10),

                // ===== Employees =====
                _sectionTitle(
                  "الموظفون المعينون (${request['participants'].length})",
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: request['participants'].length,
                  itemBuilder: (context, index) {
                    List participants = request['participants'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          EmployeeCard(
                            name: "${participants[index]['username']}",
                            role: "${participants[index]['role']}",
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );
                  },
                ),

                // ===== Notes =====
                _sectionTitle("الملاحظات (${taskComments.length})"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskComments.length,
                    itemBuilder: (context, index) {
                      Map taskComment = taskComments[index];
                      return NoteCard(
                        name: "${taskComment['employeeId']}",
                        date: SharedData.formatDate(taskComment['createdAt']),
                        note: "${taskComment['comment']}",
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ===== Add Note =====
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "إضافة ملاحظة",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        maxLines: 4,
                        controller: noteController,
                        decoration: InputDecoration(
                          hintText: "اكتب ملاحظتك هنا...",
                          filled: true,
                          fillColor: const Color(0xffEEF1F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (noteController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجي ادخال الملاحظة'),
                                ),
                              );
                            } else {
                              sharedData.addTaskComments(
                                requestsNumber: request['requestNumber'],
                                employeeId: userData?['username'] ?? '',
                                comment: noteController.text,
                              );
                              noteController.clear(); // ✅ إضافة مفيدة
                            }
                          },
                          child: const Text("حفظ الملاحظة"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // باقي الدوال المساعدة (_statusChip, _sectionTitle, _infoCard, getStatusColor, getPriorityColor) كما هي
  static Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static Widget _infoCard({
    required List<Widget> children,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ...children,
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffEEF1F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'معلقة':
        return Colors.orange;
      case 'جارية':
        return Colors.blue;
      case 'مكتملة':
        return Colors.green;
      case 'مرفوضة':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'عاجل':
      case 'عاجلة':
        return const Color(0xffFF6B6B); // أحمر
      case 'مستعجلة':
        return const Color(0xffFFA726); // برتقالي
      case 'عادية':
        return const Color(0xff42A5F5); // أزرق
      case 'مستقبلية':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;

  const EmployeeCard({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
        subtitle: Text(role),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String name;
  final String date;
  final String note;

  const NoteCard({
    super.key,
    required this.name,
    required this.date,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Text("أ")),
              const Spacer(),
              Text(name),
              const SizedBox(width: 10),
              Text(date),
            ],
          ),
          const SizedBox(height: 20),
          Text(note, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
