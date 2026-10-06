import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class AddSchoolScreen extends StatefulWidget {
  final Map<String, dynamic>? schoolData;
  final Map<String, dynamic>? user;
  const AddSchoolScreen({super.key, this.schoolData, this.user});

  @override
  State<AddSchoolScreen> createState() => _AddSchoolScreenState();
}

class _AddSchoolScreenState extends State<AddSchoolScreen> {
  SharedData sharedData = SharedData.instance;
  List<Map<String, dynamic>> get schools => sharedData.schools;
  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<String>> genderList = [
    "ذكور",
    "إناث",
    "مختلط",
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String gender = "ذكور";

  final List<DropdownMenuItem<String>> intervalList = [
    "صباحي",
    "مسائي",
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String interval = "صباحي";

  final List<DropdownMenuItem<String>> stageList = [
    "ابتدائي",
    "إعدادي",
    "ثانوي",
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String stage = "ابتدائي";

  final List<DropdownMenuItem<String>> typeList = [
    "حكومي",
    "خاص",
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String type = "حكومي";

  final schoolNumber = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final note = TextEditingController();
  final managerName = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    schoolNumber.dispose();
    name.dispose();
    address.dispose();
    phone.dispose();
    note.dispose();
    managerName.dispose();
    userName.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.schoolData != null) {
      final data = widget.schoolData!;

      schoolNumber.text = data['number'] ?? '';
      name.text = data['name'] ?? '';
      address.text = data['address'] ?? '';
      phone.text = (data['phonenumber'] ?? '').toString();
      managerName.text = data['managerName'] ?? '';
      note.text = data['notes'] ?? '';

      gender = data['gender'] ?? gender;
      interval = data['interval'] ?? interval;
      stage = data['stage'] ?? stage;
      type = data['type'] ?? type;
    }
    if (widget.user != null) {
      userName.text = widget.user!['username'] ?? '';
      password.text = widget.user!['password'] ?? '';
    }
  }

  bool islode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.schoolData == null
              ? "إضافة مدرسة جديدة"
              : "تعديل بيانات مدرسة",
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
                    schoolNumber,
                    "رقم المدرسة",
                    keyboardType: TextInputType.number,
                    readOnly: widget.schoolData != null ? true : false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      if (widget.schoolData == null) {
                        bool exists = schools.any((school) {
                          return school['number'] == value;
                        });
                        if (exists) {
                          return 'رقم المدرسة مستخدم مسبقاً';
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    name,
                    "اسم المدرسة",
                    readOnly: widget.schoolData != null ? true : false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    address,
                    "العنوان",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }

                      return null;
                    },
                  ),
                  _buildTextField(
                    phone,
                    "الهاتف",
                    keyboardType: TextInputType.phone,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButton(
                      value: gender,
                      items: genderList,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            gender = value;
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButton(
                      value: interval,
                      items: intervalList,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            interval = value;
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButton(
                      value: stage,
                      items: stageList,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            stage = value;
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButton(
                      value: type,
                      items: typeList,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            type = value;
                          });
                        }
                      },
                    ),
                  ),

                  _buildTextField(managerName, "اسم المدير"),
                  _buildTextField(
                    userName,
                    'اسم المستخدم',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    password,
                    'كلمة المرور',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(note, "ملاحظات"),
                  const SizedBox(height: 30),
                  islode
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() {
                              islode = true;
                            });
                            if (widget.schoolData == null) {
                              await sharedData.addSchool(
                                number: schoolNumber.text,
                                name: name.text,
                                phonenumber: phone.text,
                                address: address.text,
                                gender: gender,
                                interval: interval,
                                stage: stage,
                                type: type,
                                managerName: managerName.text,
                                notes: note.text,
                              );
                              await sharedData.addUser(
                                name: managerName.text,
                                username: userName.text,
                                password: password.text,
                                email: '${userName.text}@gmail.com',
                                role: 'principal',
                                roleStr: 'مدير مدرسة/قسم',
                                schoolNumber: schoolNumber.text,
                                employeeNumber: '',
                                permissions: [],
                              );
                            } else {
                              await sharedData.updateSchool(schoolNumber.text, {
                                'name': name.text,
                                'address': address.text,
                                'gender': gender,
                                'interval': interval,
                                'stage': stage,
                                'type': type,
                                'managerName': managerName.text,
                                'notes': note.text,
                              });
                              await sharedData
                                  .updateUserById(widget.user?['id'], {
                                    'username': userName.text,
                                    'password': password.text,
                                    'email': '${userName.text}@gmail.com',
                                    'role': 'principal',
                                    'schoolNumber': schoolNumber.text,
                                    'employeeNumber': '',
                                  });
                            }

                            if (!mounted) return;
                            Navigator.pop(context);
                            setState(() {
                              islode = false;
                            });
                          },
                          icon: const Icon(Icons.save),
                          label: Text(
                            widget.schoolData == null
                                ? "حفظ المدرسة"
                                : "تعديل المدرسة",
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

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
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
