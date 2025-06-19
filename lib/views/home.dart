import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/add_client.dart';
import 'package:quickbill/views/commons/common_page_header.dart';
import 'package:quickbill/views/payments.dart';
import 'package:quickbill/views/stats.dart';

import 'add_invoice.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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

    //drawer
    drawerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    drawerSlideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Slide in from left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: drawerController, curve: Curves.easeOut));

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
  }

  void _onTapTotalClients() async {
    await clientController.forward();
    await clientController.reverse();
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
              gradient: LinearGradient(
                colors: [
                  Color(0xff3f009e),
                  Color(0xff9260e9),
                  Colors.white,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
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
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            boxIcons[index],
                                            color: Color(0xff3f009e),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            boxTexts[index],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
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
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Container(
                                  width: Get.width / 2.2,
                                  height: Get.height / 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "10",
                                        style: TextStyle(
                                          color: Color(0xff3f009e),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Total Invoices",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
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
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Container(
                                  width: Get.width / 2.2,
                                  height: Get.height / 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "10",
                                        style: TextStyle(
                                          color: Color(0xff3f009e),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Total Clients",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
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
                          "Recents",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
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
        color: Color(0xff3f009e),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
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
                              '₹10000',
                              style: TextStyle(
                                fontSize: 14,
                                color: amountColor,
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

  Widget customDrawer() {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24),
          topRight: Radius.circular(24),
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
      ),
    );
  }
}
