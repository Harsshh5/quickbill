import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
                  var list = invoiceListController.filteredList.toList();

                  return Skeletonizer(
                    enabled: invoiceListController.isLoading.value,
                    child: ListView.builder(
                      itemCount: list.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var invoices = list[index];
                        var amountColor = (invoices["status"] == "paid") ? Colors.green : Colors.red;

                        bool showHeader = false;
                        String headerText = "";

                        try {
                          DateTime currentDate = DateFormat("dd-MM-yyyy").parse(invoices["invoiceDate"]!);

                          headerText = DateFormat("MMMM yyyy").format(currentDate);

                          if (index == 0) {
                            showHeader = true;
                          } else {
                            DateTime prevDate = DateFormat("dd-MM-yyyy").parse(list[index - 1]["invoiceDate"]!);
                            String prevHeader = DateFormat("MMMM yyyy").format(prevDate);

                            if (headerText != prevHeader) {
                              showHeader = true;
                            }
                          }
                        } catch (e) {
                          showHeader = (index == 0);
                          headerText = "Recent";
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 8, left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      headerText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],

                            SlideTransition(
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Bill No. ${invoices["invoiceNumber"]!}",
                                                  style: appTextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  invoices["companyName"]!,
                                                  style: appTextStyle(fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(invoices["invoiceDate"]!, style: appTextStyle(fontSize: 14)),
                                          const SizedBox(width: 15),
                                          Text(
                                            invoiceListController.formatIndianCurrency(invoices["totalAmount"]!),
                                            style: appTextStyle(fontSize: 14, color: amountColor),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.chevron_right_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
    );
  }
}
