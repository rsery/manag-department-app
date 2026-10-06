import 'package:flutter/material.dart';
import 'package:manag_department_software_2/layout/secretary_home_layout.dart';
import 'package:manag_department_software_2/layout/admin_home_layout.dart';
import 'package:manag_department_software_2/screenes/assignTaskScreen.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/utils/user_role.dart';

class MyRequestWiatScreen extends StatelessWidget {
  final Map<String, dynamic> requestPending;
  final Map<String, dynamic> school;
  final UserRole userRole;

  MyRequestWiatScreen({
    super.key,
    required this.requestPending,
    required this.school,
    required this.userRole,
  });

  final SharedData sharedData = SharedData.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDetailsCard(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // زر توزيع على موظف
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (x) => AssignTaskScreen(
                                requestPending: requestPending,
                                userRole: userRole,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'توزيع على الموظففين',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2947B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // زر رفض
                    requestPending['status'] != 'مرفوضة'
                        ? Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showRejectDialog(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xffFFF5F5),
                                side: const BorderSide(
                                  color: Color(0xffE8CACA),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text(
                                    'رفض',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "تأكيد رفض الطلب",
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: const Text(
          "هل أنت متأكد من رفض هذا الطلب؟",
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              sharedData.updateRequest(requestPending['requestNumber'], {
                'status': 'مرفوضة',
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (x) => _destinationLayout()),
              );
            },
            child: const Text("رفض", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// يحدد الصفحة الرئيسية المناسبة حسب دور المستخدم بعد الرفض.
  /// هذه الشاشة تُفتح عملياً من قبل السكرتير أو الأدمن فقط، لكن التعامل
  /// مع باقي القيم مُضاف للأمان واكتمال الـ switch.
  Widget _destinationLayout() {
    switch (userRole) {
      case UserRole.secretary:
        return const SecretaryHomeLayout(initialIndex: 2);
      case UserRole.admin:
        return const AdminHomeLayout(initialIndex: 2);
      case UserRole.employee:
      case UserRole.principal:
        return const AdminHomeLayout(initialIndex: 2);
    }
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
            '${requestPending['requestNumber']}',
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
              color: _statusColor('${requestPending['status']}'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${requestPending['status']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${requestPending['requestType']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(
            SharedData.formatDate(requestPending['date']),
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

          _detailRow('القسم/المدرسة', '${school['name']}'),
          _detailRow('المقدم', '${school['managerName']}'),
          _detailRow('الجهاز', '${requestPending['devicNumber']}'),

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
                  '${requestPending['description']}',
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
