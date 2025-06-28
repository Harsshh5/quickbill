import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';

import '../../config/app_colors.dart';
import '../commons/page_header.dart';
import '../commons/submit_button.dart';
import '../commons/text_style.dart';


class AllInvoices extends StatefulWidget {
  const AllInvoices({super.key});

  @override
  State<AllInvoices> createState() => _AllInvoicesState();
}

class _AllInvoicesState extends State<AllInvoices>
    with TickerProviderStateMixin {

  late List<AnimationController> listControllers;
  late List<Animation<double>> listAnimations;

  late List<AnimationController> entranceControllers;
  late List<Animation<double>> listFadeAnimation;
  late List<Animation<Offset>> listSlideAnimation;

  final int itemCount = 30;

  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  final Random random = Random();

  @override
  void initState() {
    super.initState();

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
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                  ),

                  const SizedBox(height: 20),

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
                    child: CommonSubmit(data: 'Submit', onTap: (){},)),
              ],
            )
        ],
      ),
    );
  }

  Expanded invoiceList() {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.dark,
        onRefresh: () {
          return Future(() {});
        },
        child: ListView.builder(
          itemCount: 30,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Color amountColor = random.nextBool() ? Colors.green : Colors.red;
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
                    child: CommonCardContainer(
                      height: 80,
                      width: Get.width,
                      padding: const EdgeInsets.all(10),
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
                                style: appTextStyle(fontSize: 16),
                              ),
                              Text(
                                "Company Name",
                                style: appTextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '16-6-25',
                            style: appTextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 15),
                          Text(
                            '₹10,000',
                            style: appTextStyle(fontSize: 16, color: amountColor),
                          ),
                          SizedBox(width: 10),
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
    );
  }
}
