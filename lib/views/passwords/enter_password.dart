import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/passwords/check_password.dart';
import 'package:quickbill/views/commons/common_pinput.dart';
import 'package:quickbill/views/commons/drop_down.dart';
import 'package:quickbill/views/commons/submit_button.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../masters/home.dart';

class SetPassword extends StatelessWidget {
  SetPassword({super.key});

  final Map<String, String> accountMap = {
    "1": "After Nature",
    "2": "V.B. Art Line",
    "3": "Ethnic Design",
    "4": "Lion Art Studio",
  };

  final CheckPasswordController checkPasswordController = Get.put(CheckPasswordController());

  @override
  Widget build(BuildContext context) {

    final List<DropdownMenuEntry<Object>> accountList =
        accountMap.entries
            .map(
              (entry) => DropdownMenuEntry<Object>(
                value: entry.key,
                label: entry.value,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    appTextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ).toList();

    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        padding: EdgeInsets.all(10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "QUICK BILL",
                    style: appTextStyle(color: Colors.black, fontSize: 28),
                  ),
                ],
              ),

              Spacer(),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enter PIN",
                        style: appTextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: CommonDropDown(
                      onSelected: (value) {
                        checkPasswordController.selectedAccount.value = value.toString();
                      },
                      dropdownMenuEntries: accountList,
                      width: MediaQuery.of(context).size.width * 0.9,
                      initialSelection: accountList.first.value,
                    ),
                  ),

                  SizedBox(height: 30),

                  Obx(() => CommonPinput(
                    errorText: checkPasswordController.pinErrorText.value,
                    controller: checkPasswordController.pinController,
                    onCompleted: (pin) {
                      final businessId = checkPasswordController.selectedAccount.value;
                      final pass = int.parse(pin);
                      checkPasswordController.verifyPassword(businessId, pass);
                    },
                  )),

                ],
              ),
              Spacer(),

              Skeletonizer(
                enabled: checkPasswordController.isLoading.value,
                child: CommonSubmit(data: "Continue", onTap: () {
                  Get.to(() => Home());
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
