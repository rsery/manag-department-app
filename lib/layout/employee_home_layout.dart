import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/DashboardScreen.dart';
import 'package:manag_department_software_2/screenes/ProfileScreen.dart';
import 'package:manag_department_software_2/screenes/admin/devices_admin_screen.dart';
import 'package:manag_department_software_2/screenes/employee/task_emplyee_screen.dart';

class EmployeeHomeLayout extends StatefulWidget {
  const EmployeeHomeLayout({super.key});

  @override
  State<EmployeeHomeLayout> createState() => _EmployeeHomeLayoutState();
}

class _EmployeeHomeLayoutState extends State<EmployeeHomeLayout> {
  int _currentIndex = 0;
  static final List<Widget> _screens = [
    DashboardScreen(),
    DevicesAdminScreen(),
    TaskEmplyeeScreen(),
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
