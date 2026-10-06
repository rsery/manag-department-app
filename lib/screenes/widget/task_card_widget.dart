import 'package:flutter/material.dart';

Widget taskCardWidget(
  String status,
  Color statusColor,
  String priority,
  Color priorityColor,
  String requestId,
  String description,
  String school,
  String date,
  int notesCount,
  int employeeCount,
) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xffE3E5EC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              requestId,
              style: const TextStyle(
                color: Color(0xff70798B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // Description
        Text(
          description,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff1B1D26),
          ),
        ),

        const SizedBox(height: 3),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(color: Color(0xff8D93A1), fontSize: 15),
            ),
            Text(
              school,
              style: const TextStyle(fontSize: 12, color: Color(0xff777C8B)),
            ),
          ],
        ),
        const SizedBox(height: 3),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$employeeCount موظف',
              style: const TextStyle(color: Color(0xff8D93A1), fontSize: 12),
            ),
            Text('.     '),
            Text(
              '$notesCount ملاحظة',
              style: const TextStyle(color: Color(0xff8D93A1), fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}
