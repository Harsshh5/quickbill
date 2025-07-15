import 'dart:developer';

import 'package:get/get.dart';

import '../../model/invoice_model/invoice_count.dart';


class InvoiceCountController extends GetxController{
  var count = 0.obs;
  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getInvoiceCount();
    super.onInit();
  }

  Future<void> getInvoiceCount() async {
    isLoading.value = true;
    try {
      var res = await InvoiceCountModel().fetchInvoiceCount();

      if (res["success"] == true) {

        count.value = res["totalInvoices"];

      } else {

        count.value = 0;
        log("Success is false I guess!!");

      }
    } catch (e) {

      count.value = 0;
      log("Error fetching table data: $e");

    } finally {
      isLoading.value = false;
      update();
    }
  }
}
