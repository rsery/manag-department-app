import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/employee/my_task_emplyee_Screen.dart';
import 'package:manag_department_software_2/screenes/widget/build_tab_widget.dart';
import 'package:manag_department_software_2/screenes/widget/task_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class TaskEmplyeeScreen extends StatefulWidget {
  const TaskEmplyeeScreen({super.key});

  @override
  State<TaskEmplyeeScreen> createState() => _TaskEmplyeeScreenState();
}

class _TaskEmplyeeScreenState extends State<TaskEmplyeeScreen> {
  SharedData sharedData = SharedData.instance;
  Map<dynamic, dynamic>? get user => sharedData.currentUser;
  String _selectedFilter = 'الكل';

  final List _filter = ['الكل', 'جارية', 'مكتملة'];

  List<Map<String, dynamic>> get _filteredRequests {
    return sharedData.requests.where((r) {
      final List participants = r['participants'] ?? [];

      final bool isMyTask = participants.any(
        (u) => user?['username'] == u['username'],
      ); // عدّل حسب شكل user id

      final bool matchStatus =
          _selectedFilter == 'الكل' || r['status'] == _selectedFilter;

      return isMyTask && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              // ================= Header =================
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  right: 15,
                  left: 15,
                  bottom: 10,
                ),
                decoration: const BoxDecoration(color: Color(0xff2947B8)),
                child: Column(
                  children: [
                    const Text(
                      'المهام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filter.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 2),
                        itemBuilder: (context, index) {
                          final filter = _filter[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: buildTab(
                              title: filter,
                              isSelected: filter == _selectedFilter,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= Requests List =================
              Expanded(
                child: _filteredRequests.isEmpty
                    ? Center(
                        child: Text(
                          user == null
                              ? 'جاري تحميل بيانات المستخدم...'
                              : 'لا توجد مهام مطابقة',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _filteredRequests.length,
                        itemBuilder: (BuildContext context, int index) {
                          final task = _filteredRequests[index];
                          Map<String, dynamic> school = sharedData
                              .schoolBySchoolNumber('${task['schoolNumber']}');
                          final taskComments = sharedData.taskCommentsByRequest(
                            task['requestNumber'],
                          );
                          final List taskParticipants =
                              task['participants'] ?? [];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (x) => MyTaskEmplyeeScreen(
                                    requestNumber: task['requestNumber'],

                                    school: school,
                                  ),
                                ),
                              );
                            },
                            child: taskCardWidget(
                              '${task['status']}',
                              getStatusColor('${task['status']}'),
                              '${task['priority']}',
                              getPriorityColor('${task['priority']}'),
                              '${task['requestNumber']}',
                              '${task['description']}',
                              '${school['name']}',

                              SharedData.formatDate(task['date']),
                              taskComments.length,
                              taskParticipants.length,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
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
