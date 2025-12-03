import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/client_controller/client_list.dart';
import 'package:quickbill/controller/invoice_controller/add_invoice.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/drop_down.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/submit_button.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

import '../../controller/invoice_controller/latest_invoice_number.dart';

class AddInvoice extends StatelessWidget {
  AddInvoice({super.key});

  final AddInvoiceController controller = Get.put(AddInvoiceController());
  final ClientListController clientListController = Get.put(ClientListController());
  final LatestInvoiceNumberController latestInvoiceNumberController = Get.put(LatestInvoiceNumberController());

  Widget buildDesignCard(int index) {
    if (index >= controller.designCardList.length) return const SizedBox();

    final data = controller.designCardList[index];
    return CommonCardContainer(
      cardMargin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      width: Get.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Design Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Design ${index + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (controller.designCardList.length > 1)
                GestureDetector(
                  onTap: () => controller.removeDesignCard(index),
                  child: CommonIconCardContainer(
                    height: 35,
                    width: 35,
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // Row 1: Category & Total Designs
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Category"),
                    const SizedBox(height: 6),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(22)),
                      child: CommonDropDown(
                        dropdownMenuEntries: controller.categoryDropdownEntries,
                        width: Get.width / 2.5,
                        initialSelection: data.category,
                        hintText: "Category",
                        borderSideBorder: BorderSide.none,
                        borderSideEnable: BorderSide.none,
                        borderSideFocused: BorderSide.none,
                        onSelected: (p0) {
                          data.category = p0;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Total Designs"),
                    const SizedBox(height: 6),
                    CommonTextField(
                      hintText: "Total Designs",
                      controller: data.totalDesigns,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => controller.calculateAmount(data),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Row 2: Rate & Amount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Rate"),
                    const SizedBox(height: 6),
                    CommonTextField(
                      hintText: "Rate",
                      controller: data.rate,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => controller.calculateAmount(data),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Amount"),
                    const SizedBox(height: 6),
                    CommonTextField(hintText: "Amount", controller: data.amount, readOnly: true),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Row 3: Discount & Notes (Updated Section)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DISCOUNT FIELD ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Discount"),
                    const SizedBox(height: 6),
                    Obx(
                      () => CommonTextField(
                        hintText: "0",
                        controller: data.discountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => controller.calculateAmount(data),
                        suffixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VerticalDivider(color: Colors.grey.shade400, indent: 8, endIndent: 8, thickness: 1),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: data.discountType.value,
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                    style: appTextStyle(color: Colors.black, fontSize: 14),
                                    borderRadius: BorderRadius.circular(20),
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        data.discountType.value = newValue;
                                        controller.calculateAmount(data);
                                      }
                                    },
                                    items:
                                        <String>['percentage', 'amount'].map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value == "percentage" ? "%" : "₹",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // --- Additional Amount Field ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Additional Amount"),
                    const SizedBox(height: 6),
                    CommonTextField(
                      hintText: "Add. Amt.",
                      controller: data.additionalAMT,
                      onChanged: (_) => controller.calculateAmount(data),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonFromHeading(data: "Notes"),
              const SizedBox(height: 6),
              CommonTextField(
                hintText: "Notes",
                controller: data.note,
                onChanged: (_) => controller.calculateAmount(data),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "₹ ${value.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Future showCompanyList() {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: Get.context!,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          height: Get.height / 2,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Company", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              CommonTextField(
                hintText: "Search",
                suffixIcon: const Icon(Icons.search, color: Colors.black),
                onChanged: (p0) {
                  clientListController.filterItems(p0);
                },
              ),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: clientListController.filteredList.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Skeletonizer(
                        enabled: clientListController.isLoading.value,
                        child: ListTile(
                          title: Text(clientListController.filteredList[index]["companyName"]!),
                          subtitle: Text(clientListController.filteredList[index]["clientName"]!),
                          onTap: () {
                            controller.company.text = clientListController.filteredList[index]["companyName"]!;
                            controller.clientId.text = clientListController.filteredList[index]["id"]!;
                            Get.back();
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM y').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Invoice",
                subHeading: "Add New Invoice",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    controller: controller.scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- COMPANY DETAILS SECTION ---
                        CommonCardContainer(
                          width: Get.width,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CommonFromHeading(data: "Invoice No."),
                                  const Spacer(),
                                  Obx(() {
                                    return CommonFromHeading(
                                      data: "${latestInvoiceNumberController.latestNumber.value}",
                                    );
                                  }),
                                ],
                              ),
                              Row(
                                children: [
                                  const CommonFromHeading(data: "Invoice Date"),
                                  const Spacer(),
                                  CommonFromHeading(data: formattedDate),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              const CommonFromHeading(data: "Company"),
                              const SizedBox(height: 10),
                              CommonTextField(
                                autofocus: true,
                                hintText: "Company",
                                readOnly: true,
                                controller: controller.company,
                                onTap: () {
                                  showCompanyList();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- HEADER FOR DESIGN DETAILS ---
                        Row(
                          children: [
                            Text("Design Details", style: appTextStyle(fontSize: 18)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                controller.addDesignCard();

                                Future.delayed(const Duration(milliseconds: 100), () {
                                  if (controller.pageController.hasClients) {
                                    controller.pageController.animateToPage(
                                      controller.designCardList.length - 1,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                });
                              },
                              child: CommonIconCardContainer(
                                height: 40,
                                width: 40,
                                child: const Icon(Icons.add, color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        // --- NAVIGATION ARROWS & COUNTER ---
                        Obx(() {
                          if (controller.designCardList.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: controller.currentCardIndex.value > 0 ? Colors.black : Colors.grey[400],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    "${controller.currentCardIndex.value + 1} / ${controller.designCardList.length}",
                                    style: appTextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    controller.pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color:
                                        controller.currentCardIndex.value < controller.designCardList.length - 1
                                            ? Colors.black
                                            : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // --- HORIZONTAL LIST (ExpandablePageView) ---
                        Obx(() {
                          if (controller.designCardList.isEmpty) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(20.0), child: Text("Click + to add items")),
                            );
                          }

                          return ExpandablePageView.builder(
                            controller: controller.pageController,
                            itemCount: controller.designCardList.length,
                            onPageChanged: (index) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.currentCardIndex.value = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return buildDesignCard(index);
                            },
                          );
                        }),

                        const SizedBox(height: 20),

                        // --- SUMMARY SECTION ---
                        CommonCardContainer(
                          width: Get.width,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSummaryRow("Subtotal", controller.subtotal.value),
                              (AppConstants.abbreviation == "AN")
                                  ? buildSummaryRow("CGST (2.5%)", controller.cgst.value)
                                  : (AppConstants.abbreviation == "LA")
                                  ? buildSummaryRow("CGST (9%)", controller.cgst.value)
                                  : const SizedBox.shrink(),
                              (AppConstants.abbreviation == "AN")
                                  ? buildSummaryRow("SGST (2.5%)", controller.sgst.value)
                                  : (AppConstants.abbreviation == "LA")
                                  ? buildSummaryRow("SGST (9%)", controller.sgst.value)
                                  : const SizedBox.shrink(),
                              const Divider(thickness: 1.5),
                              buildSummaryRow("Final Total", controller.finalTotal.value, isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        CommonSubmit(
                          onTap: () {
                            controller.createInvoice();
                          },
                          data: "Submit",
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
