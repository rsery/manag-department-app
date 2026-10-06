// طباعة قائمة كل الأجهزة المفلترة (PDF Table)
import 'dart:io';

import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/pdf_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printDevicesList(
  List<Map<String, dynamic>> filteredDevices,
) async {
  await PdfFonts.load();

  final doc = pw.Document(theme: PdfFonts.theme);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        pw.Text(
          'قائمة الأجهزة',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: PdfFonts.bold,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '  عدد الأجهزة: ${filteredDevices.length}',
          style: pw.TextStyle(fontSize: 11, font: PdfFonts.regular),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['المدرسة', 'الحالة', 'الموديل', 'الشركة', 'النوع', 'الرقم'],
          data: filteredDevices.map((d) {
            return [
              '${d['schoolName']}',
              '${d['status']}',
              '${d['model']}',
              '${d['brand']}',
              '${d['type']}',
              '${d['id']}',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            font: PdfFonts.bold,
          ),
          cellStyle: pw.TextStyle(fontSize: 9, font: PdfFonts.regular),
          cellAlignment: pw.Alignment.centerRight,
          headerAlignment: pw.Alignment.centerRight,
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'devices_list.pdf',
  );
}

// Future<void> printDevicesList(
//   List<Map<String, dynamic>> filteredDevices,
// ) async {
//   final doc = pw.Document();

//   doc.addPage(
//     pw.MultiPage(
//       build: (context) => [
//         pw.Text(
//           'قائمة الأجهزة',
//           style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 12),
//         pw.TableHelper.fromTextArray(
//           headers: ['الرقم', 'النوع', 'الشركة', 'الموديل', 'الحالة', 'المدرسة'],
//           data: filteredDevices
//               .map(
//                 (d) => [
//                   '${d['id']}',
//                   '${d['type']}',
//                   '${d['brand']}',
//                   '${d['model']}',
//                   '${d['status']}',
//                   '${d['schoolName']}',
//                 ],
//               )
//               .toList(),
//         ),
//       ],
//     ),
//   );

//   await Printing.layoutPdf(onLayout: (format) async => doc.save());
// }

// تصدير الأجهزة المفلترة إلى إكسل
Future<void> exportDevicesExcel(
  BuildContext context,
  List<Map<String, dynamic>> filteredDevices,
) async {
  final excel = ex.Excel.createExcel();
  final sheet = excel['الأجهزة'];

  sheet.appendRow([
    ex.TextCellValue('الرقم'),
    ex.TextCellValue('النوع'),
    ex.TextCellValue('الشركة'),
    ex.TextCellValue('الموديل'),
    ex.TextCellValue('الحالة'),
    ex.TextCellValue('المدرسة'),
  ]);

  for (final d in filteredDevices) {
    sheet.appendRow([
      ex.TextCellValue('${d['id']}'),
      ex.TextCellValue('${d['type']}'),
      ex.TextCellValue('${d['brand']}'),
      ex.TextCellValue('${d['model']}'),
      ex.TextCellValue('${d['status']}'),
      ex.TextCellValue('${d['schoolName']}'),
    ]);
  }

  final bytes = excel.encode();
  if (bytes == null) return;

  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/devices_export.xlsx';
  final file = File(path);
  await file.writeAsBytes(bytes);
  await OpenFile.open(path);
}
