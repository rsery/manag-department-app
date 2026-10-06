import 'package:flutter/material.dart';
import 'package:manag_department_software_2/layout/secretary_home_layout.dart';
import 'package:manag_department_software_2/layout/admin_home_layout.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/utils/user_role.dart';

class AssignTaskScreen extends StatefulWidget {
  final Map<String, dynamic> requestPending;
  final UserRole userRole;

  const AssignTaskScreen({
    super.key,
    required this.requestPending,
    required this.userRole,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  SharedData sharedData = SharedData.instance;
  late String selectedPriority;

  late final List<Map<String, dynamic>> employees = sharedData
      .getEmployeesAndAdmin();

  late List<Map<String, dynamic>> participants;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    selectedPriority = widget.requestPending['priority'] ?? 'عادية';

    widget.requestPending.putIfAbsent(
      'participants',
      () => <Map<String, dynamic>>[],
    );

    participants = List<Map<String, dynamic>>.from(
      widget.requestPending['participants'] ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'توزيع المهمة',
          style: TextStyle(color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: const Color(0xff2947B8),
              child: Column(
                children: [
                  const Text(
                    'توزيع المهمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.requestPending['requestNumber']} • ${widget.requestPending['requestType']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('وصف الطلب', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '${widget.requestPending['description']}',
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'الأولوية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  _priorityCard(title: 'عاجل', subtitle: 'يجب تنفيذها فوراً'),

                  _priorityCard(
                    title: 'عادية',
                    subtitle: 'تنفذها في الوقت المعتاد',
                  ),

                  _priorityCard(title: 'مستقبلية', subtitle: 'يمكن تأجيلها'),

                  const SizedBox(height: 10),

                  Text(
                    'الموظفون (${(participants).length} محدد)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  ...employees.map((employee) => _employeeCard(employee)),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _onSubmit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2947B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'توزيع المهمة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار موظف واحد على الأقل')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await sharedData.updateRequest(widget.requestPending['requestNumber'], {
        'priority': selectedPriority,
        'participants': participants,
        'status': 'جارية',
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => _destinationLayout()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل حفظ المهمة: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// يحدد الصفحة الرئيسية المناسبة حسب دور المستخدم بعد نجاح التوزيع.
  /// هذه الشاشة تُفتح عملياً من قبل السكرتير أو الأدمن فقط، لكن التعامل
  /// مع باقي القيم مُضاف للأمان واكتمال الـ switch.
  Widget _destinationLayout() {
    switch (widget.userRole) {
      case UserRole.secretary:
        return const SecretaryHomeLayout(initialIndex: 2);
      case UserRole.admin:
        return const AdminHomeLayout();
      case UserRole.employee:
      case UserRole.principal:
        return const AdminHomeLayout();
    }
  }

  Widget _priorityCard({required String title, required String subtitle}) {
    bool selected = selectedPriority == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffF2F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xff2947B8) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedPriority,
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _employeeCard(Map<String, dynamic> employee) {
    final displayName = employee['username'] ?? employee['name'] ?? '؟';
    final displayRole = employee['role'] ?? employee['job'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Checkbox(
            value: participants.any(
              (user) => user['username'] == employee['username'],
            ),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  final exists = participants.any(
                    (user) => user['username'] == employee['username'],
                  );
                  if (!exists) {
                    participants.add(employee);
                  }
                } else {
                  participants.removeWhere(
                    (user) => user['username'] == employee['username'],
                  );
                }
              });
            },
          ),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(displayName.isNotEmpty ? displayName[0] : '؟'),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayName, style: const TextStyle(fontSize: 18)),
              Text(displayRole, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}
