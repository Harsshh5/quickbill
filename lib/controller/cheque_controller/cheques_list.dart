import 'dart:developer';

import 'package:get/get.dart';
import '../../config/app_constants.dart';
import '../../model/cheques_model/cheques_list.dart';

class ChequesListController extends GetxController {
  RxList<Map<String, String>> chequeList = <Map<String, String>>[].obs;
  RxList<Map<String, String>> filteredList = <Map<String, String>>[].obs;

  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getChequeList();
    super.onInit();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(chequeList);
    } else {
      filteredList.assignAll(
        chequeList.where((item) {
          String bank = (item["bankName"] ?? "").toLowerCase();
          String client = (item["clientName"] ?? "").toLowerCase();
          String amount = (item["amount"] ?? "").toLowerCase();
          String chequeNo = (item["chequeNumber"] ?? "").toLowerCase();

          String search = query.toLowerCase();

          return bank.contains(search) ||
              client.contains(search) ||
              amount.contains(search) ||
              chequeNo.contains(search);
        }).toList(),
      );
    }
  }
  Future<void> getChequeList() async {
    isLoading.value = true;
    final String businessName = AppConstants.abbreviation;

    try {
      var res = await ChequesListModel().fetchCheques(businessName);

      if (res["success"] == true) {
        List<Map<String, String>> tempList = [];

        for (var item in res["cheques"]) {
          String billNosString = "";
          if (item["billNos"] != null && item["billNos"] is List) {
            billNosString = (item["billNos"] as List).join(", ");
          } else {
            billNosString = item["billNos"]?.toString() ?? "";
          }

          String formattedChqDate = "";
          if (item["issueDate"] != null) {
            try {
              DateTime parsedDate = DateTime.parse(item["issueDate"]);
              formattedChqDate = "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
            } catch (e) {
              formattedChqDate = item["issueDate"];
            }
          }

          String formattedClearDate = "";
          if (item["issueDate"] != null) {
            try {
              DateTime parsedDate = DateTime.parse(item["clearanceDate"]);
              formattedClearDate = "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
            } catch (e) {
              formattedClearDate = item["clearanceDate"];
            }
          }

          String displayClient = item["companyName"] ?? item["companyName"] ?? "Unknown Client";

          tempList.add({
            "id": item["_id"] ?? "",
            "bankName": item["bankName"] ?? "",
            "clientName": displayClient,
            "amount": item["amount"]?.toString() ?? "0",
            "chequeNumber": item["chequeNumber"] ?? "",
            "billNos": billNosString,
            "issueDate": formattedChqDate,
            "clearanceDate": formattedClearDate,
            "notes": item["notes"] ?? "",
          });
        }

        chequeList.assignAll(tempList);
        filteredList.assignAll(tempList);
      } else if (res["message"] == "No cheques found") {
        chequeList.clear();
        filteredList.clear();
      }
    } catch (e) {
      log("Error fetching cheque data: $e");
      chequeList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
