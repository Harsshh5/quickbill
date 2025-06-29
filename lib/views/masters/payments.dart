import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/submit_button.dart';

import '../../config/app_colors.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';
import '../wrapper/recent_invoice_wrapper.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> with TickerProviderStateMixin {


  late AnimationController calendarController;
  late Animation<double> calendarAnimation;

  late TabController tabController;

  DateTimeRange? selectedDateRange;

  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      setState(() {});
    });

    calendarController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
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
    super.dispose();
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
                    mainHeading: "Payments",
                    subHeading: "All Payments",
                    onTap: () => Get.back(),
                    icon: Icons.chevron_left_rounded,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: "Search",
                          suffixIcon: Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 15),

                      ScaleTransition(
                        scale: calendarAnimation,
                        child: GestureDetector(
                          onTap: () async {
                            await calendarController.reverse();
                            await calendarController.forward();

                            DateTimeRange? picked = await showDateRangePicker(
                              currentDate: DateTime.now(),
                              // ignore: use_build_context_synchronously
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
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.dark,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (!context.mounted) return;

                            if (picked != null) {
                              setState(() {
                                selectedDateRange = picked;
                              });
                            }

                            if (picked != null) {
                              setState(() {
                                selectedDateRange = picked;
                              });
                            }
                          },
                          child: CommonIconCardContainer(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TabBar(
                      controller: tabController,
                      tabs: const [Tab(text: 'Pending'), Tab(text: 'Received')],
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.all(5),
                      splashBorderRadius: BorderRadius.circular(18),
                      dividerColor: Colors.transparent,
                      indicatorAnimation: TabIndicatorAnimation.elastic,
                      labelStyle: appTextStyle(color: Colors.white, fontSize: 16),
                      unselectedLabelStyle: appTextStyle(fontSize: 16),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: appGradient1
                      ),

                    ),
                  ),

                  const SizedBox(height: 20),

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
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateRange = null;
                            });
                          },
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),

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
                        isSelectionMode = !val;
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
