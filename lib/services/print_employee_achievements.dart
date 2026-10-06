import 'package:flutter/material.dart';
import 'package:manag_department_software_2/shared/pdf_fonts.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printEmployeeAchievements(
  BuildContext context,
  Map<String, dynamic> employee,
  List<Map<String, dynamic>> achievements,
) async {
  await PdfFonts.load();
  final doc = pw.Document(theme: PdfFonts.theme);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'تقرير إنجازات الموظف',
            style: pw.TextStyle(fontSize: 18, font: PdfFonts.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'اسم الموظف: ${employee['name'] ?? ''}   |   اسم المستخدم: ${employee['username'] ?? ''}',
            style: pw.TextStyle(fontSize: 11, font: PdfFonts.regular),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      ),
      build: (context) => [
        if (achievements.isEmpty)
          pw.Center(
            child: pw.Text(
              'لا يوجد إنجازات مسجلة لهذا الموظف',
              style: pw.TextStyle(fontSize: 12, font: PdfFonts.regular),
              textDirection: pw.TextDirection.rtl,
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _cell('رقم الطلب', bold: true),
                  _cell('الوصف', bold: true),
                  _cell('نوع الطلب', bold: true),
                  _cell('الأولوية', bold: true),
                ],
              ),
              ...achievements.map((r) {
                return pw.TableRow(
                  children: [
                    _cell('${r['requestNumber'] ?? ''}'),
                    _cell('${r['description'] ?? ''}'),
                    _cell('${r['requestType'] ?? ''}'),
                    _cell('${r['priority'] ?? ''}'),
                  ],
                );
              }),
            ],
          ),
        pw.SizedBox(height: 16),
        pw.Text(
          'إجمالي عدد الإنجازات: ${achievements.length}',
          style: pw.TextStyle(fontSize: 12, font: PdfFonts.bold),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'achievements_${employee['username']}.pdf',
  );
}

Future<void> printAllEmployeesAchievements(
  BuildContext context,
  List<Map<String, dynamic>> employees, {
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  await PdfFonts.load();
  final doc = pw.Document(theme: PdfFonts.theme);

  String rangeLabel() {
    if (fromDate == null && toDate == null) return 'كل الفترات';
    final f = fromDate != null ? _fmt(fromDate) : '...';
    final t = toDate != null ? _fmt(toDate) : '...';
    return 'من $f  إلى  $t';
  }

  int grandTotal = 0;

  final sections = <pw.Widget>[];

  for (final emp in employees) {
    final username = emp['username'] ?? '';
    final achievements = SharedData.instance.getEmployeeAchievements(
      username,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (achievements.isEmpty) continue; // تخطي الموظفين بدون إنجازات بالفترة
    grandTotal += achievements.length;

    sections.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: pw.Text(
                '${emp['name'] ?? ''} ($username)  —  عدد الإنجازات: ${achievements.length}',
                style: pw.TextStyle(fontSize: 12, font: PdfFonts.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _cell('رقم الطلب', bold: true),
                    _cell('الوصف', bold: true),
                    _cell('نوع الطلب', bold: true),
                    _cell('الأولوية', bold: true),
                  ],
                ),
                ...achievements.map((r) {
                  return pw.TableRow(
                    children: [
                      _cell('${r['requestNumber'] ?? ''}'),
                      _cell('${r['description'] ?? ''}'),
                      _cell('${r['requestType'] ?? ''}'),
                      _cell('${r['priority'] ?? ''}'),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'تقرير إنجازات جميع الموظفين',
            style: pw.TextStyle(fontSize: 18, font: PdfFonts.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            rangeLabel(),
            style: pw.TextStyle(fontSize: 11, font: PdfFonts.regular),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      ),
      build: (context) => [
        if (sections.isEmpty)
          pw.Center(
            child: pw.Text(
              'لا يوجد إنجازات ضمن الفترة المحددة',
              style: pw.TextStyle(fontSize: 12, font: PdfFonts.regular),
              textDirection: pw.TextDirection.rtl,
            ),
          )
        else
          ...sections,
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.Text(
          'إجمالي عدد الإنجازات لجميع الموظفين: $grandTotal',
          style: pw.TextStyle(fontSize: 13, font: PdfFonts.bold),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'all_employees_achievements.pdf',
  );
}

String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

pw.Widget _cell(String text, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        font: bold ? PdfFonts.bold : PdfFonts.regular,
      ),
      textDirection: pw.TextDirection.rtl,
      textAlign: pw.TextAlign.center,
    ),
  );
}
