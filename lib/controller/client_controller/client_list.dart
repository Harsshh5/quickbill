import 'dart:developer';

import 'package:get/get.dart';
import '../../model/client_model/client_list.dart';

class ClientListController extends GetxController {
  RxList<Map<String, String>> clientList = <Map<String, String>>[].obs;
  RxList<Map<String, String>> filteredList = <Map<String, String>>[].obs;

  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getClientList();
    super.onInit();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(clientList);
    } else {
      filteredList.assignAll(
        clientList.where(
          (item) =>
              item["companyName"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["clientName"]!.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
    update();
  }

  Future<void> getClientList() async {
    isLoading.value = true;
    try {
      var res = await ClientListModel().fetchClients();

      if (res["success"] == true) {
        List<Map<String, String>> tempList = [];

        for (var item in res["clients"]) {
          tempList.add({
            "id": item["_id"] ?? "",
            "companyName": item["companyName"] ?? "",
            "clientName": item["clientName"] ?? "",
            "contact": item["contact"] ?? "",
            "address": item["address"] ?? "",
            "gstNo": item["gstNo"] ?? "",
          });
        }

        clientList.assignAll(tempList);
        filteredList.assignAll(tempList);

        // log(filteredList.toString());
      } else if (res["message"] == "No clients found") {
        log("Success is false I guess!!");
        clientList.clear();
      }
    } catch (e) {
      log("Error fetching table data: $e");
      clientList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
