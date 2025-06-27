import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/masters/home.dart';

import '../../model/passwords/check_password.dart';

class CheckPasswordController extends GetxController {
  final pinController = TextEditingController();
  var pinErrorText = "".obs;
  var isLoading = false.obs;
  final selectedAccount = '1'.obs;


  verifyPassword(businessId, pass) async {

    isLoading.value = true;

    try {
      var res = await CheckPasswordModel().checkPassword(businessId: '$businessId', inputPassword: pass);
      log(res.toString());

      if (res["success"] == true) {

        pinErrorText.value = "";
        Get.offAll(() => Home(), transition: Transition.fade);

      } else {

        pinErrorText.value = "Invalid Password";

      }
    } catch (e) {

      pinErrorText.value = "Server Error. Try after some time.";
      log("Error fetching table data: $e");

    } finally {
      isLoading.value = false;
      update();
    }
  }
}
