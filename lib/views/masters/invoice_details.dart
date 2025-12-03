import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:quickbill/views/masters/preview_pdf.dart';
import 'package:quickbill/views/pdfs/create_pdf.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/invoice_controller/invoice_details.dart';
import '../pdfs/download_pdf.dart';

class InvoiceDetails extends StatelessWidget {
  InvoiceDetails({super.key});

  final InvoiceDetailsController ctrl = Get.put(InvoiceDetailsController());
  final abb = AppConstants.abbreviation;

  Widget _buildAmountRow(String label, dynamic amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            "₹${double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount}",
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Invoice",
                subHeading: "Invoice Details",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.deepPurpleAccent.shade100,
                    radius: 50, borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      downloadPdf("$abb-Invoice-${ctrl.invoiceNo.value}");
                    },
                    child: CommonCardContainer(
                      height: 60,
                      width: Get.width / 3.5,
                      alignment: Alignment.center,
                      child: Text("Download\nPDF", textAlign: TextAlign.center, style: appTextStyle(fontSize: 14)),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.deepPurpleAccent.shade100,
                    radius: 50, borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      final pdfFile = await CreatePdf().createPdf();
                      Get.to(() => PreviewPdf(pdfPath: pdfFile.path));
                    },
                    child: CommonCardContainer(
                      height: 60,
                      width: Get.width / 3.5,
                      alignment: Alignment.center,
                      child: Text("Preview\nPDF", textAlign: TextAlign.center, style: appTextStyle(fontSize: 14)),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.deepPurpleAccent.shade100,
                    radius: 50, borderRadius: BorderRadius.circular(24),
                    onTap: () {},
                    child: CommonCardContainer(
                      height: 60,
                      width: Get.width / 3.5,
                      alignment: Alignment.center,
                      child: Text("Edit\nInvoice", textAlign: TextAlign.center, style: appTextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Main Content ---
              Expanded( // Added Expanded to allow scrolling if content is long
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Skeletonizer(
                      enabled: ctrl.designList.isEmpty,
                      child: CommonCardContainer(
                        width: Get.width,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Header Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    ctrl.status.value = ctrl.status.value == "Paid" ? "Unpaid" : "Paid";
                                  },
                                  child: CommonCardContainer(
                                    height: 30,
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      ctrl.status.value.capitalizeFirst!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ctrl.status.value == "Paid" ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Invoice #${ctrl.invoiceNo.value}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Text("${ctrl.createDate}", style: const TextStyle(fontSize: 14))],
                            ),

                            const Text("Invoice To", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("${ctrl.companyName}", style: const TextStyle(fontSize: 14)),
                            Text("${ctrl.clientName}", style: const TextStyle(fontSize: 14)),
                            if(ctrl.contact.isNotEmpty) Text("+91-${ctrl.contact}", style: const TextStyle(fontSize: 14)),
                            if(ctrl.address.isNotEmpty) Text("${ctrl.address}", style: const TextStyle(fontSize: 14)),
                            if(ctrl.gstNo.isNotEmpty) Text("GST: ${ctrl.gstNo}", style: const TextStyle(fontSize: 14)),

                            const SizedBox(height: 20),
                            const Divider(),

                            // --- Items Table ---
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      SizedBox(width: 110, child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 60, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 80, child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 100, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right,)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  ...ctrl.designList.map((item) {
                                    // Parse values for display logic
                                    final double additional = double.tryParse(item["additionalCharges"] ?? "0") ?? 0;
                                    final double discount = double.tryParse(item["discount"] ?? "0") ?? 0;
                                    final bool isPercentage = item["discountMode"] == "percentage";
                                    final String amountBefore = double.tryParse(item["amountBeforeDiscount"] ?? "0")?.toStringAsFixed(2) ?? "0";
                                    final String finalAmt = double.tryParse(item["amount"] ?? "0")?.toStringAsFixed(2) ?? "0";

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Column 1: Item & Notes
                                          SizedBox(
                                              width: 110,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${item["designCategory"]}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                                  if((item["notes"] ?? "").isNotEmpty)
                                                    Text(
                                                        "(${item["notes"]})",
                                                        style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic)
                                                    ),
                                                ],
                                              )
                                          ),
                                          // Column 2: Qty
                                          SizedBox(width: 60, child: Text("${item["quantity"]}")),
                                          // Column 3: Rate
                                          SizedBox(width: 80, child: Text("₹${item["rate"]}")),
                                          // Column 4: Amount Calculation
                                          SizedBox(
                                              width: 100,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(amountBefore, style: const TextStyle(fontSize: 12)),

                                                  if(additional > 0)
                                                    Text("+ $additional", style: TextStyle(fontSize: 10, color: Colors.grey[700])),

                                                  if(discount > 0)
                                                    Text("- ${discount.toStringAsFixed(2)}${isPercentage ? '%' : ''}", style: TextStyle(fontSize: 10, color: Colors.grey[700])),

                                                  if(additional > 0 || discount > 0) ...[
                                                    const Divider(height: 4, thickness: 0.5),
                                                    Text(finalAmt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  ]
                                                ],
                                              )
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const Divider(),
                            const SizedBox(height: 10),

                            // --- Totals Section ---
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildAmountRow("Sub Total", ctrl.subTotal.value),

                                // Show Tax for BOTH "AN" and "LA"
                                if (abb == "AN" || abb == "LA") ...[
                                  _buildAmountRow(
                                      "CGST (${abb == "AN" ? "2.5%" : "9%"})",
                                      ctrl.cgst.value
                                  ),
                                  _buildAmountRow(
                                      "SGST (${abb == "AN" ? "2.5%" : "9%"})",
                                      ctrl.sgst.value
                                  ),
                                ],

                                const SizedBox(height: 5),
                                Container(height: 1, width: 200, color: Colors.black12),
                                const SizedBox(height: 5),

                                _buildAmountRow("Final Total", ctrl.finalTotal.value, isBold: true),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}