import 'dart:developer';

import 'package:get/get.dart';
import 'package:quickbill/controller/client_controller/client_list.dart';
import 'package:quickbill/model/client_model/delete_client.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import 'client_count.dart';

class DeleteClientController extends GetxController {
  final ClientCountController clientCountController = Get.put(ClientCountController());
  final ClientListController clientListController = Get.put(ClientListController());

  Future<void> removeClient(String clientId) async {
    try {
      var res = await DeleteClientModel().deleteClient(clientId);

      if (res["success"] == true) {
        AppSnackBar.show(message: "Client deleted successfully.");

        clientListController.getClientList();
        clientCountController.getClientCount();

        Get.back();
      } else if (res["success"] == false) {
        AppSnackBar.show(message: "Some Error Occurred");
      }
    } catch (e) {
      log("Error : $e");
    }
  }
}
