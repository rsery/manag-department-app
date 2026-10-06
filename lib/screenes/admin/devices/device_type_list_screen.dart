import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class DeviceTypeListScreen extends StatefulWidget {
  const DeviceTypeListScreen({super.key});

  @override
  State<DeviceTypeListScreen> createState() => _DeviceTypeListScreenState();
}

class _DeviceTypeListScreenState extends State<DeviceTypeListScreen> {
  final SharedData sharedData = SharedData.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        final types = sharedData.deviceTypes;

        return Scaffold(
          backgroundColor: const Color(0xffF4F5F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'أنواع الأجهزة',
              style: TextStyle(color: Colors.black),
            ),
            leading: const BackButton(color: Colors.black),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff2947B8),
            onPressed: () => _showTypeDialog(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: types.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد أنواع أجهزة مضافة',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: types.length,
                  itemBuilder: (context, index) {
                    final type = types[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDelete(context, type),
                          ),
                          const Spacer(),
                          Text(
                            '${type['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> type) {
    final inUse = sharedData.isDeviceTypeInUse(type['name']);

    if (inUse) {
      // ✅ منع الحذف تماماً لو النوع مستخدم
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('لا يمكن الحذف'),
          content: Text(
            'لا يمكن حذف "${type['name']}" لأنه مستخدم حالياً في جهاز واحد أو أكثر.\n'
            'يرجى تغيير نوع الأجهزة المرتبطة أولاً ثم إعادة المحاولة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    // النوع غير مستخدم -> تأكيد الحذف العادي
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف نوع الجهاز'),
        content: Text('هل أنت متأكد من حذف "${type['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              sharedData.deleteDeviceType(type['id']);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTypeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إضافة نوع جهاز'),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'اسم نوع الجهاز (مثال: laptop)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              // تحقق من عدم التكرار
              final exists = sharedData.deviceTypes.any(
                (t) => t['name'] == name,
              );
              if (exists) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('هذا النوع موجود مسبقاً')),
                );
                return;
              }

              try {
                await sharedData.addDeviceType(name: name);
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء الإضافة: $e')),
                  );
                }
                return;
              }

              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2947B8),
            ),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
