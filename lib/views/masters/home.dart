import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/controller/client_controller/client_count.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/text_style.dart';

import '../../controller/home_widget_animations/drawer_animations.dart';
import '../commons/home_page_widgets/custom_drawer.dart';
import '../wrapper/count_box_wrapper.dart';
import '../wrapper/home_animated_grid_wrapper.dart';
import '../wrapper/recent_invoice_wrapper.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final ClientCountController clientCountController = Get.put(
    ClientCountController(),
  );

  final DrawerControllerX drawerController = Get.put(DrawerControllerX());


  final List<IconData> boxIcons = <IconData>[
    Icons.note_add,
    Icons.person_add,
    Icons.currency_rupee_rounded,
    Icons.bar_chart_rounded,
  ];

  final List<String> boxTexts = <String>[
    "Invoice",
    "Client",
    "Payments",
    "Stats",
  ];

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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(gradient: appGradient2),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: SafeArea(
              child: Column(
                children: [
                  // Greeting box
                  CommonPageHeader(
                    mainHeading: "${getGreeting()}! Harsh",
                    subHeading: formattedDate,
                    onTap: drawerController.openDrawer,
                    icon: Icons.drag_handle_rounded,
                  ),

                  SizedBox(height: 20),

                  // 4 small boxes
                  HomeAnimatedGridWrapper(
                    boxIcons: boxIcons,
                    boxTexts: boxTexts,
                  ),

                  SizedBox(height: 10),

                  // 2 big boxes - count boxes
                  CountBoxWrapper(),

                  SizedBox(height: 20),

                  // Recent Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Recent", style: appTextStyle())],
                  ),

                  SizedBox(height: 10),

                  // Recent 10 invoice list
                  InvoiceListWrapper(
                    onRefresh: (){
                      return Future(() {});
                    },
                    itemCount: 10,
                    billNo: "Bill No.",
                    companyName: "Company Name",
                    invoiceAmount: "10,000",
                    invoiceDate: "16-06-25",
                  ),
                ],
              ),
            ),
          ),

          Obx(
            () =>
                drawerController.isDrawerOpen.value
                    ? FadeTransition(
                      opacity: drawerController.animationController,
                      child: GestureDetector(
                        onTap: drawerController.closeDrawer,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          Obx(
            () =>
                drawerController.isDrawerOpen.value
                    ? SlideTransition(
                      position: drawerController.slideAnimation,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: CustomDrawer(),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
