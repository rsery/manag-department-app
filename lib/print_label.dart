import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:manag_department_software_2/shared/pdf_fonts.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

pw.MemoryImage? _logoImage;

Future<pw.MemoryImage> _loadLogo() async {
  if (_logoImage != null) return _logoImage!;
  final bytes = await rootBundle.load('assets/images/logo.png');
  _logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
  return _logoImage!;
}

Future<void> printDeviceLabel(
  BuildContext context,
  Map<String, dynamic> device,
) async {
  await PdfFonts.load();
  final logo = await _loadLogo();

  final doc = pw.Document(theme: PdfFonts.theme);

  doc.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(
        10 * PdfPageFormat.cm,
        5 * PdfPageFormat.cm,
      ),
      margin: const pw.EdgeInsets.all(6),
      build: (context) => _labelContent(device, logo),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'label_${device['id']}.pdf',
  );

  await SharedData.instance.updateDevice(device['id'], {'toPrint': true});
}

Future<void> printDevicesLabels(
  BuildContext context,
  List<Map<String, dynamic>> devices,
) async {
  if (devices.isEmpty) return;

  await PdfFonts.load();
  final logo = await _loadLogo();

  final doc = pw.Document(theme: PdfFonts.theme);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(12),
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: devices.map((device) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: _labelContent(device, logo),
            );
          }).toList(),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'devices_labels.pdf',
  );

  for (final device in devices) {
    await SharedData.instance.updateDevice(device['id'], {'toPrint': true});
  }
}

// ================= تصميم اللاصق المطابق للنموذج المعتمد =================
pw.Widget _labelContent(Map<String, dynamic> device, pw.MemoryImage logo) {
  final specs = (device['specs'] ?? '').toString();
  final deviceCode = '${device['type'] ?? 'LAPTOP'}-${device['id'] ?? ''}';

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 1, color: PdfColors.black),
    ),
    padding: const pw.EdgeInsets.all(6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ===== الهيدر: الشعار + اسم الوزارة/المديرية/القسم =====
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.7, style: pw.BorderStyle.dashed),
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, height: 42),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'وزارة التربية والتعليم العالي',
                      style: pw.TextStyle(fontSize: 9, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'مديرية التربية والتعليم - شرق غزة',
                      style: pw.TextStyle(fontSize: 9, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'قسم الحاسوب',
                      style: pw.TextStyle(fontSize: 9, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 42), // موازنة بصرية مقابل الشعار
            ],
          ),
        ),

        // ===== الجدول: الدائرة / الرقم العام / المواصفات =====
        pw.Table(
          border: pw.TableBorder.all(width: 0.7),
          columnWidths: {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(1.4),
          },
          children: [
            pw.TableRow(
              children: [
                _labelCell('قسم الحاسوب', bold: true, fontSize: 10),
                _labelCell('الدائرة', bold: true, fontSize: 9, shaded: true),
              ],
            ),
            pw.TableRow(
              children: [
                _labelCell(deviceCode, bold: true, fontSize: 12),
                _labelCell(
                  'الرقم العام',
                  bold: true,
                  fontSize: 9,
                  shaded: true,
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _labelCell(
                  specs.isEmpty
                      ? '${device['brand'] ?? ''} ${device['model'] ?? ''}'
                      : specs,
                  fontSize: 10,
                  minHeight: 34,
                ),
                _labelCell('المواصفات', bold: true, fontSize: 9, shaded: true),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _labelCell(
  String text, {
  bool bold = false,
  double fontSize = 10,
  bool shaded = false,
  double? minHeight,
}) {
  return pw.Container(
    constraints: minHeight != null
        ? pw.BoxConstraints(minHeight: minHeight)
        : null,
    color: shaded ? PdfColors.grey200 : null,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: fontSize,
        font: bold ? PdfFonts.bold : PdfFonts.regular,
      ),
      textDirection: pw.TextDirection.rtl,
      textAlign: pw.TextAlign.center,
    ),
  );
}
