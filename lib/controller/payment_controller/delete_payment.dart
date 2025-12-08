import 'dart:developer';

import 'package:get/get.dart';

import '../../model/payment_model/delete_payment.dart';
import '../../views/commons/snackbar.dart';
import 'payment_list.dart';

class DeletePaymentController extends GetxController {
  final paymentListController = Get.find<PaymentsListController>();

  Future<void> removePayment(String chequeId) async {
    try {
      var res = await DeletePaymentModel().deletePayment(chequeId);

      if (res["success"] == true) {
        AppSnackBar.show(message: "Payment deleted successfully.");
        paymentListController.getPaymentsList();

        Get.back();
      } else if (res["success"] == false) {
        log(res.toString());
        AppSnackBar.show(message: "Some Error Occurred");
      }
    } catch (e) {
      log("Error : $e");
    }
  }
}
