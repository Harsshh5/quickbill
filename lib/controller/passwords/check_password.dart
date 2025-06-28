import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/masters/home.dart';

import '../../config/app_constants.dart';
import '../../model/passwords/check_password.dart';

class CheckPasswordController extends GetxController {
  final pinController = TextEditingController();
  var pinErrorText = "".obs;
  var isLoading = false.obs;
  final selectedAccount = '1'.obs;
  var errorState = false.obs;


  Future<void> verifyPassword(String businessId, int pass) async {

    isLoading.value = true;

    try {

      if(pass.toString().length < 4){
        errorState.value = true;
        pinErrorText.value = "Enter a valid 4-Digit PIN";
        return;
      }
      var res = await CheckPasswordModel().checkPassword(businessId: businessId, inputPassword: pass);
      log(res.toString());

      if (res["success"] == true) {

        pinErrorText.value = "";
        errorState.value = false;
        AppConstants.businessId = businessId;
        if(businessId == "1"){
          AppConstants.abbreviation = "AN";
        } else if(businessId == "2"){
          AppConstants.abbreviation = "VB";
        } else if(businessId == "3"){
          AppConstants.abbreviation = "ED";
        } else if(businessId == "4"){
          AppConstants.abbreviation = "LA";
        }
        Get.offAll(() => Home(), transition: Transition.fade);

      } else {
        errorState.value = true;
        pinErrorText.value = "Invalid PIN";

      }
    } catch (e) {
      errorState.value = true;
      pinErrorText.value = "Server Error. Try after some time.";
      log("Error fetching table data: $e");

    } finally {
      isLoading.value = false;
      update();
    }
  }
}
