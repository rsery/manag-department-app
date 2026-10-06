import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class DeviceDetailsPrincipalScreen extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceDetailsPrincipalScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    SharedData sharedData = SharedData.instance;

    final requests = sharedData.getRequestsInDevice(device['id']);
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appBar(context),
              _header(),

              const SizedBox(height: 12),
              _details(),
              const SizedBox(height: 10),
              _requests(requests),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
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
  Widget _header() {
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
          ),
          const SizedBox(height: 8),
          Text(
            '${device['id']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${device['type']}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _status(),
        ],
      ),
    );
  }

  Widget _status() {
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
        '${device['status'] ?? '-'}',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _btn(IconData icon, String text) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xff233EAF)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ================= DETAILS =================
  Widget _details() {
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

          _row('رقم', device['id']),
          _row('شركة', device['brand']),
          _row('موديل', device['model']),
          _row('سيريال', device['serialNumber']),
          _row('قسم/مدرسة', device['schoolName']),
          _row('تاريخ', SharedData.formatDate(device['purchaseDate'])),
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
          Text(v, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ================= REQUESTS =================
  Widget _requests(List requests) {
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

          ...requests.map(
            (r) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${r['requestNumber'] ?? '-'}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${r['description'] ?? '-'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    SharedData.formatDate(r['date']),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
