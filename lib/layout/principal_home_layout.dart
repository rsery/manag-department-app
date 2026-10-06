import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/DashboardScreen.dart';
import 'package:manag_department_software_2/screenes/ProfileScreen.dart';
import 'package:manag_department_software_2/screenes/principal/request_principal_screen.dart';

class PrincipalHomeLayout extends StatefulWidget {
  final int initIndex;
  const PrincipalHomeLayout({super.key, this.initIndex = 0});

  @override
  State<PrincipalHomeLayout> createState() => _PrincipalHomeLayoutState();
}

class _PrincipalHomeLayoutState extends State<PrincipalHomeLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex;
  }

  static const List<Widget> _screens = [
    DashboardScreen(),
    RequestPrincipalScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _naveItem = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "الرئيسية"),
    BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "طلبات"),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "الملف"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
