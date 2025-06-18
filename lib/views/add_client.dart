import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/common_form_card.dart';
import 'package:quickbill/views/commons/common_page_header.dart';

class AddClient extends StatefulWidget {
  const AddClient({super.key});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> with TickerProviderStateMixin {
  late AnimationController controller;

  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  late AnimationController submitController;
  late Animation<double> submitScale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 500),
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

    submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      reverseDuration: Duration(milliseconds: 150),
    );

    submitScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: submitController, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    submitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SafeArea(
          child: Column(
            children: [
              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: CommonPageHeader(
                    mainHeading: "Client",
                    subHeading: "Add New Client",
                    icon: Icons.chevron_left_rounded,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
              ),

              SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Container(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonFromHeading(data: "Company Name"),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: true,
                                  hintText: "Company Name",
                                ),

                                SizedBox(height: 15),

                                CommonFromHeading(data: "Client Name"),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "Client Name",
                                ),

                                SizedBox(height: 15),

                                CommonFromHeading(data: "Contact"),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "Contact",
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Container(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonFromHeading(data: "GST NO."),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "GST NO.",
                                ),

                                SizedBox(height: 15),

                                CommonFromHeading(data: "Address"),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "Address",
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        GestureDetector(
                          onTap: () async {
                            await submitController.forward();
                            await submitController.reverse();
                          },
                          child: ScaleTransition(
                            scale: submitScale,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Container(
                                width: Get.width,
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0xff8845ec),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
