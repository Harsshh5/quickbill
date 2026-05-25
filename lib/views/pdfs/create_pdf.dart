import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:indian_currency_to_word/indian_currency_to_word.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../config/app_constants.dart';
import '../../controller/invoice_controller/invoice_details.dart';

class CreatePdf {
  final InvoiceDetailsController ctrl = Get.put(InvoiceDetailsController());

  static const double _businessNameSize = 19;
  static const double _titleSize = 13;
  static const double _bodySize = 10.5;
  static const double _smallSize = 9;
  static const double _tinySize = 8;
  static const double _amountSize = 10.5;

  String get invoiceFileName {
    final abbreviation = AppConstants.abbreviation.toString().trim();
    final invoiceNumber = ctrl.invoiceNo.value.toString().trim();
    return _sanitizeFileName('$abbreviation-invoice-$invoiceNumber');
  }

  String _sanitizeFileName(String value) {
    final cleaned =
        value
            .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
            .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '-')
            .replaceAll(RegExp(r'\s+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '')
            .trim();

    return cleaned.isEmpty ? 'invoice-${ctrl.invoiceNo.value}' : cleaned;
  }

  pw.TextStyle _regular(
    pw.Font font, {
    double size = _bodySize,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      font: font,
      fontSize: size,
      color: color ?? PdfColors.black,
    );
  }

  pw.TextStyle _bold(pw.Font font, {double size = _bodySize, PdfColor? color}) {
    return pw.TextStyle(
      font: font,
      fontSize: size,
      fontWeight: pw.FontWeight.bold,
      color: color ?? PdfColors.black,
    );
  }

  pw.Widget _pdfAmountRow(
    pw.Font regularFont,
    pw.Font boldFont,
    String label,
    dynamic value, {
    bool isBold = false,
  }) {
    final num amount =
        value is num ? value : (num.tryParse(value.toString()) ?? 0);
    final font = isBold ? boldFont : regularFont;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style:
                isBold
                    ? _bold(font, size: _amountSize)
                    : _regular(font, size: _amountSize),
          ),
          pw.SizedBox(width: 12),
          pw.Text(
            '\u20B9 ${amount.toStringAsFixed(2)}',
            style:
                isBold
                    ? _bold(font, size: _amountSize)
                    : _regular(font, size: _amountSize),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Divider(height: 1, thickness: 0.6, color: PdfColors.grey600),
    );
  }

