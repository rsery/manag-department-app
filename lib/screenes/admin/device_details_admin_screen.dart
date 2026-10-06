import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/devices/add_device_screen.dart';
import 'package:manag_department_software_2/screenes/admin/devices/transfer_log_screen.dart';
import 'package:manag_department_software_2/screenes/admin/my_task_admin_screen.dart';
import 'package:manag_department_software_2/screenes/myRequestWiatScreen.dart';
import 'package:manag_department_software_2/screenes/widget/task_card_widget.dart';
import 'package:manag_department_software_2/services/print_label.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/utils/user_role.dart';

class DeviceDetailsAdminScreen extends StatelessWidget {
  final String deviceId;
  const DeviceDetailsAdminScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final sharedData = SharedData.instance;

    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        final device = sharedData.devices.firstWhere(
          (d) => d['id'] == deviceId,
          orElse: () => {},
        );

        if (device.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(body: SizedBox());
        }

        final requests = sharedData.getRequestsInDevice(device['id']);
        final school = sharedData.schoolBySchoolNumber(device['schoolNumber']);

        return Scaffold(
          backgroundColor: const Color(0xffF4F5F7),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _appBar(context),
                  _header(device),
                  const SizedBox(height: 8),
                  _actions(context, sharedData, device),
                  const SizedBox(height: 12),
                  _details(device),
                  const SizedBox(height: 12),
                  DeviceStatusSelector(device: device),
                  const SizedBox(height: 10),
                  _requests(context, sharedData, requests, school),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= APP BAR =================
  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          const SizedBox(width: 4),
          const Text(
            'تفاصيل الجهاز',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(Map<String, dynamic> device) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: const Color(0xff233EAF),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.laptop, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 8),
          Text(
            device['brand'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            device['model'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _status(device),
        ],
      ),
    );
  }

  Widget _status(Map<String, dynamic> device) {
    Color c;
    switch (device['status']) {
      case 'يعمل':
        c = Colors.green;
        break;
      case 'صيانة':
        c = Colors.orange;
        break;
      default:
        c = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        device['status'] ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  // ================= ACTIONS =================
  Widget _actions(
    BuildContext context,
    SharedData sharedData,
    Map<String, dynamic> device,
  ) {
    final canTransfer = sharedData.hasPermission('transfer_device');
    final canPrint = sharedData.hasPermission('print_device');
    final canEdit = sharedData.hasPermission('edit_device');
    final canDelete = sharedData.hasPermission('delete_device');

    // لو مفيش صلاحية واحدة على الأقل، منعرضش الصف خالص
    final hasAnyAction = canTransfer || canPrint || canEdit || canDelete;
    if (!hasAnyAction) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (canTransfer || canPrint)
            Row(
              children: [
                if (canTransfer)
                  Expanded(
                    child: _btn(
                      Icons.receipt_long_outlined,
                      'سجل نقل الجهاز',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransferLogScreen(deviceId: device['id']),
                          ),
                        );
                      },
                    ),
                  ),
                if (canTransfer && canPrint) const SizedBox(width: 8),
                if (canPrint)
                  Expanded(
                    child: _btn(
                      Icons.local_offer_outlined,
                      'طباعة لاصق',
                      () {
                        printDeviceLabel(context, device);
                      },
                      color: device['toPrint'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ],
            ),
          if (canTransfer || canPrint) const SizedBox(height: 8),
          if (canEdit || canDelete)
            Row(
              children: [
                if (canEdit)
                  Expanded(
                    child: _btn(Icons.edit_outlined, 'تعديل بينات الجهاز', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddDeviceScreen(device: device),
                        ),
                      );
                    }),
                  ),
                if (canEdit && canDelete) const SizedBox(width: 8),
                if (canDelete)
                  Expanded(
                    child: _btn(Icons.delete_outline, 'خذف الجهاز', () {
                      _confirmDelete(context, device);
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    final c = color ?? const Color(0xff233EAF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: c),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 12, color: c)),
          ],
        ),
      ),
    );
  }

  // ================= DETAILS =================
  Widget _details(Map<String, dynamic> device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل الجهاز',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _row('رقم', device['id'] ?? ''),
          _row('شركة', device['brand'] ?? ''),
          _row('موديل', device['model'] ?? ''),
          _row('سيريال', device['serialNumber'] ?? ''),
          _row('المواصفات', device['specs'] ?? ''),
          _row('قسم/مدرسة', device['schoolName'] ?? ''),
          _row('الموقع', device['location'] ?? ''),
          _row('تاريخ الشراء', formatDate(device['purchaseDate'])),
          _row('حالة الجهاز عند الادخال ', formatDate(device['statusIn'])),
          _row('المشروع', formatDate(device['project'])),
          _row('مضيف الجهاز', device['nameIn'] ?? ''),
        ],
      ),
    );
  }

  Widget _row(String t, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ================= REQUESTS =================
  Widget _requests(
    context,
    SharedData sharedData,
    List requests,
    Map<String, dynamic> school,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            'الطلبات (${requests.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (requests.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('لا يوجد طلبات', style: TextStyle(fontSize: 12)),
              ),
            ),
          ...requests.map((request) {
            List taskComments = sharedData.taskCommentsByRequest(
              request['requestNumber'],
            );
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
                Colors.blue,
                '${request['priority']}',
                Color(0xffFF6B6B),
                '${request['requestNumber']}',
                '${request['description']}',
                '${school['name']}',
                '${request['data']}',
                taskComments.length,
                (request['participants'] as List? ?? []).length,
              ),
            );
          }),
        ],
      ),
    );
  }

  String formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return value?.toString() ?? '';
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا الجهاز؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SharedData.instance.deleteDevice(device['id']);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class DeviceStatusSelector extends StatefulWidget {
  final Map device;
  const DeviceStatusSelector({super.key, required this.device});

  @override
  State<DeviceStatusSelector> createState() => _DeviceStatusSelectorState();
}

class _DeviceStatusSelectorState extends State<DeviceStatusSelector> {
  late Map<dynamic, dynamic> device = widget.device;
  late String selectedStatus = device['status'];
  late String deviceId = device['id'];

  final List<String> statuses = ['تالف', 'صيانة', 'يعمل'];
  SharedData sharedData = SharedData.instance;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    // ✅ تغيير الحالة نفسه يعتبر تعديل على الجهاز
    if (!sharedData.hasPermission('edit_device')) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'تغيير الحالة',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        isloading
            ? CircularProgressIndicator()
            : Row(
                children: statuses.map((status) {
                  final isSelected = selectedStatus == status;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            selectedStatus = status;
                            isloading = true;
                          });
                          await sharedData.updateDevice(deviceId, {
                            'status': selectedStatus,
                          });
                          setState(() {
                            isloading = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2948B8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
