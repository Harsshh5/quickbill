import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/home_widget_animations/drawer_animations.dart';
import '../../controller/home_widget_animations/list_animation_controller.dart';
import '../../controller/invoice_controller/invoice_list.dart';
import '../commons/card_container.dart';
import '../commons/home_page_widgets/custom_drawer.dart';
import '../wrapper/count_box_wrapper.dart';
import '../wrapper/home_animated_grid_wrapper.dart';
import 'invoice_details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final ListAnimationControllerHelper animController;

  final DrawerControllerX drawerController = Get.put(DrawerControllerX());

  final InvoiceListController invoiceListController = Get.put(InvoiceListController());

  final List<IconData> boxIcons = <IconData>[
    Icons.note_add,
    Icons.person_add,
    Icons.currency_rupee_rounded,
    Icons.account_balance_rounded
  ];

  final List<String> boxTexts = <String>["Invoice", "Client", "Payments", "Cheques"];

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

  void handleTap(int index) async {
    await animController.listControllers[index].forward();
    await animController.listControllers[index].reverse();
  }

  @override
  void initState() {
    super.initState();
    animController = ListAnimationControllerHelper(vsync: this, itemCount: 10);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          Container(height: Get.height, width: Get.width, decoration: BoxDecoration(gradient: appGradient2)),

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
                  HomeAnimatedGridWrapper(boxIcons: boxIcons, boxTexts: boxTexts),

                  SizedBox(height: 10),

                  // 2 big boxes - count boxes
                  CountBoxWrapper(),

                  SizedBox(height: 20),

                  // Recent Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Recent Invoices", style: appTextStyle())],
                  ),

                  SizedBox(height: 10),

                  // Recent 10 invoice list
                  invoicesList(),
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
                        child: Container(color: Colors.black.withValues(alpha: 0.4)),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          Obx(
            () =>
                drawerController.isDrawerOpen.value
                    ? SlideTransition(
                      position: drawerController.slideAnimation,
                      child: const Align(alignment: Alignment.centerLeft, child: CustomDrawer()),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget invoicesList() {
    return Obx(() {
      return Expanded(
        child:
            invoiceListController.filteredList.isEmpty
                ? CommonCardContainer(
                  child: Center(child: Text("No Invoices Found", style: appTextStyle(color: Colors.grey))),
                )
                : RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: AppColors.dark,
                  onRefresh: () {
                    return invoiceListController.getInvoiceList();
                  },
                  child: Skeletonizer(
                    enabled: invoiceListController.isLoading.value,
                    child: ListView.builder(
                      itemCount:
                          (invoiceListController.filteredList.length) > 10
                              ? 10
                              : invoiceListController.filteredList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var invoices = invoiceListController.filteredList[index];
                        var amountColor = (invoices["status"] == "paid") ? Colors.green : Colors.red;

                        return SlideTransition(
                          position: animController.listSlideAnimation[index],
                          child: FadeTransition(
                            opacity: animController.listFadeAnimation[index],
                            child: ScaleTransition(
                              scale: animController.listAnimations[index],
                              child: GestureDetector(
                                onTap: () {
                                  handleTap(index);
                                  Get.to(() => InvoiceDetails(), arguments: {"invoiceId": invoices["id"]});
                                },
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
                  ),
                ),
      );
    });
  }
}
