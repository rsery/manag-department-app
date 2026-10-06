import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFonts {
  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<void> load() async {
    if (_regular != null && _bold != null) return;

    final regularData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

    _regular = pw.Font.ttf(regularData);
    _bold = pw.Font.ttf(boldData);
  }

  static pw.Font get regular {
    assert(_regular != null, 'PdfFonts.load() لم يتم استدعاؤها بعد');
    return _regular!;
  }

  static pw.Font get bold {
    assert(_bold != null, 'PdfFonts.load() لم يتم استدعاؤها بعد');
    return _bold!;
  }

  static pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: regular, bold: bold);
}
