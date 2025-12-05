import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/masters/add_cheque.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/home_widget_animations/list_animation_controller.dart';
import '../../controller/invoice_controller/invoice_list.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';
import 'cheque_list.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> with TickerProviderStateMixin {
  late ListAnimationControllerHelper animController;
  late int invoiceCount;

  final InvoiceListController invoiceListController = Get.put(InvoiceListController());

  late AnimationController calendarController;
  late Animation<double> calendarAnimation;

  late TabController tabController;

  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();

    invoiceCount = Get.arguments != null ? (Get.arguments["invoiceCount"] ?? 0) : 0;

    animController = ListAnimationControllerHelper(vsync: this, itemCount: invoiceCount);

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      setState(() {
        // Todo: Add logic here to filter the list based on Tab Index (0 or 1)
        // invoiceListController.filterByStatus(tabController.index == 0 ? 'pending' : 'received');
      });
    });

    calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.92,
      upperBound: 1.0,
    );

    calendarAnimation = CurvedAnimation(
      parent: calendarController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    calendarController.value = 1.0;
  }

  @override
  void dispose() {
    tabController.dispose();
    calendarController.dispose();
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              // Page Header
              CommonPageHeader(
                mainHeading: "Payments",
                subHeading: "All Payments",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              // Search and calender row
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      hintText: "Search",
                      suffixIcon: const Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 15),

                  ScaleTransition(
                    scale: calendarAnimation,
                    child: GestureDetector(
                      onTap: () async {
                        await calendarController.reverse();
                        await calendarController.forward();

                        if (!context.mounted) return;

                        DateTimeRange? picked = await showDateRangePicker(
                          currentDate: DateTime.now(),
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDateRange: selectedDateRange,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.dark,
                                  onPrimary: Colors.white,
                                  secondary: AppColors.medium,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: AppColors.dark),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setState(() {
                            selectedDateRange = picked;
                          });
                        }
                      },
                      child: const CommonIconCardContainer(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.calendar_month_rounded, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Total Amount Sum
              Row(
                children: [
                  Expanded(
                    child: CommonCardContainer(
                      height: 150,
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("₹ 0", style: appTextStyle(fontSize: 24, color: AppColors.dark)),
                          Text("Total Amount", style: appTextStyle()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cheque options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => AddCheque(), arguments: {"tag": "add_cheque"}, transition: Transition.fadeIn);
                    },
                    child: CommonCardContainer(
                      height: 65,
                      width: Get.width / 2.2,
                      alignment: Alignment.center,
                      child: Text("Add Cheque", style: appTextStyle(fontSize: 15)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ChequeList(), transition: Transition.fadeIn);
                    },
                    child: CommonCardContainer(
                      height: 65,
                      width: Get.width / 2.2,
                      alignment: Alignment.center,
                      child: Text("Cheque List", style: appTextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tab bar header
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: TabBar(
                  controller: tabController,
                  tabs: const [Tab(text: 'Pending'), Tab(text: 'Received')],
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(5),
                  splashBorderRadius: BorderRadius.circular(18),
                  dividerColor: Colors.transparent,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  labelStyle: appTextStyle(color: Colors.white, fontSize: 16),
                  unselectedLabelStyle: appTextStyle(fontSize: 16),
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: appGradient1),
                ),
              ),

              const SizedBox(height: 20),

              // Selected date range
              if (selectedDateRange != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)}"
                      " - "
                      "${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}",
                      style: appTextStyle(),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateRange = null;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),

              // Invoice List
              invoicesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget invoicesList() {
    return Expanded(
      child:
          invoiceListController.filteredList.isEmpty
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

                        if (index >= animController.listAnimations.length) {
                          return GestureDetector(
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
                                      Text("Bill No. ${invoices["invoiceNumber"]!}", style: appTextStyle(fontSize: 16)),
                                      Text(invoices["companyName"]!, style: appTextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(invoices["date"]!, style: appTextStyle(fontSize: 16)),
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
                          );
                        }

                        return SlideTransition(
                          position: animController.listSlideAnimation[index],
                          child: FadeTransition(
                            opacity: animController.listFadeAnimation[index],
                            child: ScaleTransition(
                              scale: animController.listAnimations[index],
                              child: GestureDetector(
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
                                      Text(invoices["date"]!, style: appTextStyle(fontSize: 16)),
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
