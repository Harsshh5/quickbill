import 'dart:developer';

import 'package:get/get.dart';

import '../../model/invoice_model/latest_invoice_number.dart';

class LatestInvoiceNumberController extends GetxController {
  var latestNumber = 1.obs;
  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getInvoiceLatestNumber();
    super.onInit();
  }

  Future<void> getInvoiceLatestNumber() async {
    isLoading.value = true;
    try {
      var res = await LatestInvoiceNumberModel().fetchInvoiceNumber();
      if (res["success"] == true) {

        latestNumber.value = res["lastInvoiceNumber"] + 1;


      } else {

        latestNumber.value = 1;
        log("Success is false I guess!!");

      }
    } catch (e) {

      latestNumber.value = 0;
      log("Error fetching table data: $e");

    } finally {
      isLoading.value = false;
      update();
    }
  }
}