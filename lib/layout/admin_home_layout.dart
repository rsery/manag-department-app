import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/DashboardScreen.dart';
import 'package:manag_department_software_2/screenes/ProfileScreen.dart';
import 'package:manag_department_software_2/screenes/admin/devices_admin_screen.dart';
import 'package:manag_department_software_2/screenes/admin/task_admin_screen.dart';

class AdminHomeLayout extends StatefulWidget {
  final int initialIndex;

  const AdminHomeLayout({super.key, this.initialIndex = 0});

  @override
  State<AdminHomeLayout> createState() => _AdminHomeLayoutState();
}

class _AdminHomeLayoutState extends State<AdminHomeLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  static final List<Widget> _screens = [
    DashboardScreen(),
    DevicesAdminScreen(),
    TaskAdminScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _naveItem = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "الرئيسية"),
    BottomNavigationBarItem(icon: Icon(Icons.devices), label: "الأجهزة"),
    BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "المهام"),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "الملف"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _naveItem,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}
