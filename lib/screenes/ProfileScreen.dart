import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/devices/device_type_list_screen.dart';
import 'package:manag_department_software_2/screenes/admin/employee/employee_list_screen.dart';
import 'package:manag_department_software_2/screenes/admin/school/school_list_screen.dart';
import 'package:manag_department_software_2/screenes/widget/logout_button_widget.dart';
import 'package:manag_department_software_2/screenes/widget/stat_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

/// شاشة بروفايل موحّدة لكل الأدوار (admin, employee, principal, secretary)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedData = SharedData.instance;

    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        final user = sharedData.currentUser;
        final stats = sharedData.dashboardStats;
        final role = user?['role'] ?? '';

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                _header(user, role, sharedData),
                const SizedBox(height: 18),
                _statsSection(role, stats),
                const SizedBox(height: 10),
                _menuSection(context, sharedData, role),
                const SizedBox(height: 22),
                logoutButtonWidget(context),
                const SizedBox(height: 40),
                const Text(
                  'قسم الحاسوب - مديرية التربية والتعليم - شرق غزة',
                  style: TextStyle(color: Color(0xff7A7F8C), fontSize: 10),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header(
    Map<dynamic, dynamic>? user,
    String role,
    SharedData sharedData,
  ) {
    String name;
    String jobTitle;
    String? extraLine;

    switch (role) {
      case 'principal':
        final school = sharedData.school;
        name = 'مدير ${school?['name'] ?? ''}';
        jobTitle = 'مدير مدرسة/قسم';
        extraLine = '${school?['managerName'] ?? ''}';
        break;
      case 'employee':
        name = '${user?['name'] ?? user?['username'] ?? ''}';
        jobTitle = '${user?['roleStr'] ?? ''}';
        extraLine = '${sharedData.school?['name'] ?? ''}';
        break;
      case 'admin':
      case 'secretary':
      default:
        name = '${user?['name'] ?? ''}';
        jobTitle = '${user?['roleStr'] ?? ''}';
        extraLine = null;
    }

    final avatarLetter = name.trim().isNotEmpty ? name.trim()[0] : 'م';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: const BoxDecoration(color: Color(0xff2947B8)),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            jobTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .85),
              fontSize: 14,
            ),
          ),
          if (extraLine != null && extraLine.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              extraLine,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .85),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _statsSection(String role, Map<String, dynamic> stats) {
    switch (role) {
      case 'principal':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: statCardWidget(
                  '${stats['devicesInSchool'] ?? 0}',
                  'اجهزة',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['requestsInSchool'] ?? 0}',
                  'طلباتي',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['getRequestsInSchoolDane'] ?? 0}',
                  'المنجزة',
                  Colors.blue,
                ),
              ),
            ],
          ),
        );

      case 'secretary':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: statCardWidget(
                  '${stats['pendingRequests'] ?? 0}',
                  'معلقة',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['activeRequests'] ?? 0}',
                  'موزعة',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['completedRequests'] ?? 0}',
                  'مكتملة',
                  Colors.green,
                ),
              ),
            ],
          ),
        );

      case 'admin':
      case 'employee':
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: statCardWidget(
                  '${stats['myTasksCount'] ?? 0}',
                  'مهامي',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['myActiveTasksCount'] ?? 0}',
                  role == 'admin' ? 'مهامي الجارية' : 'النشطة',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCardWidget(
                  '${stats['myCompletedTasksCount'] ?? 0}',
                  role == 'admin' ? 'مهامي المكتملة' : 'مكتملة',
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
    }
  }

  // ================= MENU (permission-gated) =================
  Widget _menuSection(
    BuildContext context,
    SharedData sharedData,
    String role,
  ) {
    // principal مفيهوش قوائم إدارية أصلاً
    if (role == 'principal') return const SizedBox();

    final canManageEmployees =
        sharedData.hasPermission('add_employee') ||
        sharedData.hasPermission('edit_employee') ||
        sharedData.hasPermission('delete_employee') ||
        sharedData.hasPermission('view_reports');

    final canManageSchools =
        sharedData.hasPermission('add_school') ||
        sharedData.hasPermission('edit_school') ||
        sharedData.hasPermission('delete_school');

    final canManageDeviceTypes = sharedData.hasPermission('add_device');

    final items = <Widget>[];

    if (canManageEmployees) {
      items.add(
        SettingsCard(
          title: 'إدارة الصلاحيات',
          subtitle: 'صلاحيات السكرتير والموظفين',
          icon: Icons.shield_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
            );
          },
        ),
      );
    }

    if (canManageSchools) {
      items.add(
        SettingsCard(
          title: 'إدارة المدارس والأقسام',
          subtitle: 'إضافة وتعديل وحذف',
          icon: Icons.home_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SchoolListScreen()),
            );
          },
        ),
      );
    }

    // "إضافة نوع جهاز" كانت أصلاً حصرية للأدمن فقط
    if (role == 'admin' && canManageDeviceTypes) {
      items.add(
        SettingsCard(
          title: 'إضافة نوع جهاز',
          subtitle: 'تسجيل جهاز في النظام',
          icon: Icons.monitor_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeviceTypeListScreen()),
            );
          },
        ),
      );
    }

    if (items.isEmpty) return const SizedBox();

    return Column(children: items);
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE3E7EF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left, size: 25, color: Color(0xff6B7A90)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff7D8797),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xffDCE7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xff2D52C5)),
            ),
          ],
        ),
      ),
    );
  }
}
