import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class MyRequestPrincipalScreen extends StatelessWidget {
  final Map<String, dynamic> request;
  final Map<String, dynamic> school;
  MyRequestPrincipalScreen({
    super.key,
    required this.request,
    required this.school,
  });
  final SharedData sharedData = SharedData.instance;

  List<Map<String, dynamic>> get taskComments =>
      sharedData.taskCommentsByRequest(request['requestNumber']) ?? [];

  late final List<Map<String, dynamic>> participants =
      (request['participants'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDetailsCard(),

              const SizedBox(height: 8),

              // _buildEmployeesSection(employees),
              _sectionTitle("الموظفون المعينون (${participants.length})"),
              if (participants.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("لا يوجد موظفون معينون"),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          EmployeeCard(
                            name: "${participants[index]['username']}",
                            role: "${participants[index]['role']}",
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 8),

              // _buildNotesSection(notes),
              _sectionTitle("الملاحظات (${taskComments.length})"),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: taskComments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("لا توجد ملاحظات"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskComments.length,
                        itemBuilder: (contex, index) {
                          final Map<String, dynamic> taskComment =
                              taskComments[index];
                          return NoteCard(
                            name: "${taskComment['employeeId']}",
                            date: SharedData.formatDate(
                              taskComment['createdAt'],
                            ),
                            note: "${taskComment['comment']}",
                          );
                        },
                      ),
              ),
            ],

            // distributionEmpleyeesWidget(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const SizedBox(width: 4),
          const Text(
            'تفاصيل الطلب',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(color: Color(0xff233EAF)),
      child: Column(
        children: [
          Text(
            '${request['requestNumber']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor('${request['status']}'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${request['status']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'خدمة ${request['requestType']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(
            SharedData.formatDate(request['date']),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل الطلب',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _detailRow('رقم الطلب', '${request['requestNumber']}'),
          _detailRow('القسم/المدرسة', '${school['number']}'),
          _detailRow('نوع الطلب', '${request['requestType']}'),
          request['requestType'] == 'فنية'
              ? _detailRow('الجهاز المعطل', '${request['devicNumber']}')
              : SizedBox(),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوصف',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request['description']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'معلقة':
        return Colors.orange;
      case 'جارية':
        return const Color(0xff233EAF);
      case 'مكتملة':
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}

class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;

  const EmployeeCard({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xff233EAF),
          child: Text(name[0], style: const TextStyle(color: Colors.white)),
        ),
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
              CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '')),
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
