import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/admin/school/add_school_screen.dart';
import 'package:manag_department_software_2/screenes/admin/school/school_details_screen.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class SchoolListScreen extends StatefulWidget {
  const SchoolListScreen({super.key});

  @override
  State<SchoolListScreen> createState() => _SchoolListScreenState();
}

class _SchoolListScreenState extends State<SchoolListScreen> {
  final TextEditingController _searchController = TextEditingController();

  SharedData sharedData = SharedData.instance;

  bool get _canAdd => sharedData.hasPermission('add_school');
  bool get _canEdit => sharedData.hasPermission('edit_school');
  bool get _canDelete => sharedData.hasPermission('delete_school');

  List<Map<String, dynamic>> get _filteredSchools {
    final query = _searchController.text.trim().toLowerCase();
    final schools = sharedData.schools;

    return schools.where((school) {
      final matchSearch =
          query.isEmpty ||
          school['number'].toString().toLowerCase().contains(query) ||
          school['name'].toString().toLowerCase().contains(query) ||
          school['phonenumber'].toString().toLowerCase().contains(query) ||
          school['address'].toString().toLowerCase().contains(query) ||
          school['gender'].toString().toLowerCase().contains(query) ||
          school['interval'].toString().toLowerCase().contains(query) ||
          school['stage'].toString().toLowerCase().contains(query) ||
          school['type'].toString().toLowerCase().contains(query) ||
          school['managerName'].toString().toLowerCase().contains(query) ||
          school['notes'].toString().toLowerCase().contains(query);

      return matchSearch;
    }).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("المدارس"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "ابحث باسم المدرسة أو رقمها",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          body: ListView.builder(
            itemCount: _filteredSchools.length,
            itemBuilder: (context, index) {
              final school = _filteredSchools[index];
              final user = sharedData.userBySchool[school['number']];

              // ✅ نبني عناصر trailing حسب الصلاحيات، ونخفي الصف كله لو مفيش صلاحية
              final trailingActions = <Widget>[
                if (_canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddSchoolScreen(schoolData: school, user: user),
                        ),
                      );
                    },
                  ),
                if (_canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text("تأكيد الحذف"),
                            content: const Text(
                              "هل أنت متأكد من حذف هذه المدرسة؟",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);

                                  if (sharedData
                                      .devicesBySchool(school['number'])
                                      .isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'لا يمكن حذف المدرسة طالما يوجد فيها أجهزة',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await SharedData.instance.deleteSchool(
                                    school['number'],
                                  );
                                  await SharedData.instance.deleteUserById(
                                    user?['id'],
                                  );
                                },
                                child: const Text(
                                  "حذف",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ];

              return Card(
                child: ListTile(
                  title: Text(school['name']),
                  subtitle: Text(school['address']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchoolDetailsScreen(school: school),
                      ),
                    );
                  },
                  trailing: trailingActions.isEmpty
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: trailingActions,
                        ),
                ),
              );
            },
          ),

          floatingActionButton: _canAdd
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddSchoolScreen(user: null, schoolData: null),
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}
