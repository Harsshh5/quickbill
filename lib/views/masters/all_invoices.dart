import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_text_field.dart';

import '../commons/page_header.dart';
import '../commons/submit_button.dart';
import '../wrapper/recent_invoice_wrapper.dart';


class AllInvoices extends StatefulWidget {
  const AllInvoices({super.key});

  @override
  State<AllInvoices> createState() => _AllInvoicesState();
}

class _AllInvoicesState extends State<AllInvoices>
    with TickerProviderStateMixin {

  bool isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Column(
                children: [
                  CommonPageHeader(
                    mainHeading: "Invoice",
                    subHeading: "All Invoices",
                    onTap: () => Get.back(),
                    icon: Icons.chevron_left_rounded,
                  ),

                  const SizedBox(height: 20),

                  CommonTextField(
                    hintText: "Search",
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                  ),

                  const SizedBox(height: 20),

                  InvoiceListWrapper(
                    onRefresh: (){
                     return Future(() {});
                    },
                    itemCount: 20,
                    enableSelection: true,
                    billNo: "Bill No.",
                    companyName: "Company Name",
                    invoiceAmount: "10,000",
                    invoiceDate: "16-06-25",
                    onSelectionModeChange: (val) {
                      setState(() {
                        isSelectionMode = val;
                      });
                    },
                  ),

                ],
              ),
            ),
          ),

          if (isSelectionMode)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: CommonSubmit(data: 'Submit', onTap: () {
                    // Perform action on selected items
                  }),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
