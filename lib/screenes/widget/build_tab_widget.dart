import 'package:flutter/material.dart';

Widget buildTab({required String title, bool isSelected = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: isSelected ? Colors.white.withValues(alpha: .25) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}
