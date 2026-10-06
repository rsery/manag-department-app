import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/device_details_admin_screen.dart';
import 'package:manag_department_software_2/screenes/admin/devices/add_device_screen.dart';
import 'package:manag_department_software_2/screenes/widget/device_card.dart';
import 'package:manag_department_software_2/services/print_label.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:manag_department_software_2/services/printDevicesList.dart';

class DevicesAdminScreen extends StatefulWidget {
  const DevicesAdminScreen({super.key});

  @override
  State<DevicesAdminScreen> createState() => _DevicesAdminScreenState();
}

class _DevicesAdminScreenState extends State<DevicesAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';

  SharedData sharedData = SharedData.instance;

  bool get _canAdd => sharedData.hasPermission('add_device');
  bool get _canPrint => sharedData.hasPermission('print_device');

  List<String> get _filters => [
    'الكل',
    ...sharedData.schools.map((e) => e['name']),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDevices {
    final query = _searchController.text.trim().toLowerCase();

    return sharedData.devices.where((device) {
      final matchSearch =
          query.isEmpty ||
          device['number'].toString().toLowerCase().contains(query) ||
          device['type'].toString().toLowerCase().contains(query) ||
          device['id'].toString().toLowerCase().contains(query) ||
          device['serialNumber'].toString().toLowerCase().contains(query) ||
          device['brand'].toString().toLowerCase().contains(query) ||
          device['model'].toString().toLowerCase().contains(query) ||
          device['schoolName'].toString().toLowerCase().contains(query);

      final matchFilter =
          _selectedFilter == 'الكل' || device['schoolName'] == _selectedFilter;

      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF4F5F9),
          body: Column(
            children: [
              // ================= Header =================
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  right: 10,
                  left: 10,
                  bottom: 10,
                ),
                color: const Color(0xff2947B8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_canAdd) ...[
                              _headerIconButton(
                                icon: Icons.add,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (x) =>
                                          AddDeviceScreen(device: null),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (_canPrint) ...[
                              _headerIconButton(
                                icon: Icons.print_outlined,
                                onTap: _filteredDevices.isEmpty
                                    ? null
                                    : () => printDevicesList(_filteredDevices),
                              ),
                              const SizedBox(width: 6),
                              _headerIconButton(
                                icon: Icons.file_download_outlined,
                                onTap: _filteredDevices.isEmpty
                                    ? null
                                    : () => exportDevicesExcel(
                                        context,
                                        _filteredDevices,
                                      ),
                              ),
                              const SizedBox(width: 6),
                              _headerIconButton(
                                icon: Icons.local_offer_outlined,
                                onTap: _filteredDevices.isEmpty
                                    ? null
                                    : () => printDevicesLabels(
                                        context,
                                        _filteredDevices,
                                      ),
                              ),
                            ],
                          ],
                        ),

                        const Text(
                          'الأجهزة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ================= Search =================
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم، الرقم، الشركة...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: .6),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: .15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ================= Dropdown =================
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFilter,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _filters.map((school) {
                        return DropdownMenuItem(
                          value: school,
                          child: Text(school, textAlign: TextAlign.right),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // ================= Devices List =================
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredDevices.length,
                  itemBuilder: (context, int index) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (x) => DeviceDetailsAdminScreen(
                            deviceId: _filteredDevices[index]['id'],
                          ),
                        ),
                      );
                    },
                    child: DeviceCard(
                      status: "${_filteredDevices[index]['status']}",
                      statusColor: _status(
                        '${_filteredDevices[index]['status']}',
                      ),
                      code: "${_filteredDevices[index]['id']}",
                      type: "${_filteredDevices[index]['type']}",
                      model: "${_filteredDevices[index]['model']}",
                      school: '${_filteredDevices[index]['schoolName']}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _status(String status) {
    switch (status) {
      case 'يعمل':
        return Colors.green;
      case 'صيانة':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _headerIconButton({required IconData icon, VoidCallback? onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 22,
      ),
    );
  }
}
