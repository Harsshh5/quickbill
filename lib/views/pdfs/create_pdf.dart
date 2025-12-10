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
        pw.Text("₹ ${value.toStringAsFixed(2)} ", style: pw.TextStyle(font: ttf, fontSize: 14)),
      ],
    );
  }

  Future<File> createPdf() async {
    final converter = AmountToWords();

    String address = "";
    String codes = "";
    String contactDetails = "";

    if (AppConstants.abbreviation == "AN") {
      address = "406, 4th Floor, Midas Square, Parvatgam, Godadara Road, Surat - 395010";
      codes = "HSN CODE : 998821 | GST NO. 24ABNPR3829A1ZQ";
      contactDetails = "+91 9825654790 | dhirajratnaparkhi15@gmail.com";
    } else if (AppConstants.abbreviation == "VB") {
      address = "132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010";
      codes = "PAN : AAPPR0140R | UDHYAM-GJ-22-0212600";
      contactDetails = "+91 9825654790 | dhirajratnaparkhi15@gmail.com";
    } else if (AppConstants.abbreviation == "ED") {
      address = "132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010";
      codes = "PAN : AADHP0737L | UDHYAM-GJ-22-0212550";
      contactDetails = "+91 9825654790 | dhirajratnaparkhi15@gmail.com";
    } else if (AppConstants.abbreviation == "LA") {
      address = "132, Neminath Nagar, Parvat Patiya, Dumbhal, Surat - 395010";
      codes = "SAC CODE : 998391 | GST NO. 24CEVPR3580M1ZL | Udhyam : GJ-22-0213504";
      contactDetails = "+91 9016079197 | +91-9825654790 | harshratnaparkhi19@gmail.com";
    }

    final signatureImage = pw.MemoryImage((await rootBundle.load('assets/images/sign.png')).buffer.asUint8List());

    final fontData = await rootBundle.load("assets/fonts/Quicksand-Regular.ttf");
    final fontData2 = await rootBundle.load("assets/fonts/Quicksand-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final ttf2 = pw.Font.ttf(fontData2);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(margin: pw.EdgeInsets.all(16), pageFormat: PdfPageFormat.a4),
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
                      pw.Text(AppConstants.businessName, style: pw.TextStyle(font: ttf2, fontSize: 22)),
                      pw.SizedBox(height: 5),
                      pw.Text(codes, textAlign: pw.TextAlign.end, style: pw.TextStyle(font: ttf2, fontSize: 10)),
                      pw.SizedBox(height: 10),
                      pw.Text(address, textAlign: pw.TextAlign.end, style: pw.TextStyle(font: ttf, fontSize: 12)),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        contactDetails,
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(font: ttf, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                (AppConstants.abbreviation == "AN" || AppConstants.abbreviation == "LA")
                    ? pw.Column(
                      children: [
                        pw.Divider(),

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [pw.Text("TAX INVOICE", style: pw.TextStyle(font: ttf2, fontSize: 14))],
                        ),

                        pw.Divider(),
                      ],
                    )
                    : pw.Divider(),

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
                pw.Text("${ctrl.gstNo}", style: pw.TextStyle(font: ttf2, fontSize: 14)),

                pw.SizedBox(height: 14),

                pw.Divider(),

                pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text("Item", style: pw.TextStyle(font: ttf2))),

                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("Quantity", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),

                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("Rate (₹)", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),

                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("Amount (₹)", textAlign: pw.TextAlign.left, style: pw.TextStyle(font: ttf2)),
                    ),
                  ],
                ),

                pw.Divider(),

                ...ctrl.designList.map((item) {
                  final double baseAmount = double.tryParse(item["amountBeforeDiscount"]?.toString() ?? "0") ?? 0.0;
                  final double additional = double.tryParse(item["additionalCharges"]?.toString() ?? "0") ?? 0.0;
                  final double discount = double.tryParse(item["discountValue"]?.toString() ?? "0") ?? 0.0;
                  final double finalAmount = double.tryParse(item["amount"]?.toString() ?? "0") ?? 0.0;
                  final bool isPercentage = (item["discountMode"] == "percentage");

                  return pw.Column(
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "${item["designCategory"]}",
                                  style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  item["notes"] ?? "",
                                  style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
                                ),
                              ],
                            ),
                          ),

                          pw.Expanded(flex: 1, child: pw.Text("${item["quantity"]}", style: pw.TextStyle(font: ttf))),

                          pw.Expanded(flex: 1, child: pw.Text("${item["rate"]}.0", style: pw.TextStyle(font: ttf))),

                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end, // Aligns text to the right
                              children: [

                                // Base Amount
                                pw.Text(
                                  baseAmount.toStringAsFixed(2),
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),

                                // Additional Charges (Only show if > 0)
                                if (additional > 0)
                                  pw.Text(
                                    "₹ + ${additional.toStringAsFixed(2)}",
                                    style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
                                  ),

                                // Discount (Only show if > 0)
                                if (discount > 0)
                                  pw.Text(
                                    "${isPercentage ? '%' : '₹'} - ${discount.toStringAsFixed(2)}",
                                    style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
                                  ),

                                // Final Total (Only show if logic was applied)
                                if (additional > 0 || discount > 0) ...[
                                  pw.SizedBox(height: 2),
                                  pw.Divider(height: 1, thickness: 0.5), // Adds a calculation line
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    finalAmount.toStringAsFixed(2),
                                    style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold),
                                  ),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                      pw.Divider(color: PdfColors.grey),
                    ],
                  );
                }),

                pw.SizedBox(height: 20),

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _pdfAmountRow(ttf, "Sub Total", ctrl.subTotal.value),

                    // Check if abbreviation matches either condition
                    if (AppConstants.abbreviation == "AN" || AppConstants.abbreviation == "LA") ...[
                      _pdfAmountRow(
                          ttf,
                          "CGST ( ${AppConstants.abbreviation == "AN" ? "2.5%" : "9%"} )",
                          ctrl.cgst.value
                      ),
                      _pdfAmountRow(
                          ttf,
                          "SGST ( ${AppConstants.abbreviation == "AN" ? "2.5%" : "9%"} )",
                          ctrl.sgst.value
                      ),
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
                    (AppConstants.abbreviation == "AN")
                        ? pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Bank Details for NEFT & RTGS", style: pw.TextStyle(font: ttf2, fontSize: 14)),
                            pw.Text("Acc. No. 2480111071399", style: pw.TextStyle(font: ttf, fontSize: 12)),
                            pw.Text("IFSC: SUTB0248011", style: pw.TextStyle(font: ttf, fontSize: 12)),
                            pw.Text("THE SUTEX CO-OP BANK LTD", style: pw.TextStyle(font: ttf, fontSize: 12)),
                            pw.Text("Parvat Patiya, Surat-10", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          ],
                        )
                        : pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Bank Details for NEFT & RTGS", style: pw.TextStyle(font: ttf2, fontSize: 14)),
                        pw.Text("Acc. No. 00111021001747", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text("IFSC: SUTB0248011", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text("THE SUTEX CO-OP BANK LTD", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text("Parvat Patiya, Surat-10", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text("Pan No: CEVPR3580M", style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("For, ${AppConstants.businessName}", style: pw.TextStyle(font: ttf2, fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Image(signatureImage, height: 40, fit: pw.BoxFit.contain),
                        pw.Text("Proprietor", style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ],
                    ),
                  ],
                ),

                // pw.SizedBox(height: 10),

                pw.Divider(),

                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Terms and Conditions : ", style: pw.TextStyle(font: ttf2, fontSize: 12)),
                    pw.Text("~ Design once sold is not returned or taken back.", style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text("~ Payment within 30 days.", style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text("~ Subject to surat jurisdiction.", style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text("E. & O. E.", style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.SizedBox(height: 10),
                  ],
                ),
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
