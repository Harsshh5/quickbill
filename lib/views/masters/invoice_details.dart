import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/invoice_controller/invoice_details.dart';

class InvoiceDetails extends StatelessWidget {
  InvoiceDetails({super.key});

  final InvoiceDetailsController ctrl = Get.put(InvoiceDetailsController());

  Widget _buildAmountRow(String label, dynamic amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "$label: ₹$amount",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Invoice",
                subHeading: "Invoice Details",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonCardContainer(
                    height: 60,
                    width: Get.width / 4.8,
                    alignment: Alignment.center,
                    child: Text("Download", style: appTextStyle(fontSize: 14)),
                  ),
                  CommonCardContainer(
                    height: 60,
                    width: Get.width / 4.8,
                    alignment: Alignment.center,
                    child: Text("Preview", style: appTextStyle(fontSize: 14)),
                  ),
                  CommonCardContainer(
                    height: 60,
                    width: Get.width / 4.8,
                    alignment: Alignment.center,
                    child: Text("Share", style: appTextStyle(fontSize: 14)),
                  ),
                  CommonCardContainer(
                    height: 60,
                    width: Get.width / 4.8,
                    alignment: Alignment.center,
                    child: Text("Edit", style: appTextStyle(fontSize: 14)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Obx(() {
                return Skeletonizer(
                  enabled: ctrl.designList.isEmpty,
                  child: CommonCardContainer(
                    width: Get.width,
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

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
                            Spacer(),
                            Text(
                              "Invoice #${ctrl.invoiceNo.value}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text("${ctrl.createDate}", style: TextStyle(fontSize: 14))],
                        ),
                        Text("Invoice To", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${ctrl.companyName}", style: TextStyle(fontSize: 14)),
                        Text("${ctrl.clientName}", style: TextStyle(fontSize: 14)),
                        Text("+91-${ctrl.contact}", style: TextStyle(fontSize: 14)),
                        Text("${ctrl.address}", style: TextStyle(fontSize: 14)),
                        Text("${ctrl.gstNo}", style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  SizedBox(
                                    width: 100,
                                    child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              ...ctrl.designList.map((item) {
                                return Row(
                                  children: [
                                    SizedBox(width: 100, child: Text("${item["designCategory"]}")),
                                    SizedBox(width: 80, child: Text("${item["quantity"]}")),
                                    SizedBox(width: 80, child: Text("${item["rate"]}.0")),
                                    SizedBox(width: 80, child: Text("${item["amount"]}.0")),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildAmountRow("Sub Total", ctrl.subTotal.value),

                            if (AppConstants.abbreviation == "AN") ...[
                              _buildAmountRow("CGST", ctrl.cgst.value),
                              _buildAmountRow("SGST", ctrl.sgst.value),
                            ],

                            _buildAmountRow("Final Total", ctrl.finalTotal.value),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
