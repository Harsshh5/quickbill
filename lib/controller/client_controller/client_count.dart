import 'dart:developer';

import 'package:get/get.dart';

import '../../model/client_model/client_count.dart';

class ClientCountController extends GetxController{
  var count = 0.obs;
  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getClientCount();
    super.onInit();
  }

  getClientCount() async {
    isLoading.value = true;
    try {
      var res = await ClientCountModel().fetchClientCount();

      if (res["success"] == true) {

        count.value = res["totalClients"];

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
