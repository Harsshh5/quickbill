import 'dart:convert';
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

  pw.Widget _pdfAmountRow(pw.Font ttf, String label, dynamic value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 14)),
        pw.SizedBox(width: 15),
        pw.Text(value.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 14)),
      ],
    );
  }

  Future<File> createPdf() async {
    final converter = AmountToWords();

    final fontData = await rootBundle.load("assets/fonts/Quicksand-Regular.ttf");
    final fontData2 = await rootBundle.load("assets/fonts/Quicksand-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final ttf2 = pw.Font.ttf(fontData2);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
            padding: const pw.EdgeInsets.symmetric(horizontal: 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  alignment: pw.Alignment.center,
                  padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text("SUBJECT TO SURAT JURISDICTION", style: pw.TextStyle(font: ttf, fontSize: 8)),
                      pw.Text(AppConstants.businessName, style: pw.TextStyle(font: ttf2, fontSize: 22)),
                      pw.SizedBox(height: 5),
                      (AppConstants.abbreviation == "AN") ? pw.Text(
                        "HSN CODE : 998821 | GST NO. 24ABNPR3829A1ZQ",
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(font: ttf2, fontSize: 10),
                      ) : pw.SizedBox(height: 0),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "406, 4th Floor, Midas Square, Parvatgam, Godadara Road, Surat - 395010",
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(font: ttf, fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "+91 9825654790 | dhirajratnaparkhi15@gmail.com",
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(font: ttf, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                (AppConstants.abbreviation == "AN") ? pw.Column(
                    children: [
                      pw.Divider(),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [pw.Text("TAX INVOICE", style: pw.TextStyle(font: ttf2, fontSize: 14))],
                      ),

                      pw.Divider()
                    ]
                ) : pw.Divider(),


                // Status + Invoice No
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Invoice To", style: pw.TextStyle(font: ttf2, fontSize: 16)),
                    pw.Text(
                      "Invoice #${ctrl.invoiceNo.value}",
                      style: pw.TextStyle(font: ttf2, fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [pw.Text("${ctrl.createDate}", style: pw.TextStyle(font: ttf, fontSize: 14))],
                ),

                pw.Text("${ctrl.companyName}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("${ctrl.clientName}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("+91-${ctrl.contact}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("${ctrl.address}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("${ctrl.gstNo}", style: pw.TextStyle(font: ttf, fontSize: 14)),

                pw.SizedBox(height: 14),

                pw.Divider(),

                // Table Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(width: 100, child: pw.Text("Item", style: pw.TextStyle(font: ttf2))),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text("Quantity", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text("Rate (₹)", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text("Amount (₹)", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),
                  ],
                ),

                pw.Divider(),

                // Items
                ...ctrl.designList.map((item) {
                  return pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // important for alignment
                        children: [
                          // First column with category and notes stacked vertically
                          pw.SizedBox(
                            width: 100,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "${item["designCategory"]}",
                                  style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  (jsonEncode(item["notes"]) == '""') ? "" : jsonDecode(item["notes"]!),
                                  style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
                                ),
                              ],
                            ),
                          ),

                          // Quantity column
                          pw.SizedBox(width: 80, child: pw.Text("${item["quantity"]}", style: pw.TextStyle(font: ttf))),

                          // Rate column
                          pw.SizedBox(width: 80, child: pw.Text("${item["rate"]}.0", style: pw.TextStyle(font: ttf))),

                          // Amount column
                          pw.SizedBox(width: 80, child: pw.Text("${item["amount"]}.0", style: pw.TextStyle(font: ttf))),
                        ],
                      ),
                      pw.Divider(color: PdfColors.grey),
                    ],
                  );
                }),

                pw.SizedBox(height: 20),

                // Amount Section
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _pdfAmountRow(ttf, "Sub Total", ctrl.subTotal.value),
                    if (AppConstants.abbreviation == "AN") ...[
                      _pdfAmountRow(ttf, "CGST ( 2.5% )", ctrl.cgst.value),
                      _pdfAmountRow(ttf, "SGST ( 2.5% )", ctrl.sgst.value),
                    ],
                    _pdfAmountRow(ttf2, "Final Total", ctrl.finalTotal.value),
                    pw.SizedBox(height: 10),
                    pw.Text("[ ${converter.convertAmountToWords(ctrl.finalTotal.value.toDouble())} Only ]"),
                  ],
                ),

                pw.Spacer(),

                pw.Divider(),

                pw.Row(
                  children: [
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Bank Details for NEFT & RTGS", style: pw.TextStyle(font: ttf2, fontSize: 14)),
                        pw.Text("Acc. No. 2480111071399", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text("IFSC: SUTB0248011", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text("THE SUTEX CO-OP BANK LTD", style: pw.TextStyle(font: ttf2, fontSize: 12)),
                        pw.Text("Parvat Patiya, Surat-10", style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
