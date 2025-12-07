import 'dart:developer';

import 'package:get/get.dart';

import '../../model/cheques_model/delete_cheque.dart';
import '../../views/commons/snackbar.dart';
import 'cheques_list.dart';

class DeleteChequeController extends GetxController {
  final chequeListController = Get.find<ChequesListController>();

  Future<void> removeCheque(String chequeId) async {
    try {
      var res = await DeleteChequeModel().deleteCheque(chequeId);

      if (res["success"] == true) {
        AppSnackBar.show(message: "Client deleted successfully.");
        chequeListController.getChequeList();

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
