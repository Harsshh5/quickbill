import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/client_controller/client_list.dart';
import 'package:quickbill/controller/invoice_controller/edit_invoice.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/drop_down.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/submit_button.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EditInvoice extends StatelessWidget {
  EditInvoice({super.key});

  final EditInvoiceController controller = Get.put(EditInvoiceController());
  final ClientListController clientListController = Get.put(
    ClientListController(),
  );

  final List<TextInputFormatter> numberFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  Widget _lockedValue(String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonFromHeading(data: label),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Locked",
                  style: appTextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonCardContainer(
            height: 50,
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: appTextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Design ${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
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
                          data.categoryError.value = '';
                        },
                      ),
                    ),
                    Obx(
                      () =>
                          data.categoryError.value.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  top: 3,
                                ),
                                child: Text(
                                  data.categoryError.value,
                                  style: appTextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
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
                    Obx(
                      () => CommonTextField(
                        hintText: "Total Designs",
                        controller: data.totalDesigns,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        errorText:
                            data.quantityError.value.isEmpty
                                ? null
                                : data.quantityError.value,
                        onChanged: (_) {
                          data.quantityError.value = '';
                          controller.calculateAmount(data);
                        },
                      ),
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
                    Obx(
                      () => CommonTextField(
                        hintText: "Rate",
                        controller: data.rate,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: numberFormatter,
                        errorText:
                            data.rateError.value.isEmpty
                                ? null
                                : data.rateError.value,
                        onChanged: (_) {
                          data.rateError.value = '';
                          controller.calculateAmount(data);
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
                    Row(
                      children: [
                        const CommonFromHeading(data: "Amount"),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Auto",
                            style: appTextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CommonTextField(
                      hintText: "Amount",
                      controller: data.amount,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: numberFormatter,
                        errorText:
                            data.discountError.value.isEmpty
                                ? null
                                : data.discountError.value,
                        onChanged: (_) {
                          data.discountError.value = '';
                          controller.calculateAmount(data);
                        },
                        suffixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VerticalDivider(
                                color: Colors.grey.shade400,
                                indent: 8,
                                endIndent: 8,
                                thickness: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: data.discountType.value,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    style: appTextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        data.discountType.value = newValue;
                                        data.discountError.value = '';
                                        controller.calculateAmount(data);
                                      }
                                    },
                                    items:
                                        <String>[
                                          'percentage',
                                          'amount',
                                        ].map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value == "percentage"
                                                  ? "%"
                                                  : "Rs.",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonFromHeading(data: "Additional Amount"),
                    const SizedBox(height: 6),
                    Obx(
                      () => CommonTextField(
                        hintText: "Add. Amt.",
                        controller: data.additionalAMT,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: numberFormatter,
                        errorText:
                            data.additionalAmountError.value.isEmpty
                                ? null
                                : data.additionalAmountError.value,
                        onChanged: (_) {
                          data.additionalAmountError.value = '';
                          controller.calculateAmount(data);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const CommonFromHeading(data: "Notes"),
          const SizedBox(height: 6),
          CommonTextField(hintText: "Notes", controller: data.note),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rs. ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future showCompanyList() {
    clientListController.filterItems("");
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: Get.height / 2,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Company",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                  if (clientListController.filteredList.isEmpty &&
                      !clientListController.isLoading.value) {
                    return const Center(child: Text("No clients found"));
                  }

                  return Skeletonizer(
                    enabled: clientListController.isLoading.value,
                    child: ListView.builder(
                      itemCount:
                          clientListController.isLoading.value
                              ? 5
                              : clientListController.filteredList.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (clientListController.isLoading.value) {
                          return const ListTile(
                            title: Text("Loading..."),
                            subtitle: Text("Loading..."),
                          );
                        }

                        final item = clientListController.filteredList[index];
                        return ListTile(
                          title: Text(item["companyName"] ?? ""),
                          subtitle: Text(item["clientName"] ?? ""),
                          onTap: () {
                            controller.company.text = item["companyName"] ?? "";
                            controller.clientId.text = item["id"] ?? "";
                            controller.companyError.value = '';
                            Get.back();
                          },
                        );
                      },
                    ),
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
    void showExitConfirmation() {
      Get.defaultDialog(
        radius: 22,
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 10),
        title: "Discard Invoice?",
        titleStyle: appTextStyle(),
        content: const Column(
          children: [
            Divider(),
            SizedBox(height: 20),
            Text(
              "You have unsaved changes. Are you sure you want to discard them?",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Keep Editing"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          showExitConfirmation();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: [
                CommonPageHeader(
                  mainHeading: "Invoice",
                  subHeading: "Edit Invoice",
                  onTap: () => showExitConfirmation(),
                  icon: Icons.chevron_left_rounded,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.designCardList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }

                    return SingleChildScrollView(
                      controller: controller.scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonCardContainer(
                            width: Get.width,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _lockedValue(
                                      "Invoice No.",
                                      controller.invoiceNumber.value.toString(),
                                    ),
                                    const SizedBox(width: 16),
                                    _lockedValue(
                                      "Status",
                                      controller.status.value.capitalizeFirst ??
                                          "",
                                      valueColor:
                                          controller.status.value == "paid"
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const CommonFromHeading(
                                      data: "Invoice Date",
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        controller.selectDate(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Obx(
                                              () => CommonFromHeading(
                                                data: DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(
                                                  controller.invoiceDate.value,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 10),
                                const CommonFromHeading(data: "Company"),
                                const SizedBox(height: 10),
                                Obx(
                                  () => CommonTextField(
                                    autofocus: false,
                                    hintText: "Company",
                                    readOnly: true,
                                    controller: controller.company,
                                    errorText:
                                        controller.companyError.value.isEmpty
                                            ? null
                                            : controller.companyError.value,
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                    onTap: () {
                                      showCompanyList();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "Design Details",
                                style: appTextStyle(fontSize: 18),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  controller.addDesignCard();
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      if (controller
                                          .pageController
                                          .hasClients) {
                                        controller.pageController.animateToPage(
                                          controller.designCardList.length - 1,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  );
                                },
                                child: CommonIconCardContainer(
                                  height: 40,
                                  width: 40,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            if (controller.designCardList.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed:
                                        controller.currentCardIndex.value > 0
                                            ? () {
                                              controller.pageController
                                                  .previousPage(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                  );
                                            }
                                            : null,
                                    icon: Icon(
                                      Icons.chevron_left,
                                      color:
                                          controller.currentCardIndex.value > 0
                                              ? Colors.black
                                              : Colors.grey[400],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      "${controller.currentCardIndex.value + 1} / ${controller.designCardList.length}",
                                      style: appTextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        controller.currentCardIndex.value <
                                                controller
                                                        .designCardList
                                                        .length -
                                                    1
                                            ? () {
                                              controller.pageController
                                                  .nextPage(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                  );
                                            }
                                            : null,
                                    icon: Icon(
                                      Icons.chevron_right,
                                      color:
                                          controller.currentCardIndex.value <
                                                  controller
                                                          .designCardList
                                                          .length -
                                                      1
                                              ? Colors.black
                                              : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Obx(() {
                            if (controller.designCardList.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("Click + to add items"),
                                ),
                              );
                            }

                            return ExpandablePageView.builder(
                              controller: controller.pageController,
                              itemCount: controller.designCardList.length,
                              onPageChanged: (index) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  controller.currentCardIndex.value = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return buildDesignCard(index);
                              },
                            );
                          }),
                          const SizedBox(height: 20),
                          CommonCardContainer(
                            width: Get.width,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildSummaryRow(
                                  "Subtotal",
                                  controller.subtotal.value,
                                ),
                                (AppConstants.abbreviation == "AN")
                                    ? buildSummaryRow(
                                      "CGST (2.5%)",
                                      controller.cgst.value,
                                    )
                                    : (AppConstants.abbreviation == "LA")
                                    ? buildSummaryRow(
                                      "CGST (9%)",
                                      controller.cgst.value,
                                    )
                                    : const SizedBox.shrink(),
                                (AppConstants.abbreviation == "AN")
                                    ? buildSummaryRow(
                                      "SGST (2.5%)",
                                      controller.sgst.value,
                                    )
                                    : (AppConstants.abbreviation == "LA")
                                    ? buildSummaryRow(
                                      "SGST (9%)",
                                      controller.sgst.value,
                                    )
                                    : const SizedBox.shrink(),
                                const Divider(thickness: 1.5),
                                buildSummaryRow(
                                  "Final Total",
                                  controller.finalTotal.value,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => CommonSubmit(
                              onTap:
                                  controller.isSubmitting.value
                                      ? () {}
                                      : controller.updateInvoice,
                              data:
                                  controller.isSubmitting.value
                                      ? "Updating..."
                                      : "Update Invoice",
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
