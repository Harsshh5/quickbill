import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/commons/common_form_card.dart';
import 'package:quickbill/views/commons/common_submit.dart';

import 'commons/common_page_header.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  late List<AnimationController> listControllers;
  late List<Animation<double>> listAnimations;

  late List<AnimationController> entranceControllers;
  late List<Animation<double>> listFadeAnimation;
  late List<Animation<Offset>> listSlideAnimation;

  final int itemCount = 10;

  late AnimationController calendarController;
  late Animation<double> calendarAnimation;

  late AnimationController submitController;
  late Animation<double> submitScale;

  late TabController tabController;

  DateTimeRange? selectedDateRange;

  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

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


    controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    submitScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: submitController, curve: Curves.easeOut));

    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        entranceControllers[i].forward();
      });
    }

    listControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 150),
        lowerBound: 0.92,
        upperBound: 1.0,
      ),
    );

    listAnimations =
        listControllers.map((controller) {
          return CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOut,
          );
        }).toList();

    for (var controller in listControllers) {
      controller.value = 1.0;
    }

    entranceControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      ),
    );

    listFadeAnimation =entranceControllers
            .map((c) => Tween<double>(begin: 0.0,end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeIn)))
            .toList();

    listSlideAnimation =
        entranceControllers.asMap().entries.map((entry) {
          var controller = entry.value;
          return Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
            ),
          );
        }).toList();

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    submitController.dispose();
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
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: CommonPageHeader(
                        mainHeading: "Payments",
                        subHeading: "All Payments",
                        onTap: () => Get.back(),
                        icon: Icons.chevron_left_rounded,
                      ),
                    ),
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
                                      primary: Color(0xff3f009e),
                                      onPrimary: Colors.white,
                                      secondary: Color(0xff8845ec),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Color(0xff3f009e),
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
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.black,
                              ),
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
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "quicksand",
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "quicksand",
                      ),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff3f009e),
                            Color(0xff8845ec),
                            Color(0xffbea0f2),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      indicatorAnimation: TabIndicatorAnimation.elastic,
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
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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

                  invoiceList(),
                ],
              ),
            ),
          ),

          if(isSelectionMode)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                    child: CommonSubmit()),
              ],
            )
        ],
      )
    );
  }

  invoiceList() {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Color(0xff3f009e),
        onRefresh: () {
          return Future(() {}); // Your refresh logic
        },
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            bool isSelected = selectedIndexes.contains(index);

            return SlideTransition(
              position: listSlideAnimation[index],
              child: FadeTransition(
                opacity: listFadeAnimation[index],
                child: ScaleTransition(
                  scale: listAnimations[index],
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        isSelectionMode = true;
                        selectedIndexes.add(
                          index,
                        ); // select the long-pressed item
                      });
                    },
                    onTap: () async {
                      await listControllers[index].reverse();
                      await listControllers[index].forward();

                      if (isSelectionMode) {
                        setState(() {
                          if (isSelected) {
                            selectedIndexes.remove(index);
                            if (selectedIndexes.isEmpty) {
                              isSelectionMode = false;
                            }
                          } else {
                            selectedIndexes.add(index);
                          }
                        });
                      } else {
                        // Navigate to invoice details or another action
                      }
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Container(
                        height: 80,
                        width: Get.width,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xffe6dbf8) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isSelectionMode)
                              Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val!) {
                                      selectedIndexes.add(index);
                                    } else {
                                      selectedIndexes.remove(index);
                                      if (selectedIndexes.isEmpty) {
                                        isSelectionMode = false;
                                      }
                                    }
                                  });
                                },
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bill No.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Company Name",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              '16-6-25',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 15),
                            Text(
                              '₹10,000',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    tabController.index == 0
                                        ? Colors.red[600]
                                        : Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
