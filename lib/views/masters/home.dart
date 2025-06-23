import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/controller/client_controller/client_count.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:quickbill/views/masters/all_clients.dart';
import 'package:quickbill/views/masters/payments.dart';
import 'package:quickbill/views/masters/stats.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'add_client.dart';
import 'add_invoice.dart';
import 'all_invoices.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {

  final ClientCountController clientCountController = Get.put(ClientCountController());

  List<IconData> boxIcons = <IconData>[
    Icons.add,
    Icons.person_add,
    Icons.currency_rupee_rounded,
    Icons.auto_graph,
  ];

  List<String> boxTexts = <String>["Invoice", "Client", "Payments", "Stats"];

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  late AnimationController controller;

  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  List<AnimationController> bounceControllers = [];
  List<Animation<double>> bounceAnimations = [];

  late List<Animation<Offset>> slideAnimations;
  late List<Animation<double>> fadeAnimations;

  late AnimationController invoiceController;
  late AnimationController clientController;

  late Animation<double> invoiceScale;
  late Animation<double> clientScale;

  final Random random = Random();
  final int itemCount = 10;

  late List<AnimationController> listControllers;
  late List<Animation<double>> listAnimations;

  late List<AnimationController> entranceControllers;
  late List<Animation<double>> listFadeAnimation;
  late List<Animation<Offset>> listSlideAnimation;

  late AnimationController drawerController;
  late Animation<Offset> drawerSlideAnimation;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    //good morning box
    controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    //4 small boxes
    slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            0.1 * index,
            0.6 + 0.1 * index,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    fadeAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            0.1 * index,
            0.6 + 0.1 * index,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    for (int i = 0; i < 4; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 150),
        reverseDuration: Duration(milliseconds: 150),
      );
      final animation = Tween(
        begin: 1.0,
        end: 0.92,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      bounceControllers.add(controller);
      bounceAnimations.add(animation);
    }

    //2 big count boxes
    invoiceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      reverseDuration: Duration(milliseconds: 150),
    );

    clientController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      reverseDuration: Duration(milliseconds: 150),
    );

    invoiceScale = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: invoiceController, curve: Curves.easeOut),
    );
    clientScale = Tween(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: clientController, curve: Curves.easeOut));

    //list
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
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
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

    listFadeAnimation =
        entranceControllers
            .map(
              (c) => Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: c, curve: Curves.easeIn)),
            )
            .toList();

    listSlideAnimation =
        entranceControllers.asMap().entries.map((entry) {
          var controller = entry.value;
          return Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeOut),
            ),
          );
        }).toList();

    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        entranceControllers[i].forward();
      });
    }

    //drawer
    drawerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    drawerSlideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Slide in from left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: drawerController, curve: Curves.easeInOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    invoiceController.dispose();
    clientController.dispose();
    for (var controller in bounceControllers) {
      controller.dispose();
    }
    drawerController.dispose();
    super.dispose();
  }

  void _onTapTotalInvoice() async {
    await invoiceController.forward();
    await invoiceController.reverse();

    Get.to(() => AllInvoices(), transition: Transition.fadeIn);
  }

  void _onTapTotalClients() async {
    await clientController.forward();
    await clientController.reverse();

    Get.to(() => AllClients(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: appGradient2,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: SafeArea(
              child: Column(
                children: [
                  SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: CommonPageHeader(
                        mainHeading: "${getGreeting()}! Harsh",
                        subHeading: formattedDate,
                        onTap: () {
                          setState(() => isDrawerOpen = true);
                          drawerController.forward();
                        },
                        icon: Icons.drag_handle_rounded,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return SlideTransition(
                          position: slideAnimations[index],
                          child: FadeTransition(
                            opacity: fadeAnimations[index],
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: GestureDetector(
                                onTap: () async {
                                  await bounceControllers[index].forward();
                                  await bounceControllers[index].reverse();

                                  if (index == 0) {
                                    Get.to(
                                      () => AddInvoice(),
                                      transition: Transition.fadeIn,
                                    );
                                  } else if (index == 1) {
                                    Get.to(
                                      () => AddClient(),
                                      transition: Transition.fadeIn,
                                    );
                                  } else if (index == 2) {
                                    Get.to(() => Payments(), transition: Transition.fadeIn);
                                  } else if (index == 3) {
                                    Get.to(() => Stats(), transition: Transition.fadeIn);
                                  }
                                },
                                child: ScaleTransition(
                                  scale: bounceAnimations[index],
                                  child: CommonCardContainer(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          boxIcons[index],
                                          color: AppColors.dark,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          boxTexts[index],
                                          style: appTextStyle(fontSize: 15)
                                        ),
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

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideTransition(
                        position: slideAnimation,
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: GestureDetector(
                            onTap: _onTapTotalInvoice,
                            child: ScaleTransition(
                              scale: invoiceScale,
                              child: CommonCardContainer(
                                width: Get.width / 2.2,
                                height: Get.height / 6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "10",
                                      style: appTextStyle(fontSize: 28, color: AppColors.dark),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Total Invoices",
                                      style: appTextStyle(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: slideAnimation,
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: GestureDetector(
                            onTap: _onTapTotalClients,
                            child: ScaleTransition(
                              scale: clientScale,
                              child: CommonCardContainer(
                                width: Get.width / 2.2,
                                height: Get.height / 6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() => Skeletonizer(
                                      enabled: clientCountController.isLoading.value,
                                      child: Text(
                                        clientCountController.count.value.toString(),
                                        style: appTextStyle(color: AppColors.dark, fontSize: 28),
                                      ),
                                    )),
                                    SizedBox(height: 10),
                                    Text(
                                      "Total Clients",
                                      style: appTextStyle(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  FadeTransition(
                    opacity: fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Recent",
                          style: appTextStyle(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  recentInvoices(),
                ],
              ),
            ),
          ),

          isDrawerOpen
              ? FadeTransition(
                opacity: drawerController,
                child: GestureDetector(
                  onTap: () {
                    drawerController.reverse().then((_) {
                      setState(() => isDrawerOpen = false);
                    });
                  },
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4), // backdrop
                  ),
                ),
              )
              : SizedBox.shrink(),

          isDrawerOpen
              ? SlideTransition(
                position: drawerSlideAnimation,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: customDrawer(),
                ),
              )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget recentInvoices() {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.dark,
        onRefresh: () {
          return Future(() {});
        },
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Color amountColor = random.nextBool() ? Colors.green : Colors.red;
            return SlideTransition(
              position: listSlideAnimation[index],
              child: FadeTransition(
                opacity: listFadeAnimation[index],
                child: GestureDetector(
                  onTap: () async {
                    await listControllers[index].reverse();
                    await listControllers[index].forward();
                  },
                  child: ScaleTransition(
                    scale: listAnimations[index],
                    child: CommonCardContainer(
                      height: 80,
                      width: Get.width,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bill No.",
                                style: appTextStyle(fontSize: 16),
                              ),
                              Text(
                                "Company Name",
                                style: appTextStyle(fontSize: 14),
                              ),
                            ],
                          ),

                          Spacer(),

                          Text(
                            '16-6-25',
                            style: appTextStyle(fontSize: 16),
                          ),

                          SizedBox(width: 15),

                          Text(
                            '₹10000',
                            style: appTextStyle(fontSize: 16, color: amountColor),
                          ),

                          SizedBox(width: 10),

                          Icon(Icons.chevron_right_rounded),
                        ],
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

  Widget customDrawer() {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Container(
        width: Get.width / 1.5,
        height: Get.height / 1.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
