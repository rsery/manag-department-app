import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/myRequestWiatScreen.dart';
import 'package:manag_department_software_2/utils/user_role.dart';
import 'package:manag_department_software_2/screenes/employee/my_task_emplyee_Screen.dart';
import 'package:manag_department_software_2/screenes/principal/device_details_principal_screen.dart';
import 'package:manag_department_software_2/screenes/principal/new_request_principal_screen.dart';
import 'package:manag_department_software_2/screenes/widget/device_card.dart';
import 'package:manag_department_software_2/screenes/widget/request_card_widget.dart';
import 'package:manag_department_software_2/screenes/widget/stat_card_widget.dart';
import 'package:manag_department_software_2/screenes/widget/task_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

/// شاشة لوحة تحكم موحّدة لكل الأدوار (admin, employee, principal, secretary)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SharedData sharedData = SharedData.instance;

  Map<dynamic, dynamic>? get user => sharedData.currentUser;
  String get role => user?['role'] ?? '';

  List<Map<String, dynamic>> get requests => sharedData.requests;

  List<Map<String, dynamic>> get requestsPending =>
      requests.where((r) => r['status'] == 'معلقة').toList();

  List<Map<String, dynamic>> get myActiveTasks {
    final currentUsername = user?['username'];
    return requests.where((r) {
      final List participants = r['participants'] ?? [];
      return participants.any((p) => p['username'] == currentUsername) &&
          r['status'] == 'جارية';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 5),
                  _statsSection(),
                  const SizedBox(height: 5),
                  ..._bodySection(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header() {
    String title;
    String subtitle;

    switch (role) {
      case 'admin':
        title = "اهلا؛ ${user?['name']}";
        subtitle = "رئيس قسم الحاسوب";
        break;
      case 'secretary':
        title = "اهلا؛ ${user?['name'] ?? 'اسامة'}";
        subtitle = "سكرتير قسم الحاسوب";
        break;
      case 'employee':
        title = "اهلا؛ ${user?['name']}";
        subtitle = "${user?['roleStr'] ?? ''}";
        break;
      case 'principal':
        final school = sharedData.school;
        title = "${school?['name'] ?? ''}";
        subtitle = "مدير المدرسة/القسم";
        break;
      default:
        title = "اهلا؛ ${user?['name'] ?? ''}";
        subtitle = "";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(color: Color(0xff2845B8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _statsSection() {
    final stats = sharedData.dashboardStats;

    switch (role) {
      case 'admin':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: statCardWidget(
                      "${stats['schools'] ?? 0}",
                      "مدارس واقسام",
                      Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: statCardWidget(
                      "${stats['devices'] ?? 0}",
                      "اجهزة",
                      Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: statCardWidget(
                      "${stats['pendingRequests'] ?? 0}",
                      "طلبات القسم معلقة",
                      Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: statCardWidget(
                      "${stats['activeRequests'] ?? 0}",
                      "مهام القسم النشطة",
                      Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'secretary':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: statCardWidget(
                      "${stats['pendingRequests'] ?? 0}",
                      "معلقة",
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: statCardWidget(
                      "${stats['activeRequests'] ?? 0}",
                      "موزعة",
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: statCardWidget(
                  "${stats['completedRequests'] ?? 0}",
                  "مكتملة",
                  Colors.green,
                ),
              ),
            ],
          ),
        );

      case 'employee':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: statCardWidget(
                      "${stats['myTasks'] ?? 0}",
                      "كل المهام",
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: statCardWidget(
                      "${stats['myActiveTasksCount'] ?? 0}",
                      "نشطة",
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: statCardWidget(
                  "${stats['myCompletedTasksCount'] ?? 0}",
                  "مكتملة",
                  Colors.green,
                ),
              ),
            ],
          ),
        );

      case 'principal':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            children: [
              statCardWidget(
                "${stats['devicesInSchool'] ?? 0}",
                "الأجهزة",
                const Color(0xff2845B8),
              ),
              statCardWidget(
                "${stats['devicesInSchoolWorke'] ?? 0}",
                "تعمل",
                Colors.green,
              ),
              statCardWidget(
                "${stats['devicesInSchoolDamaged'] ?? 0}",
                "تالفة",
                Colors.red,
              ),
              statCardWidget(
                "${stats['requestsInSchool'] ?? 0}",
                "طلباتي",
                Colors.lightBlue,
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  // ================= BODY (list section) =================
  List<Widget> _bodySection(BuildContext context) {
    switch (role) {
      case 'admin':
        return [
          _sectionTitle("الطلبات تنتظر التوزيع"),
          requestsPending.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا يوجد طلبات بانتظار التوزيع'),
                )
              : _pendingRequestsList(
                  context,
                  onTapBuilder: (request, school) => MyRequestWiatScreen(
                    requestPending: request,
                    school: school,
                    userRole: UserRole.admin,
                  ),
                ),
        ];

      case 'secretary':
        return [
          _sectionTitle("الطلبات تنتظر التوزيع"),
          requestsPending.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا يوجد طلبات بانتظار التوزيع'),
                )
              : _pendingRequestsList(
                  context,
                  onTapBuilder: (request, school) => MyRequestWiatScreen(
                    requestPending: request,
                    school: school,
                    userRole: UserRole.secretary,
                  ),
                ),
        ];

      case 'employee':
        return [_sectionTitle("مهامي النشطة"), _myTasksList(context)];

      case 'principal':
        final school = sharedData.school;
        final devicesBySchool = sharedData.devicesBySchool(school?['number']);
        return [
          _principalRequestButton(context, school, devicesBySchool),
          const SizedBox(height: 10),
          _sectionTitle("أجهزة المدرسة"),
          _principalDevicesList(context, devicesBySchool),
        ];

      default:
        return [];
    }
  }

  // ---------- Shared pieces ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
        ),
      ),
    );
  }

  Widget _pendingRequestsList(
    BuildContext context, {
    required Widget Function(
      Map<String, dynamic> request,
      Map<String, dynamic> school,
    )
    onTapBuilder,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: requestsPending.length,
      itemBuilder: (context, index) {
        final request = requestsPending[index];
        final school = sharedData.schoolBySchoolNumber(
          '${request['schoolNumber']}',
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => onTapBuilder(request, school),
                ),
              );
            },
            child: requestCardWidget(
              request['status'] ?? 'قيد الانتظار',
              Colors.orange,
              request['requestNumber'] ?? '',
              request['description'] ?? '',
              request['devicNumber'] ?? '',
              school['name'] ?? '',
              request['date'] != null
                  ? SharedData.formatDate(request['date'])
                  : '',
              request['requestType'] ?? '',
            ),
          ),
        );
      },
    );
  }

  Widget _myTasksList(BuildContext context) {
    return ListView.builder(
      itemCount: myActiveTasks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final task = myActiveTasks[index];
        final school = sharedData.schoolBySchoolNumber(
          '${task['schoolNumber']}',
        );
        final taskComments = sharedData.taskCommentsByRequest(
          task['requestNumber'],
        );

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyTaskEmplyeeScreen(
                  requestNumber: task['requestNumber'],
                  school: school,
                ),
              ),
            );
          },
          child: taskCardWidget(
            '${task['status']}',
            _statusColor('${task['status']}'),
            '${task['priority']}',
            _priorityColor('${task['priority']}'),
            '${task['requestNumber']}',
            '${task['description']}',
            '${school['name']}',
            SharedData.formatDate(task['date']),
            taskComments.length,
            (task['participants'] as List? ?? []).length,
          ),
        );
      },
    );
  }

  Widget _principalRequestButton(
    BuildContext context,
    Map<String, dynamic>? school,
    List<Map<String, dynamic>> devicesBySchool,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2845B8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () {
            if (school == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (x) => NewRequestPrincipalScreen(
                  school: school,
                  device: devicesBySchool,
                ),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            "طلب خدمة جديد",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _principalDevicesList(
    BuildContext context,
    List<Map<String, dynamic>> devicesBySchool,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devicesBySchool.length,
      itemBuilder: (context, index) {
        final device = devicesBySchool[index];
        final statusColor = device['status'] == 'يعمل'
            ? Colors.green
            : device['status'] == 'صيانة'
            ? Colors.orange
            : Colors.red;

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (x) => DeviceDetailsPrincipalScreen(device: device),
            ),
          ),
          child: DeviceCard(
            status: "${device['status']}",
            statusColor: statusColor,
            code: "${device['id']}",
            type: "${device['type']}",
            model: "${device['model']}",
            school: '${device['schoolName']}',
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'عاجل':
      case 'عاجلة':
        return const Color(0xffFF6B6B);
      case 'مستعجلة':
        return const Color(0xffFFA726);
      case 'عادية':
        return const Color(0xff42A5F5);
      case 'مستقبلية':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
