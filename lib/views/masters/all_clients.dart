import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/client_controller/client_list.dart';
import '../commons/card_text_field.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';

class AllClients extends StatefulWidget {
  const AllClients({super.key});

  @override
  State<AllClients> createState() => _AllClientsState();
}

class _AllClientsState extends State<AllClients> with TickerProviderStateMixin{

  final ClientListController clientListController = Get.put(ClientListController());

  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  late List<AnimationController> listControllers;
  late List<Animation<double>> listAnimations;

  late List<AnimationController> entranceControllers;
  late List<Animation<double>> listFadeAnimation;
  late List<Animation<Offset>> listSlideAnimation;

  final int itemCount = 30;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(children: [
            SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: CommonPageHeader(
                  mainHeading: "Clients",
                  subHeading: "All Clients",
                  onTap: () => Get.back(),
                  icon: Icons.chevron_left_rounded,
                ),
              ),
            ),

            SizedBox(height: 20),

            CommonTextField(
              hintText: "Search",
              suffixIcon: Icon(Icons.search, color: Colors.black),
              onChanged: (p0) {
                clientListController.filterItems(p0);
              },
            ),

            SizedBox(height: 20),

            invoiceList()
          ]),
        ),
      ),
    );
  }


  invoiceList() {
    return Obx((){
      return Expanded(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: AppColors.dark,
          onRefresh: () {
            return clientListController.getClientList();
          },
          child: Skeletonizer(
            enabled: clientListController.isLoading.value,
            child: ListView.builder(
              itemCount: clientListController.filteredList.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var client = clientListController.filteredList[index];
                String? clientId = client["id"];

                return SlideTransition(
                  position: listSlideAnimation[index],
                  child: FadeTransition(
                    opacity: listFadeAnimation[index],
                    child: ScaleTransition(
                      scale: listAnimations[index],
                      child: GestureDetector(
                          onTap: () async {
                            await listControllers[index].reverse();
                            await listControllers[index].forward();

                            log(clientId!);
                          },
                          child: CommonCardContainer(
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
                                      "${client["companyName"]}",
                                      style: appTextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "${client["clientName"]}",
                                      style: appTextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    Text(
                                      "Contact : ${client["contact"]}",
                                      style: appTextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          )
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
