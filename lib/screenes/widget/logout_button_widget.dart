import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

Widget logoutButtonWidget(context) {
  return InkWell(
    onTap: () {
      final confirm = showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      confirm.then((value) {
        if (value == true) {
          SharedData.instance.logout(context); // ✅ يمسح currentUser وينتقل
        }
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xffFDEEEE),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffF2C7C7)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xffD93A3A), size: 25),
            SizedBox(width: 12),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: Color(0xffD93A3A),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
