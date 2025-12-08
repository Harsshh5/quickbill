import 'dart:developer';

import 'package:get/get.dart';
import '../../config/app_constants.dart';
import '../../model/payment_model/payment_list.dart';

class PaymentsListController extends GetxController {
  RxList<Map<String, dynamic>> filteredList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> paymentList = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    await getPaymentsList();
    super.onInit();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(paymentList);
    } else {
      filteredList.assignAll(
        paymentList.where((item) {
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
  Future<void> getPaymentsList() async {
    isLoading.value = true;
    final String businessName = AppConstants.abbreviation;

    try {
      var res = await PaymentListModel().fetchPayments(businessName);

      if (res["success"] == true && res["payments"] != null) {

        List<Map<String, dynamic>> richList = [];

        List<dynamic> serverData = res["payments"];

        for (var item in serverData) {
          String billNosString = "";
          if (item["billNos"] != null && item["billNos"] is List) {
            billNosString = (item["billNos"] as List).join(", ");
          } else {
            billNosString = item["billNos"]?.toString() ?? "";
          }

          String mode = (item["payment_mode"] ?? "cheque").toString().toLowerCase();

          String primaryDate = "";
          String secondaryDate = "";
          String referenceNumber = "";
          String bankOrMode = "";

          if (mode == "online") {
            referenceNumber = item["transactionId"] ?? "";
            primaryDate = item["transactionDate"] ?? "";
            bankOrMode = "Online Transfer";
          }
          else if (mode == "cash") {
            referenceNumber = "CASH";
            primaryDate = item["cashDate"] ?? "";
            bankOrMode = "Cash Payment";
          }
          else {
            referenceNumber = item["chequeNumber"] ?? "";
            primaryDate = item["issueDate"] ?? "";
            secondaryDate = item["clearanceDate"] ?? "";
            bankOrMode = item["bankName"] ?? "";
          }

          String formattedPrimaryDate = _safeDateFormat(primaryDate);
          String formattedSecondaryDate = _safeDateFormat(secondaryDate);

          String displayClient = item["companyName"] ?? item["clientName"] ?? "Unknown Client";

          richList.add({
            "id": item["_id"] ?? "",
            "payment_mode": mode,
            "bankName": bankOrMode,
            "chequeNumber": referenceNumber,
            "issueDate": formattedPrimaryDate,
            "clearanceDate": formattedSecondaryDate,
            "clientName": displayClient,
            "amount": item["amount"]?.toString() ?? "0",
            "billNos": billNosString,
            "notes": item["notes"] ?? "",
            "cashDenominations": item["cashDenominations"],
            "realBankName": item["bankName"],
            "rawBillIds": item["billNos"],
          });
        }

        paymentList.assignAll(richList);
        filteredList.assignAll(richList);
      } else {
        paymentList.clear();
        filteredList.clear();
      }
    } catch (e) {
      log("Error fetching payment data: $e");
      paymentList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  String _safeDateFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
    } catch (e) {
      return dateString;
    }
  }
}
