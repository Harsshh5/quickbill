import 'dart:developer';

import 'package:get/get.dart';
import 'package:quickbill/model/invoice_model/invoice_list.dart';

class InvoiceListController extends GetxController {
  RxList<Map<String, String>> invoiceList = <Map<String, String>>[].obs;
  RxList<Map<String, String>> filteredList = <Map<String, String>>[].obs;

  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getInvoiceList();
    super.onInit();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(invoiceList);
    } else {
      filteredList.assignAll(
        invoiceList.where(
          (item) =>
              item["invoiceNumber"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["companyName"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["totalAmount"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["date"]!.toLowerCase().contains(query.toLowerCase()),
        ),
      );

      // log(filteredList.toString());
    }
    update();
  }

  Future<void> getInvoiceList() async {
    isLoading.value = true;
    try {
      var res = await InvoiceListModel().fetchInvoices();

      if (res["success"] == true) {
        List<Map<String, String>> tempList = [];

        for (var item in res["invoices"]) {
          tempList.add({
            "id": item["_id"] ?? "",
            "companyName": item["clientId"]?["companyName"] ?? "",
            "totalAmount": item["amountDetails"]?["totalAmount"]?.toString() ?? "",
            "invoiceNumber": item["invoiceNumber"]?.toString() ?? "",
            "status": item["status"] ?? "",
            "date": item["createdAt"] ?? "",
          });
        }


        invoiceList.assignAll(tempList);
        filteredList.assignAll(tempList);

        log(filteredList.toString());
      } else if (res["message"] == "No invoices found") {
        log("Success is false I guess!!");
        invoiceList.clear();
      }
    } catch (e) {
      log("Error fetching table data: $e");
      invoiceList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
