import 'package:flutter/material.dart';
import 'package:manag_department_software_2/services/print_employee_achievements.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> employee;
  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SharedData.instance,
      builder: (context, _) {
        final sharedData = SharedData.instance;

        // ✅ نجيب أحدث نسخة من بيانات الموظف من SharedData بدل النسخة الثابتة الممررة
        final current = sharedData.users.firstWhere(
          (u) => u['id'] == employee['id'],
          orElse: () => employee,
        );
        final achievements = sharedData.getEmployeeAchievements(
          current['username'] ?? '',
        );

        final bool isActive = current['isActive'] != false;
        final bool canEdit = sharedData.hasPermission('edit_employee');
        final bool canViewReports = sharedData.hasPermission('view_reports');
        final bool canToggle =
            canEdit &&
            current['role'] != 'admin' &&
            current['role'] != 'secretary';

        return Scaffold(
          appBar: AppBar(
            title: const Text("تفاصيل الموظف"),
            actions: [
              if (canViewReports)
                IconButton(
                  icon: const Icon(Icons.print_outlined),
                  tooltip: 'طباعة تقرير الإنجازات',
                  onPressed: achievements.isEmpty
                      ? null
                      : () => printEmployeeAchievements(
                          context,
                          current,
                          achievements,
                        ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // ✅ بطاقة الحالة
                Card(
                  color: isActive ? Colors.green[50] : Colors.red[50],
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      isActive ? Icons.check_circle : Icons.block,
                      color: isActive ? Colors.green[700] : Colors.red[700],
                    ),
                    title: Text(
                      isActive ? "الحساب فعّال" : "الحساب غير فعّال",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    subtitle: Text(
                      isActive
                          ? "يستطيع الموظف تسجيل الدخول"
                          : "لا يستطيع الموظف تسجيل الدخول حالياً",
                    ),
                    trailing: canToggle
                        ? TextButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    isActive
                                        ? "إلغاء تفعيل الموظف"
                                        : "تفعيل الموظف",
                                  ),
                                  content: Text(
                                    isActive
                                        ? "هل أنت متأكد من إلغاء تفعيل هذا الموظف؟"
                                        : "هل تريد إعادة تفعيل هذا الموظف؟",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("إلغاء"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        isActive ? "إلغاء التفعيل" : "تفعيل",
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await SharedData.instance.setUserActiveById(
                                  current['id'],
                                  !isActive,
                                );
                              }
                            },
                            child: Text(isActive ? "إلغاء التفعيل" : "تفعيل"),
                          )
                        : null,
                  ),
                ),

                buildItem("اسم الموظف", current['name'] ?? ''),
                buildItem("اسم المستخدم", current['username'] ?? ''),
                buildItem("كلمة المرور", current['password'] ?? ''),
                buildItem("الدور", current['role'] ?? ''),
                buildItem(
                  "الصلاحيات",
                  (current['permissions'] as List?)?.join('، ') ?? '',
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإنجازات (${achievements.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (canViewReports && achievements.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => printEmployeeAchievements(
                          context,
                          current,
                          achievements,
                        ),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('طباعة'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (achievements.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('لا يوجد إنجازات مسجلة')),
                    ),
                  )
                else
                  ...achievements.map((r) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(
                          '${r['requestNumber'] ?? ''} - ${r['description'] ?? ''}',
                        ),
                        subtitle: Text(
                          'النوع: ${r['requestType'] ?? ''}  |  الأولوية: ${r['priority'] ?? ''}',
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
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
