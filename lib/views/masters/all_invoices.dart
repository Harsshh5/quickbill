import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/controller/invoice_controller/invoice_list.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../commons/card_container.dart';
import '../commons/drop_down.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';
import '../../../controller/home_widget_animations/list_animation_controller.dart';
import 'invoice_details.dart';

class AllInvoices extends StatefulWidget {
  const AllInvoices({super.key});

  @override
  State<AllInvoices> createState() => _AllInvoicesState();
}

class _AllInvoicesState extends State<AllInvoices>
    with TickerProviderStateMixin {
  ListAnimationControllerHelper? animController;
  int _animCount = 0;

  final InvoiceListController invoiceListController = Get.put(
    InvoiceListController(),
  );

  @override
  void initState() {
    super.initState();

    // initialize with at least 1 to avoid zero-sized controllers
    _animCount = 1;
    animController = ListAnimationControllerHelper(
      vsync: this,
      itemCount: _animCount,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || invoiceListController.isClosed) return;
      invoiceListController.setStatusFilter('');
      invoiceListController.setDateRangeFilter(null);
      invoiceListController.setSearchQuery('');
      invoiceListController.enableFinancialYearFilter();
    });
  }

  @override
  void dispose() {
    // IMPORTANT: don't mutate Rx state synchronously in dispose().
    // It can trigger Obx rebuilds while Flutter is finalizing the tree
    // ("widget tree was locked" assertion). Defer to next frame.
    final ctrl = invoiceListController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.isClosed) return;
      ctrl.disableFinancialYearFilter();
      ctrl.setSearchQuery('');
    });
    animController?.dispose();
    super.dispose();
  }

  void handleTap(int index) async {
    if (animController == null) return;
    if (index < animController!.listControllers.length) {
      await animController!.listControllers[index].forward();
      await animController!.listControllers[index].reverse();
    }
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
                      invoiceListController.setSearchQuery(p0);
                    },
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                  ),

                  const SizedBox(height: 15),

                  Obx(() {
                    final years = invoiceListController.financialYears;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonFromHeading(data: "Financial Year"),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: CommonDropDown<String>(
                            key: ValueKey(
                              invoiceListController.selectedFinancialYear.value,
                            ),
                            hintText: "Financial Year",
                            isEnable: years.isNotEmpty,
                            initialSelection:
                                invoiceListController
                                        .selectedFinancialYear
                                        .value
                                        .isEmpty
                                    ? null
                                    : invoiceListController
                                        .selectedFinancialYear
                                        .value,
                            dropdownMenuEntries:
                                invoiceListController
                                    .financialYearDropdownEntries,
                            borderSideBorder: BorderSide.none,
                            borderSideEnable: BorderSide.none,
                            borderSideFocused: BorderSide.none,
                            onSelected: (value) {
                              if (value != null) {
                                invoiceListController.setFinancialYearFilter(
                                  value,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }),

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
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.dark,
        onRefresh: () {
          return invoiceListController.getInvoiceList();
        },
        child: Obx(() {
          var list = invoiceListController.filteredList.toList();

                  // Ensure animation controller matches current list length
                  int needed = list.isEmpty ? 1 : list.length;
                  if (animController == null || _animCount != needed) {
                    // dispose previous
                    try {
                      animController?.dispose();
                    } catch (_) {}
                    _animCount = needed;
                    animController = ListAnimationControllerHelper(vsync: this, itemCount: _animCount);
                  }

          if (!invoiceListController.isLoading.value && list.isEmpty) {
            return Center(
              child: Text(
                "No Invoices Found",
                style: appTextStyle(color: Colors.grey),
              ),
            );
          }

          return Skeletonizer(
            enabled: invoiceListController.isLoading.value,
            child: ListView.builder(
              itemCount: list.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var invoices = list[index];
                var amountColor =
                    (invoices["status"] == "paid") ? Colors.green : Colors.red;

                        bool showHeader = false;
                        String headerText = "";

                        try {
                          String currentDateStr = invoices["invoiceDate"] ?? '';
                          DateTime currentDate = DateFormat(
                            "dd-MM-yyyy",
                          ).parse(currentDateStr);

                          headerText = DateFormat(
                            "MMMM yyyy",
                          ).format(currentDate);

                          if (index == 0) {
                            showHeader = true;
                          } else {
                            String prevDateStr = list[index - 1]["invoiceDate"] ?? '';
                            DateTime prevDate = DateFormat(
                              "dd-MM-yyyy",
                            ).parse(prevDateStr);
                            String prevHeader = DateFormat(
                              "MMMM yyyy",
                            ).format(prevDate);

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
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 8,
                                  left: 5,
                                  right: 5,
                                ),
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
                                    const Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SlideTransition(
                              position: animController?.listSlideAnimation[index] ??
                                  AlwaysStoppedAnimation(const Offset(0, 0)),
                              child: FadeTransition(
                                opacity: animController?.listFadeAnimation[index] ??
                                    AlwaysStoppedAnimation(1.0),
                                child: ScaleTransition(
                                  scale: animController?.listAnimations[index] ??
                                      AlwaysStoppedAnimation(1.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      handleTap(index);
                                      Get.to(
                                        () => InvoiceDetails(),
                                        arguments: {
                                          "invoiceId": invoices["id"],
                                        },
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Bill No. ${invoices["invoiceNumber"] ?? ''}",
                                                  style: appTextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  invoices["companyName"] ?? '',
                                                  style: appTextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            invoices["invoiceDate"] ?? '',
                                            style: appTextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            invoiceListController.formatIndianCurrency(invoices["totalAmount"] ?? ''),
                                            style: appTextStyle(
                                              fontSize: 14,
                                              color: amountColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
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
