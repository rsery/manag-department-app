import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/myRequestWiatScreen.dart';
import 'package:manag_department_software_2/screenes/secretary/my_task_secretary_screen.dart';
import 'package:manag_department_software_2/screenes/widget/build_tab_widget.dart';
import 'package:manag_department_software_2/screenes/widget/task_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/utils/user_role.dart';

class TaskSecretaryScreen extends StatefulWidget {
  const TaskSecretaryScreen({super.key});

  @override
  State<TaskSecretaryScreen> createState() => _TaskSecretaryScreenState();
}

class _TaskSecretaryScreenState extends State<TaskSecretaryScreen> {
  SharedData sharedData = SharedData.instance;

  String _selectedFilter = 'الكل';

  final List _filter1 = ['الكل', 'معلقة', 'جارية', 'مكتملة', 'مرفوضة'];

  List<Map<String, dynamic>> get _filteredRequests {
    return sharedData.requests.where((r) {
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
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filter1.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 2),
                        itemBuilder: (context, index) {
                          final filter = _filter1[index];
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
                                userRole: UserRole.secretary,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (x) => MyTaskSecretaryScreen(
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
