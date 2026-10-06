import 'package:flutter/material.dart';
import 'package:manag_department_software_2/screenes/principal/my_request_principal_screen.dart';
import 'package:manag_department_software_2/screenes/principal/new_request_principal_screen.dart';
import 'package:manag_department_software_2/screenes/widget/build_tab_widget.dart';
import 'package:manag_department_software_2/screenes/widget/request_card_widget.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

class RequestPrincipalScreen extends StatefulWidget {
  const RequestPrincipalScreen({super.key});

  @override
  State<RequestPrincipalScreen> createState() => _RequestPrincipalScreenState();
}

class _RequestPrincipalScreenState extends State<RequestPrincipalScreen> {
  String _selectedFilter = 'الكل';
  final List _filters = ['الكل', 'معلقة', 'جارية', 'مكتملة', 'مرفوضة'];

  SharedData sharedData = SharedData.instance;
  late Map<String, dynamic> school;
  List<Map<String, dynamic>> get _filteredRequests {
    final requests = sharedData.getRequestsInSchool(school['number']);
    if (_selectedFilter == 'الكل') {
      return requests;
    }
    return requests.where((r) => r['status'] == _selectedFilter).toList();
  }

  late final devicesBySchool = sharedData.devicesBySchool(school['number']);

  @override
  void initState() {
    super.initState();
    school = sharedData.school!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sharedData,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              // ================= Header =================
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  right: 15,
                  left: 15,
                  bottom: 10,
                ),
                decoration: const BoxDecoration(color: Color(0xff2947B8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            color: Colors.white,
                            iconSize: 20,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (x) => NewRequestPrincipalScreen(
                                    school: school,
                                    device: devicesBySchool,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                        const Text(
                          'طلباتي',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(width: 5),
                        itemBuilder: (BuildContext context, int index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedFilter = filter;
                            }),
                            child: buildTab(
                              title: '$filter',
                              isSelected: isSelected,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= Requests List =================
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredRequests.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(height: 5),
                  itemBuilder: (BuildContext context, int index) {
                    final request = _filteredRequests[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyRequestPrincipalScreen(
                              request: request,
                              school: school,
                            ),
                          ),
                        );
                      },
                      child: requestCardWidget(
                        '${request['status']}',
                        _statusColor(request['status']),
                        '${request['requestNumber']}',
                        '${request['description']}',
                        request['requestType'] == 'فنية'
                            ? '${request['description']}'
                            : '',
                        '${school['name']}',
                        SharedData.formatDate(request['date']),
                        '${request['requestType']}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'معلقة':
        return Colors.orange;

      case 'جارية':
        return Colors.blue;

      case 'مكتملة':
        return Colors.green;

      case 'مرفوضة':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
