import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class AddDeviceScreen extends StatefulWidget {
  final Map<String, dynamic>? device;
  const AddDeviceScreen({super.key, required this.device});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  SharedData sharedData = SharedData.instance;
  List<Map<String, dynamic>> get schools => sharedData.schools;
  // هنا اضافة باقي الوحدات
  List<DropdownMenuItem<String>> get deviceTypeItems {
    return sharedData.deviceTypes.map((t) {
      return DropdownMenuItem<String>(
        value: t['name'].toString(),
        child: Text(t['name'].toString()),
      );
    }).toList();
  }

  String? type;
  final List<DropdownMenuItem<String>> statusList = [
    'يعمل',
    'صيانة',
    'تالف',
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String? status;

  List<DropdownMenuItem<String>> get schoolsNumberList {
    return schools.map((school) {
      return DropdownMenuItem<String>(
        value: school['number'].toString(),
        child: Text(school['name']),
      );
    }).toList();
  }

  String? schoolNumber;

  final List<DropdownMenuItem<String>> statusInList = [
    'جديد',
    'مستعمل',
  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  String? statusIn;

  DateTime? _purchaseDate;

  final deviceNumber = TextEditingController();
  final serialNumber = TextEditingController();
  final brand = TextEditingController();
  final model = TextEditingController();
  final purchaseDate = TextEditingController();
  final location = TextEditingController();
  final projeact = TextEditingController();
  final note = TextEditingController();
  final specs = TextEditingController(); // ✅ جديد

  @override
  void initState() {
    super.initState();

    if (widget.device != null) {
      type = widget.device!['type'];
      status = widget.device!['status'];
      statusIn = widget.device!['statusIn'];

      deviceNumber.text = widget.device!['number'].toString();
      serialNumber.text = widget.device!['serialNumber'] ?? '';
      brand.text = widget.device!['brand'] ?? '';
      model.text = widget.device!['model'] ?? '';
      projeact.text = widget.device!['project'] ?? '';
      note.text = widget.device!['note'] ?? '';
      specs.text = widget.device!['specs'] ?? ''; // ✅ جديد
      schoolNumber = widget.device!['schoolNumber'];
    } else {
      // توليد الرقم الأولي عند فتح شاشة الإضافة لأول مرة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoFillDeviceNumber();
      });
    }
  }

  bool islode = false;
  bool _manualNumber = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.device == null ? "إضافة جهاز جديد" : "تعديل بيانات الجهاز",
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
                  DropdownButtonFormField<String>(
                    hint: const Text('اختر نوع الجهاز'),
                    items: deviceTypeItems,
                    onChanged: widget.device == null
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                type = value;
                              });
                              _autoFillDeviceNumber();
                              _formKey.currentState?.validate();
                            }
                          }
                        : null,
                    initialValue: type,
                    validator: (value) =>
                        value == null ? 'يرجى اختيار نوع الجهاز' : null,
                  ),
                  _buildDeviceNumberField(),
                  _buildTextField(serialNumber, "رقم التسلسلي للجهاز"),
                  _buildTextField(brand, "علامة التجارية"),
                  _buildTextField(model, "موديل الجهاز"),
                  _buildTextField(
                    specs,
                    "المواصفات (مثال: Core i7-11Gen 2.8GHz;16GB DDR4;500GB Nvme)",
                    maxLines: 2,
                  ), // ✅ جديد
                  DropdownButtonFormField(
                    hint: Text('حالة الجهاز عند الشراء'),
                    initialValue: statusIn,
                    items: statusInList,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          statusIn = value;
                        });
                      }
                    },
                  ),

                  _buildTextField(
                    purchaseDate,
                    "تارخ الشراء",
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _purchaseDate = pickedDate;
                          purchaseDate.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    hint: Text('حالة الجهاز الحالية'),
                    initialValue: status,
                    items: statusList,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          status = value;
                        });
                      }
                    },
                  ),
                  _buildTextField(projeact, "المشروع"),
                  DropdownButtonFormField<String>(
                    hint: Text('اختر المدرسة'),
                    initialValue: schoolNumber,
                    items: schoolsNumberList,
                    onChanged: widget.device == null
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                schoolNumber = value;
                              });
                            }
                          }
                        : null,
                  ),
                  _buildTextField(location, "الموقع"),

                  _buildTextField(note, "ملاحظات"),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (type == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى اختيار نوع الجهاز'),
                          ),
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        final selectedSchool = schools.firstWhere(
                          (e) => e['number'] == schoolNumber,
                          orElse: () => <String, dynamic>{},
                        );
                        if (selectedSchool.isEmpty ||
                            selectedSchool['name'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى اختيار مدرسة')),
                          );
                          return;
                        }
                        String schoolName = selectedSchool['name'];
                        setState(() {
                          islode = true;
                        });
                        if (widget.device == null) {
                          sharedData.addDevice(
                            number: deviceNumber.text,
                            type: type!,
                            id: '$type-${deviceNumber.text}',
                            serialNumber: serialNumber.text,
                            brand: brand.text,
                            model: model.text,
                            purchaseDate: _purchaseDate ?? DateTime.now(),
                            status: status ?? 'يعمل',
                            schoolNumber: schoolNumber ?? '',
                            schoolName: schoolName,
                            location: location.text,
                            statusIn: statusIn ?? 'جديد',
                            project: projeact.text,
                            printTo: false,

                            nameIn: sharedData.currentUser?['name'] ?? '',
                            note: note.text,
                            specs: specs.text, // ✅ جديد
                          );
                        } else {
                          sharedData.updateDevice(widget.device!['id'], {
                            'serialNumber': serialNumber.text,
                            'brand': brand.text,
                            'model': model.text,
                            'status': status ?? 'يعمل',
                            'schoolNumber': schoolNumber ?? '',
                            'schoolName': schoolName,
                            'location': location.text,
                            'statusIn': statusIn ?? 'جديد',
                            'project': projeact.text,
                            'note': note.text,
                            'specs': specs.text, // ✅ جديد
                            if (_purchaseDate != null)
                              'purchaseDate': _purchaseDate,
                          });
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        setState(() {
                          islode = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.device == null ? "حفظ الجهاز" : "تعديل الجهاز",
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
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
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function()? onTap,
    int maxLines = 1, // ✅ جديد
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines, // ✅ جديد
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

  String _generateNextDeviceNumber(String deviceType) {
    // جلب كل أرقام الأجهزة من نفس النوع
    final existingNumbers = sharedData.devices
        .where((d) => d['type'] == deviceType)
        .map((d) {
          final n = d['number'];
          return int.tryParse(n.toString()) ?? 0;
        })
        .toSet(); // Set أسرع للبحث بـ contains
    // ابحث عن أول رقم مش موجود بالتسلسل، بداية من 1
    int next = 1;
    while (existingNumbers.contains(next)) {
      next++;
    }

    return next.toString();
  }

  void _autoFillDeviceNumber() {
    if (widget.device != null) return; // فقط عند الإضافة، ليس التعديل
    if (_manualNumber) return; // لا تلمس الرقم لو المستخدم بوضع يدوي
    if (type == null) return;
    setState(() {
      deviceNumber.text = _generateNextDeviceNumber(type!);
    });
  }

  Widget _buildDeviceNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: deviceNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            readOnly: widget.device != null ? true : !_manualNumber,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'أدخل رقم الجهاز';
              }

              if (widget.device == null) {
                final id = '$type-${value.trim()}';
                bool exists = sharedData.devices.any(
                  (device) => device['id'] == id,
                );
                if (exists) {
                  return 'يوجد جهاز بنفس النوع والرقم';
                }
              }
              return null;
            },
            style: const TextStyle(fontFamily: 'Cairo'),
            decoration: InputDecoration(
              labelText: "رقم الجهاز",
              labelStyle: const TextStyle(fontFamily: 'Cairo'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: (widget.device != null || !_manualNumber)
                  ? Colors.grey[200]
                  : Colors.grey[50],
              suffixIcon: widget.device == null
                  ? IconButton(
                      icon: Icon(
                        _manualNumber ? Icons.edit : Icons.auto_awesome,
                        color: const Color(0xff233EAF),
                        size: 20,
                      ),
                      tooltip: _manualNumber
                          ? 'تعيين رقم يدوي'
                          : 'توليد تلقائي',
                      onPressed: null, // التحكم الفعلي عبر الـ Switch تحت
                    )
                  : null,
            ),
          ),
          if (widget.device == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Switch(
                    value: _manualNumber,
                    activeThumbColor: const Color(0xff233EAF),
                    onChanged: (value) {
                      setState(() {
                        _manualNumber = value;
                        if (!value && type != null) {
                          // رجوع للتوليد التلقائي
                          deviceNumber.text = _generateNextDeviceNumber(type!);
                        } else if (!value) {
                          deviceNumber
                              .clear(); // لو مفيش نوع محدد، نضل الحقل فاضي
                        } else {
                          // تفريغ الحقل ليدخل المستخدم رقمه
                          deviceNumber.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _manualNumber ? 'إدخال رقم يدوي' : 'توليد رقم تلقائي',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
