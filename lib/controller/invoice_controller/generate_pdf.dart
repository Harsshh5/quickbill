import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePdfPage extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const InvoicePdfPage({super.key, required this.invoiceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Preview")),
      body: PdfPreview(
        build: (format) => _generatePdf(format, invoiceData),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Invoice", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Text("Invoice No: ${data['invoiceNo'] ?? 'N/A'}"),
              pw.Text("Client: ${data['clientName'] ?? 'N/A'}"),
              pw.Text("Amount: ₹${data['amount'] ?? 0.0}"),
              pw.SizedBox(height: 20),
              pw.Text("Items:"),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                // Safely cast and map items, handling potential nulls or wrong types
                children: (data['items'] as List<dynamic>?)
                    ?.map((item) => pw.Text("- ${item.toString()}"))
                    .toList() ??
                    [pw.Text("No items found.")],
              ),
            ],
          ),
        ),
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }
}