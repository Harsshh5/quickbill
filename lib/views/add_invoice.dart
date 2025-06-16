import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'commons/common_form_card.dart';

class AddInvoice extends StatefulWidget {
  const AddInvoice({super.key});

  @override
  State<AddInvoice> createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> with TickerProviderStateMixin {
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

    submitScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: submitController, curve: Curves.easeOut),
    );


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
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: Column(
            children: [
              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      width: Get.width,
                      height: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Color(0xff8845ec),
                        border: Border.all(color: Color(0xffad78fa), width: 2),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Card(
                              elevation: 5,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Invoice",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Add New Invoice",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20,),
              Expanded(
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonFromHeading(
                                  data: "Select Client",
                                ),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: true,
                                  hintText: "Select Client",
                                ),

                                SizedBox(height: 15,),

                                CommonFromHeading(
                                  data: "Client Name",
                                ),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "Client Name",
                                ),

                                SizedBox(height: 15,),

                                CommonFromHeading(
                                  data: "Contact",
                                ),
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonFromHeading(
                                  data: "GST NO.",
                                ),
                                SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "GST NO.",
                                ),

                                SizedBox(height: 15,),

                                CommonFromHeading(
                                  data: "Address",
                                ),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Container(
                                width: Get.width,
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Color(0xff8845ec),borderRadius: BorderRadius.circular(24)),
                                child: Text("Submit", style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        )
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
