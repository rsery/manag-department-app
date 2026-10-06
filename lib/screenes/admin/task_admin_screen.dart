import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/my_task_admin_screen.dart';
import 'package:manag_department_software_2/screenes/myRequestWiatScreen.dart';

import 'package:manag_department_software_2/screenes/widget/task_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/utils/user_role.dart';

class TaskAdminScreen extends StatefulWidget {
  const TaskAdminScreen({super.key});

  @override
  State<TaskAdminScreen> createState() => _TaskAdminScreenState();
}

class _TaskAdminScreenState extends State<TaskAdminScreen> {
  SharedData sharedData = SharedData.instance;
  String _selectedFilter = 'الكل';
  final List _filter1 = ['الكل', 'معلقة', 'جارية', 'مكتملة', 'مرفوضة'];
  final List _filter2 = ['الكل', 'جارية', 'مكتملة'];

  bool filterByUser = false;
  late Map<dynamic, dynamic>? user = sharedData.currentUser;

  List<Map<String, dynamic>> get _filteredRequests {
    return sharedData.requests.where((r) {
      final List participants = r['participants'] ?? [];

      final bool isMyTask = participants.any(
        (u) => user?['id'] == u['id'],
      ); // عدّل حسب شكل user id

      // ===== 1. فلترة "مهامي"
      if (filterByUser) {
        final bool matchUser = isMyTask;

        final bool matchStatus =
            _selectedFilter == 'الكل' || r['status'] == _selectedFilter;

        return matchUser && matchStatus;
      }

      // ===== 2. فلترة عامة (كل / معلقة / جارية ...)
      final bool matchStatus =
          _selectedFilter == 'الكل' || r['status'] == _selectedFilter;

      return matchStatus;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'المهام',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 40,
                      //  فلتر 1
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filter1.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 2),
                        itemBuilder: (context, index) {
                          final filter = _filter1[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                filterByUser = false;
                                _selectedFilter = filter;
                              });
                            },
                            child: buildTab(
                              title: filter,
                              isSelected:
                                  !filterByUser && filter == _selectedFilter,
                            ),
                          );
                        },
                      ),
                    ),
                    // فلتر 2
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filter2.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 2),
                        itemBuilder: (context, index) {
                          final filter = _filter2[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                filterByUser = true;
                                _selectedFilter = filter;
                              });
                            },
                            child: buildTab(
                              title: filter == 'الكل' ? 'مهامي' : filter,
                              isSelected:
                                  filterByUser && filter == _selectedFilter,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRequests.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final request = _filteredRequests[index];
                    final taskComments = sharedData.taskCommentsByRequest(
                      request['requestNumber'],
                    );
                    Map<String, dynamic> school = sharedData
                        .schoolBySchoolNumber('${request['schoolNumber']}');
                    return InkWell(
                      onTap: () {
                        if (request['status'] == 'معلقة' ||
                            request['status'] == 'مرفوضة') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyRequestWiatScreen(
                                requestPending: request,
                                school: school,
                                userRole: UserRole.admin,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (x) => MyTaskAdminScreen(
                                requestNumber: request['requestNumber'],
                                taskComments: taskComments,
                                school: school,
                              ),
                            ),
                          );
                        }
                      },
                      child: taskCardWidget(
                        '${request['status']}',
                        getStatusColor(
                          school['status'] ?? '${request['status']}',
                        ),
                        '${request['priority']}',
                        getPriorityColor(request['priority']),
                        '${request['requestNumber']}',
                        '${request['description']}',
                        '${school['name']}',

                        SharedData.formatDate(request['date']),
                        taskComments.length,
                        request['participants'].length,
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

  Widget buildTab({required String title, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: .25) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
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
