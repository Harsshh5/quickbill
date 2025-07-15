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

class AddInvoice extends StatelessWidget {
  AddInvoice({super.key});

  final AddInvoiceController controller = Get.put(AddInvoiceController());
  final ClientListController clientListController = Get.put(ClientListController());

  Widget buildDesignCard(int index) {
    final data = controller.designCardList[index];
    return CommonCardContainer(
      cardMargin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      width: Get.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Design ${index + 1}", style: appTextStyle(fontSize: 16)),
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
                    // CommonTextField(hintText: "Category", controller: data.category),
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
                      onChanged: (_) => controller.calculateAmount(data),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
          Row(
            children: [
              Expanded(
                child: Column(
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
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Company", style: TextStyle(fontSize: 20)),
              SizedBox(height: 10,),
              CommonTextField(
                hintText: "Search",
                suffixIcon: Icon(Icons.search, color: Colors.black),
                onChanged: (p0) {
                  clientListController.filterItems(p0);
                },
              ),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: clientListController.filteredList.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
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
                        CommonCardContainer(
                          width: Get.width,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonFromHeading(data: "Invoice No."),
                              Row(
                                children: [
                                  CommonFromHeading(data: "Invoice Date"),
                                  Spacer(),
                                  CommonFromHeading(data: formattedDate),
                                ],
                              ),
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                              CommonFromHeading(data: "Company"),
                              SizedBox(height: 10),
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
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text("Design Details", style: appTextStyle(fontSize: 18)),
                            const Spacer(),
                            GestureDetector(
                              onTap: controller.addDesignCard,
                              child: CommonIconCardContainer(
                                height: 40,
                                width: 40,
                                child: const Icon(Icons.add, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(controller.designCardList.length, buildDesignCard),
                        const SizedBox(height: 20),
                        CommonCardContainer(
                          width: Get.width,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSummaryRow("Subtotal", controller.subtotal.value),
                              (AppConstants.abbreviation == "AN")
                                  ? buildSummaryRow("CGST (2.5%)", controller.cgst.value)
                                  : SizedBox.shrink(),
                              (AppConstants.abbreviation == "AN")
                                  ? buildSummaryRow("SGST (2.5%)", controller.sgst.value)
                                  : SizedBox.shrink(),
                              const Divider(thickness: 1.5),
                              buildSummaryRow("Final Total", controller.finalTotal.value, isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        CommonSubmit(onTap: () {
                          controller.createInvoice();
                        }, data: "Submit"),
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
