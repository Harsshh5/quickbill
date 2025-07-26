import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/page_header.dart';

import '../../controller/invoice_controller/invoice_details.dart';

class InvoiceDetails extends StatelessWidget {
  InvoiceDetails({super.key});

  final InvoiceDetailsController invoiceDetailsController = Get.put(InvoiceDetailsController());

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
            ],
          ),
        ),
      ),
    );
  }
}
