import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/home_widget_animations/list_animation_controller.dart';
import '../../controller/invoice_controller/invoice_list.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> with TickerProviderStateMixin {
  final InvoiceListController controller = Get.put(InvoiceListController());

  late ListAnimationControllerHelper animController;
  late TabController tabController;

  late AnimationController calendarController;
  late Animation<double> calendarAnimation;

  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();

    int initialCount = Get.arguments != null ? (Get.arguments["invoiceCount"] ?? 0) : 5;
    animController = ListAnimationControllerHelper(vsync: this, itemCount: initialCount);

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

    tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setStatusFilter('unpaid');
    });

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        controller.setStatusFilter(tabController.index == 0 ? 'unpaid' : 'paid');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isClosed) {
        controller.setStatusFilter('');
        controller.setDateRangeFilter(null);
      }
    });

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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // --- HEADER ---
              CommonPageHeader(
                mainHeading: "Payments",
                subHeading: "All Payments",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              // --- SEARCH & DATE ---
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      hintText: "Search",
                      suffixIcon: const Icon(Icons.search, color: Colors.black),
                      // Connect to Controller
                      onChanged: (val) => controller.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _buildCalendarIcon(),
                ],
              ),

              const SizedBox(height: 20),

              Obx(() {
                bool isDateSelected = controller.currentDateRange.value != null;

                return CommonCardContainer(
                  height: isDateSelected ? 150 : 100,
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pending Column
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.formatIndianCurrency(controller.pendingTotal.value),
                                  style: appTextStyle(fontSize: 20, color: Colors.red),
                                ),
                                Text("Pending Amount", style: appTextStyle(fontSize: 14)),
                              ],
                            ),

                            VerticalDivider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              width: 1,
                              indent: 10,
                              endIndent: 10,
                            ),

                            // Credit Column
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.formatIndianCurrency(controller.receivedTotal.value),
                                  style: appTextStyle(fontSize: 20, color: Colors.green),
                                ),
                                Text("Credit Amount", style: appTextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- BOTTOM SECTION: DATE CHIP (Condition) ---
                      if (isDateSelected) ...[
                        Divider(color: Colors.grey.shade200, thickness: 1, height: 10),

                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.dark),
                              const SizedBox(width: 8),
                              Text(
                                "${DateFormat('dd MMM').format(controller.currentDateRange.value!.start)} - ${DateFormat('dd MMM').format(controller.currentDateRange.value!.end)}",
                                style: appTextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  controller.setDateRangeFilter(null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // --- TAB BAR ---
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: TabBar(
                  controller: tabController,
                  tabs: const [Tab(text: 'Pending'), Tab(text: 'Received')],
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(5),
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: appGradient1),
                  labelStyle: appTextStyle(color: Colors.white, fontSize: 16),
                  unselectedLabelStyle: appTextStyle(fontSize: 16),
                ),
              ),

              // --- LIST VIEW ---
              Expanded(child: _buildInvoiceList()),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCalendarIcon() {
    return ScaleTransition(
      scale: calendarAnimation,
      child: GestureDetector(
        onTap: () async {
          await calendarController.reverse();
          await calendarController.forward();
          if (!mounted) return;

          DateTimeRange? picked = await showDateRangePicker(
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
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => selectedDateRange = picked);
            controller.setDateRangeFilter(picked);
          }
        },
        child: const CommonIconCardContainer(
          width: 50,
          height: 50,
          child: Icon(Icons.calendar_month_rounded, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildInvoiceList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => _invoiceItemBuilder({}, index, isDummy: true),
          ),
        );
      }

      if (controller.filteredList.isEmpty) {
        return Center(child: Text("No Invoices Found", style: appTextStyle(color: Colors.grey)));
      }

      return RefreshIndicator(
        onRefresh: () => controller.getInvoiceList(),
        color: AppColors.dark,
        child: ListView.builder(
          itemCount: controller.filteredList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final invoice = controller.filteredList[index];
            return _invoiceItemBuilder(invoice, index);
          },
        ),
      );
    });
  }

  Widget _invoiceItemBuilder(Map<String, String> invoice, int index, {bool isDummy = false}) {
    if (isDummy) {
      return CommonCardContainer(height: 80, width: Get.width, padding: const EdgeInsets.all(10), child: Container());
    }

    var amountColor = (invoice["status"]?.toLowerCase() == "paid") ? Colors.green : Colors.red;

    Widget cardContent = CommonCardContainer(
      height: 80,
      width: Get.width,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Bill No. ${invoice["invoiceNumber"]}", style: appTextStyle(fontSize: 16)),
              Text(invoice["companyName"] ?? "", style: appTextStyle(fontSize: 14)),
            ],
          ),
          const Spacer(),
          Text(invoice["date"] ?? "", style: appTextStyle(fontSize: 16)),
          const SizedBox(width: 15),
          Text(
            controller.formatIndianCurrency(invoice["totalAmount"] ?? "0"),
            style: appTextStyle(fontSize: 16, color: amountColor),
          ),
        ],
      ),
    );

    if (index < animController.listAnimations.length) {
      return SlideTransition(
        position: animController.listSlideAnimation[index],
        child: FadeTransition(
          opacity: animController.listFadeAnimation[index],
          child: ScaleTransition(
            scale: animController.listAnimations[index],
            child: GestureDetector(child: cardContent),
          ),
        ),
      );
    } else {
      return GestureDetector(child: cardContent);
    }
  }
}
