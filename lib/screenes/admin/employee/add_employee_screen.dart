import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final jobNumber = TextEditingController();
  final name = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final roleStr = TextEditingController();

  String? role;
  List<String> selectedPermissions = [];

  List<String> get roles {
    return widget.employee == null
        ? ['employee']
        : ['admin', 'employee', 'secretary'];
  }

  final permissionsList = [
    'add_device',
    'edit_device',
    'delete_device',
    'transfer_device',
    'print_device',

    'add_school',
    'edit_school',
    'delete_school',

    'add_employee',
    'edit_employee',
    'delete_employee',
    'view_reports',
  ];

  SharedData sharedData = SharedData.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.employee != null) {
      jobNumber.text = widget.employee!['employeeNumber'] ?? '';
      name.text = widget.employee!['name'] ?? '';
      username.text = widget.employee!['username'] ?? '';
      password.text = widget.employee!['password'] ?? '';
      roleStr.text = widget.employee!['roleStr'] ?? '';
      role = widget.employee!['role'];

      selectedPermissions = List<String>.from(
        widget.employee!['permissions'] ?? [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.employee == null ? "إضافة موظف جديد" : "تعديل بيانات موظف",
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    jobNumber,
                    "الرقم الوظيفي",
                    readOnly:
                        widget.employee !=
                        null, // ✅ يمنع التعديل عند تعديل موظف موجود
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء إدخال الرقم الوظيفي";
                      }

                      // ✅ التحقق من عدم تكرار الرقم الوظيفي عند الإضافة فقط
                      if (widget.employee == null) {
                        final bool exists = sharedData.users.any(
                          (u) => u['employeeNumber'] == value.trim(),
                        );
                        if (exists) {
                          return "هذا الرقم الوظيفي مستخدم مسبقاً";
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    name,
                    "اسم الموظف",
                    validator: (value) =>
                        value!.isEmpty ? "الرجاء إدخال اسم الموظف" : null,
                  ),
                  _buildTextField(
                    username,
                    "اسم المستخدم",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء إدخال اسم المستخدم";
                      }

                      // ✅ التحقق من عدم تكرار اسم المستخدم عند الإضافة فقط
                      if (widget.employee == null) {
                        final bool exists = sharedData.users.any(
                          (u) => u['username'] == value.trim(),
                        );
                        if (exists) {
                          return "هذا اسم المستخدم مستخدم مسبقاً";
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    password,
                    "كلمة المرور",
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? "الرجاء إدخال كلمة المرور" : null,
                  ),
                  _buildTextField(
                    roleStr,
                    "مسمى الوظيفي ",

                    validator: (value) =>
                        value!.isEmpty ? "الرجاء إدخال الدور " : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      initialValue: role,
                      items: roles
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged:
                          widget.employee != null &&
                              (widget.employee?['role'] == 'admin' ||
                                  widget.employee?['role'] == 'secretary')
                          ? null
                          : (value) {
                              setState(() {
                                role = value.toString();
                              });
                            },
                      decoration: InputDecoration(
                        labelText: "الدور",
                        labelStyle: const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "الصلاحيات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  widget.employee != null &&
                          (widget.employee?['role'] == 'admin')
                      ? Center(child: Text('يمنح مسؤول النظام كامل الصلاحيات'))
                      : Column(
                          children: permissionsList.map((perm) {
                            return CheckboxListTile(
                              title: Text(
                                getPermissionName(perm),
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              value: selectedPermissions.contains(perm),
                              onChanged: widget.employee?['role'] == 'admin'
                                  ? null
                                  : (value) {
                                      setState(() {
                                        if (value!) {
                                          selectedPermissions.add(perm);
                                        } else {
                                          selectedPermissions.remove(perm);
                                        }
                                      });
                                    },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 30),
                  isLoading == true
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (role == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى اختيار الدور'),
                                ),
                              );
                              return;
                            }
                            setState(() => isLoading = true);

                            if (widget.employee == null) {
                              // إضافة موظف جديد
                              await sharedData.addUser(
                                name: name.text,
                                username: username.text,
                                password: password.text,
                                email: '${username.text}@dept.com',
                                role: role!,
                                roleStr: roleStr.text,
                                schoolNumber: '',
                                employeeNumber: jobNumber.text,
                                permissions: selectedPermissions,
                              );
                            } else {
                              // تعديل موظف موجود — استخدم اسم المستخدم الأصلي للبحث عنه
                              await sharedData
                                  .updateUserById(widget.employee!['id'], {
                                    'name': name.text,
                                    'username': username.text,
                                    'password': password.text,
                                    'employeeNumber': jobNumber.text,
                                    'role': role!,
                                    'roleStr': roleStr.text,
                                    'permissions': selectedPermissions,
                                  });
                            }

                            if (!mounted) return;
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: Text(
                            widget.employee == null
                                ? "حفظ الموظف"
                                : "تعديل الموظف",
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getPermissionName(String perm) {
    switch (perm) {
      case 'add_device':
        return 'إضافة جهاز';
      case 'edit_device':
        return 'تعديل جهاز';
      case 'delete_device':
        return 'حذف جهاز';
      case 'transfer_device':
        return 'نقل جهاز / سجل النقل';
      case 'print_device':
        return 'طباعة لاصقات وتقارير الأجهزة';
      case 'add_school':
        return 'اضافة مدرسة';
      case 'edit_school':
        return 'تعديل مدرسة';
      case 'delete_school':
        return 'حذف مدرسة ';
      case 'add_employee':
        return 'إضافة موظف';
      case 'edit_employee':
        return 'تعديل موظف';
      case 'delete_employee':
        return 'حذف موظف';
      case 'assign_task':
        return 'تعيين مهام';
      case 'execute_task':
        return 'تنفيذ مهام';
      case 'view_reports':
        return 'عرض التقارير';
      default:
        return perm;
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
