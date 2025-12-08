import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/invoice_controller/invoice_list.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../commons/card_container.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';
import '../../../controller/home_widget_animations/list_animation_controller.dart';
import 'invoice_details.dart';

class AllInvoices extends StatefulWidget {
  const AllInvoices({super.key});

  @override
  State<AllInvoices> createState() => _AllInvoicesState();
}

class _AllInvoicesState extends State<AllInvoices> with TickerProviderStateMixin {
  late ListAnimationControllerHelper animController;

  var invoiceCount = Get.arguments["invoiceCount"];

  final InvoiceListController invoiceListController = Get.put(InvoiceListController());

  @override
  void initState() {
    super.initState();
    animController = ListAnimationControllerHelper(vsync: this, itemCount: invoiceCount);
  }

  void handleTap(int index) async {
    await animController.listControllers[index].forward();
    await animController.listControllers[index].reverse();
  }

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
                    onChanged: (p0) {
                      invoiceListController.filterItems(p0);
                    },
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                  ),

                  const SizedBox(height: 20),

                  invoicesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget invoicesList() {
    return Expanded(
      child:
          invoiceCount == 0
              ? Center(child: Text("No Invoices Found", style: appTextStyle(color: Colors.grey)))
              : RefreshIndicator(
                backgroundColor: Colors.white,
                color: AppColors.dark,
                onRefresh: () {
                  return invoiceListController.getInvoiceList();
                },
                child: Obx(() {
                  return Skeletonizer(
                    enabled: invoiceListController.isLoading.value,
                    child: ListView.builder(
                      itemCount: invoiceListController.filteredList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var invoices = invoiceListController.filteredList[index];
                        var amountColor = (invoices["status"] == "paid") ? Colors.green : Colors.red;

                        return SlideTransition(
                          position: animController.listSlideAnimation[index],
                          child: FadeTransition(
                            opacity: animController.listFadeAnimation[index],
                            child: ScaleTransition(
                              scale: animController.listAnimations[index],
                              child: GestureDetector(
                                onTap: () {
                                  handleTap(index);
                                  Get.to(
                                    () => InvoiceDetails(),
                                    arguments: {"invoiceId": invoices["id"], "invoiceCount": invoiceCount},
                                  );
                                },
                                child: CommonCardContainer(
                                  height: 80,
                                  width: Get.width,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Bill No. ${invoices["invoiceNumber"]!}",
                                            style: appTextStyle(fontSize: 16),
                                          ),
                                          Text(invoices["companyName"]!, style: appTextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(invoices["invoiceDate"]!, style: appTextStyle(fontSize: 16)),
                                      const SizedBox(width: 15),
                                      Text(
                                        invoiceListController.formatIndianCurrency(invoices["totalAmount"]!),
                                        style: appTextStyle(fontSize: 16, color: amountColor),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.chevron_right_rounded),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
    );
  }
}
