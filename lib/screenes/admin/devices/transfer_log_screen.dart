import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class TransferLogScreen extends StatefulWidget {
  final String deviceId;
  const TransferLogScreen({super.key, required this.deviceId});

  @override
  State<TransferLogScreen> createState() => _TransferLogScreenState();
}

class _TransferLogScreenState extends State<TransferLogScreen> {
  final sharedData = SharedData.instance;

  String formatDate(dynamic value) {
    DateTime? date;
    if (value is Timestamp) date = value.toDate();
    if (value is DateTime) date = value;
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd  HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        final device = sharedData.devices.firstWhere(
          (d) => d['id'] == widget.deviceId,
          orElse: () => {},
        );

        if (device.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(body: SizedBox());
        }

        final logs = sharedData.getTransferLogByDevice(device['id']);

        return Scaffold(
          backgroundColor: const Color(0xffF4F5F7),
          appBar: AppBar(
            title: const Text('سجل نقل الجهاز'),
            centerTitle: true,
            actions: [
              if (sharedData.hasPermission('print_device'))
                IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'تصدير إكسل',
                  onPressed: logs.isEmpty ? null : () => _exportExcel(logs),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.laptop, color: Color(0xff233EAF)),
                    const SizedBox(width: 8),
                    Text(
                      '${device['brand']} - ${device['model']} (${device['id']})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'لا يوجد سجل نقل لهذا الجهاز',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ...logs.map((log) => _logCard(log)),
            ],
          ),
          floatingActionButton: sharedData.hasPermission('transfer_device')
              ? FloatingActionButton.extended(
                  backgroundColor: const Color(0xff233EAF),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('إضافة نقل'),
                  onPressed: () => _showAddTransferDialog(context, device),
                )
              : null,
        );
      },
    );
  }

  Widget _logCard(Map log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${log['fromSchoolName'] ?? ''}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Color(0xff233EAF),
              ),
              Expanded(
                child: Text(
                  '${log['toSchoolName'] ?? ''}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatDate(log['date']),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          if ((log['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'ملاحظة: ${log['note']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'بواسطة: ${log['byUser'] ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showAddTransferDialog(BuildContext context, Map device) {
    String? toSchoolNumber;
    final noteController = TextEditingController();
    final currentSchoolNumber = device['schoolNumber']?.toString() ?? '';
    final currentSchool = sharedData.schoolBySchoolNumber(currentSchoolNumber);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('نقل الجهاز إلى مدرسة أخرى'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('من: ${currentSchool['name'] ?? 'غير معروف'}'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'إلى مدرسة'),
                      initialValue: toSchoolNumber,
                      items: sharedData.schools
                          .where(
                            (s) =>
                                s['number'].toString() != currentSchoolNumber,
                          )
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s['number'].toString(),
                              child: Text(s['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setStateDialog(() => toSchoolNumber = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظة (اختياري)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (toSchoolNumber == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('اختر مدرسة الوجهة')),
                      );
                      return;
                    }
                    final toSchool = sharedData.schoolBySchoolNumber(
                      toSchoolNumber!,
                    );
                    await sharedData.addTransfer(
                      deviceId: device['id'],
                      fromSchoolNumber: currentSchoolNumber,
                      fromSchoolName: currentSchool['name'] ?? '',
                      toSchoolNumber: toSchoolNumber!,
                      toSchoolName: toSchool['name'] ?? '',
                      byUser: sharedData.currentUser?['name'] ?? '',
                      note: noteController.text,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    // مفيش داعي لـ setState هنا خالص —
                    // AnimatedBuilder هيعيد البناء لوحده لما Firestore يرجع البيانات
                  },
                  child: const Text('تأكيد النقل'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportExcel(List<Map<String, dynamic>> logs) async {
    // نفس الكود كما هو، لكن استبدل widget.device['id'] بـ widget.deviceId
    final excel = ex.Excel.createExcel();
    final sheet = excel['سجل النقل'];

    sheet.appendRow([
      ex.TextCellValue('من'),
      ex.TextCellValue('إلى'),
      ex.TextCellValue('التاريخ'),
      ex.TextCellValue('بواسطة'),
      ex.TextCellValue('ملاحظة'),
    ]);

    for (final log in logs) {
      sheet.appendRow([
        ex.TextCellValue('${log['fromSchoolName'] ?? ''}'),
        ex.TextCellValue('${log['toSchoolName'] ?? ''}'),
        ex.TextCellValue(formatDate(log['date'])),
        ex.TextCellValue('${log['byUser'] ?? ''}'),
        ex.TextCellValue('${log['note'] ?? ''}'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/transfer_log_${widget.deviceId}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حفظ الملف: $path')));
    }
    await OpenFile.open(path);
  }
}
