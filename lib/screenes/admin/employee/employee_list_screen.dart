import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/employee/add_employee_screen.dart';
import 'package:manag_department_software_2/screenes/admin/employee/employee_details_screen.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/services/print_employee_achievements.dart';

enum EmployeeFilter { all, active, inactive }

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  EmployeeFilter _filter = EmployeeFilter.all;

  @override
  Widget build(BuildContext context) {
    final sharedData = SharedData.instance;

    final bool canAdd = sharedData.hasPermission('add_employee');
    final bool canEdit = sharedData.hasPermission('edit_employee');
    final bool canViewReports = sharedData.hasPermission('view_reports');

    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        // ✅ جلب الموظفين حسب الدور
        var employees = sharedData.users
            .where(
              (u) =>
                  u['role'] == 'employee' ||
                  u['role'] == 'admin' ||
                  u['role'] == 'secretary',
            )
            .toList();

        // ✅ تطبيق فلتر الحالة
        employees = employees.where((emp) {
          final bool isActive = emp['isActive'] != false;
          switch (_filter) {
            case EmployeeFilter.active:
              return isActive;
            case EmployeeFilter.inactive:
              return !isActive;
            case EmployeeFilter.all:
              return true;
          }
        }).toList();

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              "إدارة الموظفين",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (canViewReports)
                IconButton(
                  icon: const Icon(Icons.summarize_outlined),
                  tooltip: 'طباعة إنجازات جميع الموظفين',
                  onPressed: () => _showPrintAllDialog(context, employees),
                ),
            ],
          ),
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEmployeeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    "إضافة موظف",
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                )
              : null,

          body: Column(
            children: [
              // ✅ شريط الفلتر
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: "الكل",
                        selected: _filter == EmployeeFilter.all,
                        onTap: () =>
                            setState(() => _filter = EmployeeFilter.all),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: "فعّال فقط",
                        selected: _filter == EmployeeFilter.active,
                        selectedColor: Colors.green,
                        onTap: () =>
                            setState(() => _filter = EmployeeFilter.active),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: "غير فعّال",
                        selected: _filter == EmployeeFilter.inactive,
                        selectedColor: Colors.red,
                        onTap: () =>
                            setState(() => _filter = EmployeeFilter.inactive),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: employees.isEmpty
                    ? Center(
                        child: Text(
                          _filter == EmployeeFilter.all
                              ? 'لا يوجد موظفون'
                              : _filter == EmployeeFilter.active
                              ? 'لا يوجد موظفون فعّالون'
                              : 'لا يوجد موظفون غير فعّالين',
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          final bool isActive = emp['isActive'] != false;
                          final bool canToggleThis =
                              canEdit &&
                              emp['role'] != 'admin' &&
                              emp['role'] != 'secretary';

                          final trailingActions = <Widget>[
                            if (canEdit)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEmployeeScreen(employee: emp),
                                    ),
                                  );
                                },
                              ),
                            if (canToggleThis)
                              IconButton(
                                icon: Icon(
                                  isActive
                                      ? Icons.block
                                      : Icons.check_circle_outline,
                                  color: isActive ? Colors.red : Colors.green,
                                ),
                                tooltip: isActive ? "إلغاء تفعيل" : "تفعيل",
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
                                            ? "هل أنت متأكد من إلغاء تفعيل هذا الموظف؟ لن يتمكن من تسجيل الدخول."
                                            : "هل تريد إعادة تفعيل هذا الموظف؟",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text("إلغاء"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(
                                            isActive
                                                ? "إلغاء التفعيل"
                                                : "تفعيل",
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
                                      emp['id'],
                                      !isActive,
                                    );
                                  }
                                },
                              ),
                          ];

                          return Card(
                            color: isActive ? null : Colors.grey[200],
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EmployeeDetailsScreen(employee: emp),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: isActive
                                    ? Colors.blue[100]
                                    : Colors.grey[400],
                                child: Icon(
                                  Icons.person,
                                  color: isActive
                                      ? Colors.blue[800]
                                      : Colors.grey[700],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    emp['username'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isActive ? "فعّال" : "غير فعّال",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Cairo',
                                        color: isActive
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("الدور: ${emp['role'] ?? ''}"),
                                  Text(
                                    "اسم المستخدم: ${emp['username'] ?? ''}",
                                  ),
                                ],
                              ),
                              trailing: trailingActions.isEmpty
                                  ? null
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: trailingActions,
                                    ),
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

  Future<void> _showPrintAllDialog(
    BuildContext context,
    List<Map<String, dynamic>> employees,
  ) async {
    DateTime? fromDate;
    DateTime? toDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text(
                'طباعة تقرير الإنجازات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'من تاريخ',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    subtitle: Text(
                      fromDate == null
                          ? 'غير محدد'
                          : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => fromDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'إلى تاريخ',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    subtitle: Text(
                      toDate == null
                          ? 'غير محدد'
                          : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => toDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اتركهما فارغين لطباعة كل الفترات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    printAllEmployeesAchievements(
                      context,
                      employees,
                      fromDate: fromDate,
                      toDate: toDate,
                    );
                  },
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('طباعة'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ✅ ودجت مساعد لأزرار الفلتر
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor.withValues(alpha: 0.15) : Colors.white,
          border: Border.all(
            color: selected ? selectedColor : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? selectedColor : Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