  pw.Widget _header({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required String address,
    required String codes,
    required String contactDetails,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: pw.Column(
            children: [
              pw.Text(
                AppConstants.businessName,
                textAlign: pw.TextAlign.center,
                style: _bold(boldFont, size: _businessNameSize),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                codes,
                textAlign: pw.TextAlign.center,
                style: _bold(boldFont, size: _tinySize),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                address,
                textAlign: pw.TextAlign.center,
                style: _regular(regularFont, size: _smallSize),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                contactDetails,
                textAlign: pw.TextAlign.center,
                style: _regular(regularFont, size: _tinySize),
              ),
            ],
          ),
        ),
        if (AppConstants.abbreviation == 'AN' ||
            AppConstants.abbreviation == 'LA') ...[
          _sectionDivider(),
          pw.Center(
            child: pw.Text(
              'TAX INVOICE',
              style: _bold(boldFont, size: _titleSize),
            ),
          ),
        ],
        _sectionDivider(),
      ],
    );
  }

  pw.Widget _invoiceInfo({
    required pw.Font regularFont,
    required pw.Font boldFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Invoice To', style: _bold(boldFont, size: _titleSize)),
            pw.Text(
              'Invoice - G/${ctrl.invoiceNo.value}',
              style: _bold(boldFont, size: 15),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            ctrl.createDate.value,
            style: _regular(regularFont, size: _bodySize),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(ctrl.companyName.value, style: _regular(regularFont)),
        pw.Text(ctrl.clientName.value, style: _regular(regularFont)),
        if (ctrl.contact.value.isNotEmpty)
          pw.Text('+91-${ctrl.contact.value}', style: _regular(regularFont)),
        if (ctrl.address.value.isNotEmpty)
          pw.Text(ctrl.address.value, style: _regular(regularFont)),
        if (ctrl.gstNo.value.isNotEmpty)
          pw.Text(ctrl.gstNo.value, style: _bold(boldFont)),
      ],
    );
  }

  pw.Widget _tableHeader({required pw.Font boldFont}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey600, width: 0.6),
          bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.6),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text('Item', style: _bold(boldFont, size: _smallSize)),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'Qty',
              textAlign: pw.TextAlign.center,
              style: _bold(boldFont, size: _smallSize),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              'Rate (\u20B9)',
              textAlign: pw.TextAlign.right,
              style: _bold(boldFont, size: _smallSize),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              'Amount (\u20B9)',
              textAlign: pw.TextAlign.right,
              style: _bold(boldFont, size: _smallSize),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _itemRow(
    Map<String, String> item, {
    required pw.Font regularFont,
    required pw.Font boldFont,
  }) {
    final double baseAmount =
        double.tryParse(item['amountBeforeDiscount']?.toString() ?? '0') ?? 0.0;
    final double additional =
        double.tryParse(item['additionalCharges']?.toString() ?? '0') ?? 0.0;
    final double discount =
        double.tryParse(item['discountValue']?.toString() ?? '0') ?? 0.0;
    final double finalAmount =
        double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
    final bool isPercentage = item['discountMode'] == 'percentage';
    final String notes = item['notes'] ?? '';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item['designCategory'] ?? '',
                  style: _bold(boldFont, size: _bodySize),
                ),
                if (notes.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    notes,
                    style: _regular(
                      regularFont,
                      size: _tinySize,
                      color: PdfColors.grey800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              item['quantity'] ?? '0',
              textAlign: pw.TextAlign.center,
              style: _regular(regularFont, size: _smallSize),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              '\u20B9 ${(double.tryParse(item['rate'] ?? '0') ?? 0).toStringAsFixed(2)}',
              textAlign: pw.TextAlign.right,
              style: _regular(regularFont, size: _smallSize),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  baseAmount.toStringAsFixed(2),
                  style: _regular(regularFont, size: _smallSize),
                ),
                if (additional > 0)
                  pw.Text(
                    '+ ${additional.toStringAsFixed(2)}',
                    style: _regular(
                      regularFont,
                      size: _tinySize,
                      color: PdfColors.grey700,
                    ),
                  ),
                if (discount > 0)
                  pw.Text(
                    '- ${discount.toStringAsFixed(2)}${isPercentage ? '%' : ''}',
                    style: _regular(
                      regularFont,
                      size: _tinySize,
                      color: PdfColors.grey700,
                    ),
                  ),
                if (additional > 0 || discount > 0) ...[
                  pw.SizedBox(height: 2),
                  pw.Container(
                    width: 55,
                    height: 0.5,
                    color: PdfColors.grey500,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    finalAmount.toStringAsFixed(2),
                    style: _bold(boldFont, size: _smallSize),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _totals({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required AmountToWords converter,
  }) {
    final int subTotal = ctrl.subTotal.value;
    final double cgst = ctrl.cgst.value;
    final double sgst = ctrl.sgst.value;
    final double totalWithTax = subTotal + cgst + sgst;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 270,
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _pdfAmountRow(regularFont, boldFont, 'Sub Total', subTotal),
            if (AppConstants.abbreviation == 'AN' ||
                AppConstants.abbreviation == 'LA') ...[
              _pdfAmountRow(
                regularFont,
                boldFont,
                'CGST (${AppConstants.abbreviation == 'AN' ? '2.5%' : '9%'})',
                cgst,
              ),
              _pdfAmountRow(
                regularFont,
                boldFont,
                'SGST (${AppConstants.abbreviation == 'AN' ? '2.5%' : '9%'})',
                sgst,
              ),
              _pdfAmountRow(regularFont, boldFont, 'Total', totalWithTax),
            ],
            pw.Divider(height: 8, thickness: 0.6, color: PdfColors.grey600),
            _pdfAmountRow(
              regularFont,
              boldFont,
              'Final Total',
              ctrl.finalTotal.value,
              isBold: true,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              '[ ${converter.convertAmountToWords(ctrl.finalTotal.value.toDouble())} Only ]',
              textAlign: pw.TextAlign.right,
              style: _regular(regularFont, size: _smallSize),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _bankDetails({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required pw.ImageProvider signatureImage,
  }) {
    final bool isAnFirm = AppConstants.abbreviation == 'AN';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionDivider(),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bank Details for NEFT & RTGS',
                    style: _bold(boldFont, size: _bodySize),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    isAnFirm
                        ? 'Acc. No. 2480111071399'
                        : 'Acc. No. 00111021001747',
                    style: _regular(regularFont, size: _smallSize),
                  ),
                  pw.Text(
                    'IFSC: SUTB0248011',
                    style: _regular(regularFont, size: _smallSize),
                  ),
                  pw.Text(
                    'THE SUTEX CO-OP BANK LTD',
                    style: _regular(regularFont, size: _smallSize),
                  ),
                  pw.Text(
                    'Parvat Patiya, Surat-10',
                    style: _regular(regularFont, size: _smallSize),
                  ),
                  if (!isAnFirm) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Pan No: CEVPR3580M',
                      style: _regular(regularFont, size: _smallSize),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'For, ${AppConstants.businessName}',
                    textAlign: pw.TextAlign.right,
                    style: _bold(boldFont, size: _smallSize),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Image(signatureImage, height: 38, fit: pw.BoxFit.contain),
                  pw.Text(
                    'Proprietor',
                    style: _regular(regularFont, size: _smallSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _terms({required pw.Font regularFont, required pw.Font boldFont}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionDivider(),
        pw.Text(
          'Terms and Conditions:',
          style: _bold(boldFont, size: _smallSize),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '1. Design once sold is not returned or taken back.',
          style: _regular(regularFont, size: _smallSize),
        ),
        pw.Text(
          '2. Payment within 30 days.',
          style: _regular(regularFont, size: _smallSize),
        ),
        pw.Text(
          '3. Subject to Surat jurisdiction.',
          style: _regular(regularFont, size: _smallSize),
        ),
        pw.SizedBox(height: 3),
        pw.Text('E. & O. E.', style: _regular(regularFont, size: _smallSize)),
      ],
    );
  }

  pw.Widget _scalableInvoiceBody({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required AmountToWords converter,
    required double width,
  }) {
    return pw.FittedBox(
      fit: pw.BoxFit.scaleDown,
      alignment: pw.Alignment.topCenter,
      child: pw.Container(
        width: width,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _invoiceInfo(regularFont: regularFont, boldFont: boldFont),
            pw.SizedBox(height: 10),
            _tableHeader(boldFont: boldFont),
            ...ctrl.designList.map(
              (item) =>
                  _itemRow(item, regularFont: regularFont, boldFont: boldFont),
            ),
            _totals(
              regularFont: regularFont,
              boldFont: boldFont,
              converter: converter,
            ),
          ],
        ),
      ),
    );
  }

  Future<File> createPdf({String? fileName}) async {
    final converter = AmountToWords();

    String address = '';
    String codes = '';
    String contactDetails = '';

    if (AppConstants.abbreviation == 'AN') {
      address =
          '406, 4th Floor, Midas Square, Parvatgam, Godadara Road, Surat - 395010';
      codes = 'HSN CODE : 998821 | GST NO. 24ABNPR3829A1ZQ';
      contactDetails = '+91 9825654790 | dhirajratnaparkhi15@gmail.com';
    } else if (AppConstants.abbreviation == 'VB') {
      address = '132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010';
      codes = 'PAN : AAPPR0140R | UDHYAM-GJ-22-0212600';
      contactDetails = '+91 9825654790 | dhirajratnaparkhi15@gmail.com';
    } else if (AppConstants.abbreviation == 'ED') {
      address = '132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010';
      codes = 'PAN : AADHP0737L | UDHYAM-GJ-22-0212550';
      contactDetails = '+91 9825654790 | dhirajratnaparkhi15@gmail.com';
    } else if (AppConstants.abbreviation == 'LA') {
      address = '132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010';
      codes =
          'SAC CODE : 998391 | GST NO. 24CEVPR3580M1ZL | Udhyam : GJ-22-0213504';
      contactDetails =
          '+91 9016079197 | +91-9825654790 | harshratnaparkhi19@gmail.com';
    }

    final signatureImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/sign.png')).buffer.asUint8List(),
    );

    final fontData = await rootBundle.load(
      'assets/fonts/Quicksand-Regular.ttf',
    );
    final fontData2 = await rootBundle.load('assets/fonts/Quicksand-Bold.ttf');
    final regularFont = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(fontData2);

    final pdf = pw.Document();
    final contentWidth = PdfPageFormat.a4.width - 44;

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(22),
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                margin: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.7),
                ),
              ),
            );
          },
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _header(
                regularFont: regularFont,
                boldFont: boldFont,
                address: address,
                codes: codes,
                contactDetails: contactDetails,
              ),
              pw.Expanded(
                child: pw.Container(
                  alignment: pw.Alignment.topCenter,
                  child: _scalableInvoiceBody(
                    regularFont: regularFont,
                    boldFont: boldFont,
                    converter: converter,
                    width: contentWidth,
                  ),
                ),
              ),
              _bankDetails(
                regularFont: regularFont,
                boldFont: boldFont,
                signatureImage: signatureImage,
              ),
              _terms(regularFont: regularFont, boldFont: boldFont),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final safeFileName = _sanitizeFileName(fileName ?? invoiceFileName);
    final file = File('${output.path}/$safeFileName.pdf');

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
