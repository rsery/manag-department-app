import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:manag_department_software_2/shared/pdf_fonts.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

pw.MemoryImage? _logoImage;
pw.MemoryImage? _palestineLogoImage;

Future<pw.MemoryImage> _loadLogo() async {
  if (_logoImage != null) return _logoImage!;
  final bytes = await rootBundle.load('assets/images/logo.png');
  _logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
  return _logoImage!;
}

// شعار دولة فلسطين (يوضع في الطرف المقابل للشعار الحالي بالهيدر)
Future<pw.MemoryImage> _loadPalestineLogo() async {
  if (_palestineLogoImage != null) return _palestineLogoImage!;
  final bytes = await rootBundle.load('assets/images/palestine_logo.png');
  _palestineLogoImage = pw.MemoryImage(bytes.buffer.asUint8List());
  return _palestineLogoImage!;
}

// حجم اللاصق الفردي (10 سم × 5 سم)
const _labelPageFormat = PdfPageFormat(
  10 * PdfPageFormat.cm,
  5 * PdfPageFormat.cm,
);

Future<void> printDeviceLabel(
  BuildContext context,
  Map<String, dynamic> device,
) async {
  await PdfFonts.load();
  final logo = await _loadLogo();
  final palestineLogo = await _loadPalestineLogo();

  final doc = pw.Document(theme: PdfFonts.theme);

  doc.addPage(
    pw.Page(
      pageFormat: _labelPageFormat,
      margin: const pw.EdgeInsets.all(4),
      build: (context) => pw.FittedBox(
        fit: pw.BoxFit.contain,
        child: pw.SizedBox(
          width: _labelPageFormat.width - 8,
          child: _labelContent(device, logo, palestineLogo),
        ),
      ),
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
  final palestineLogo = await _loadPalestineLogo();

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
              child: _labelContent(device, logo, palestineLogo),
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
pw.Widget _labelContent(
  Map<String, dynamic> device,
  pw.MemoryImage logo,
  pw.MemoryImage palestineLogo,
) {
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
        // ===== الهيدر: شعار الوزارة + الاسم + شعار دولة فلسطين =====
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 3),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.7, style: pw.BorderStyle.dashed),
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, height: 36),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'وزارة التربية والتعليم العالي',
                      style: pw.TextStyle(fontSize: 8, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'مديرية التربية والتعليم - شرق غزة',
                      style: pw.TextStyle(fontSize: 8, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'قسم الحاسوب',
                      style: pw.TextStyle(fontSize: 8, font: PdfFonts.bold),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Image(palestineLogo, height: 36),
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
                _labelCell('قسم الحاسوب', bold: true, fontSize: 9),
                _labelCell('الدائرة', bold: true, fontSize: 8, shaded: true),
              ],
            ),
            pw.TableRow(
              children: [
                _labelCell(deviceCode, bold: true, fontSize: 11),
                _labelCell(
                  'الرقم العام',
                  bold: true,
                  fontSize: 8,
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
                  fontSize: 9,
                  minHeight: 26,
                ),
                _labelCell('المواصفات', bold: true, fontSize: 8, shaded: true),
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
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
