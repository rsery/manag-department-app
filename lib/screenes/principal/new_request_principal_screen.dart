import 'package:flutter/material.dart';
import 'package:manag_department_software_2/layout/principal_home_layout.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class NewRequestPrincipalScreen extends StatefulWidget {
  final Map<String, dynamic> school;
  final List device;
  const NewRequestPrincipalScreen({
    super.key,
    required this.school,
    required this.device,
  });

  @override
  State<NewRequestPrincipalScreen> createState() =>
      _NewRequestPrincipalScreenState();
}

class _NewRequestPrincipalScreenState extends State<NewRequestPrincipalScreen> {
  String selectedType = 'technical';
  String deviceSelecte = '';
  TextEditingController descriptionController = TextEditingController();

  final SharedData sharedData = SharedData.instance;
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),

        title: const Text(
          'طلب خدمة جديد',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= Header =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xff2947B8),

              child: Column(
                children: [
                  const Text(
                    'طلب خدمة جديد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${widget.school['name']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  const Text(
                    'نوع الخدمة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 8),

                  // ================= Technical =================
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = 'technical';
                      });
                    },

                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: selectedType == 'technical'
                            ? const Color(0xff2947B8)
                            : Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: const Color(0xffD9DEE7)),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 18,
                            color: selectedType == 'technical'
                                ? Colors.white
                                : const Color(0xff7A869A),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'فنية (مرتبطة بجهاز)',
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedType == 'technical'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ================= Admin =================
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = 'admin';
                      });
                    },

                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: selectedType == 'admin'
                            ? const Color(0xff2947B8)
                            : Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: const Color(0xffD9DEE7)),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 18,
                            color: selectedType == 'admin'
                                ? Colors.white
                                : const Color(0xff7A869A),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'إدارية',
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedType == 'admin'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  selectedType == 'technical'
                      ? const Text(
                          'اختر الجهاز المرتبط',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff70798B),
                          ),
                        )
                      : SizedBox(),

                  const SizedBox(height: 6),
                  if (selectedType == 'technical')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD9DEE7)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: deviceSelecte.isEmpty ? null : deviceSelecte,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),

                          hint: const Text(
                            'اختر جهازاً...',
                            style: TextStyle(fontSize: 12),
                          ),

                          items: widget.device.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['id'],
                              child: Text('${d['id']}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              deviceSelecte = value;
                            });
                          },
                        ),
                      ),
                    )
                  else
                    SizedBox(),

                  const SizedBox(height: 12),

                  const Text(
                    'وصف الطلب *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '...اشرح طلبك بالتفصيل',
                      hintStyle: const TextStyle(fontSize: 12),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.all(12),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffD9DEE7)),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffD9DEE7)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffDCE8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xff2947B8),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'سيتم مراجعة الطلب من قبل سكرتير القسم الحاسوب وتحويلة للموظف المختص',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff2947B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    onTap: () {
                      bool isValid =
                          descriptionController.text.trim().isNotEmpty &&
                          (selectedType == 'admin' || deviceSelecte.isNotEmpty);

                      if (!isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
                          ),
                        );
                        return;
                      }

                      int requestNumber = sharedData.requests.length + 1;
                      sharedData.addRequest(
                        requestNumber:
                            'REQ ${requestNumber.toString().padLeft(4, '0')}',
                        schoolNumber: widget.school['number'],
                        devicNumber: selectedType == 'technical'
                            ? deviceSelecte
                            : '',
                        requestType: selectedType == 'technical'
                            ? 'فنية'
                            : 'ادارية',
                        priority: 'عادية',
                        description: descriptionController.text,
                        status: 'معلقة',
                        date: DateTime.now(),
                        expiryDate: DateTime.now(),
                        participants: [],
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (x) => PrincipalHomeLayout(initIndex: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xffE9EDF3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_outlined,
                            size: 18,
                            color: Color(0xff6E7B91),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'إرسال الطلب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff6E7B91),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
