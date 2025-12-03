import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/invoice_model/invoice_details.dart';

class InvoiceDetailsController extends GetxController {
  RxList<Map<String, String>> designList = <Map<String, String>>[].obs;
  RxInt invoiceNo = 0.obs;

  RxInt discountValue = 0.obs;

  RxInt subTotal = 0.obs;
  RxInt finalTotal = 0.obs;
  RxDouble cgst = 0.0.obs;
  RxDouble sgst = 0.0.obs;
  RxString clientName = "".obs;
  RxString companyName = "".obs;
  RxString contact = "".obs;
  RxString gstNo = "".obs;
  RxString address = "".obs;
  RxString status = "".obs;
  RxString createDate = "".obs;

  String formatDateToDMY(String inputDate) {
    try {
      final date = DateTime.parse(inputDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure arguments exist before accessing
    if(Get.arguments != null && Get.arguments["invoiceId"] != null){
      final String invoiceId = Get.arguments["invoiceId"];
      getInvoiceDetails(invoiceId);
    }
  }

  Future<void> getInvoiceDetails(String invoiceId) async {
    var res = await InvoiceDetailsModel().fetchInvoiceDetails(invoiceId);

    log(res.toString());

    if (res["success"] == true) {
      var details = res["details"]; // Helper variable to make code cleaner
      var amountDetails = details["amountDetails"];
      var clientDetails = details["clientId"];

      invoiceNo.value = int.tryParse(details["invoiceNumber"].toString()) ?? 0;


      subTotal.value = int.tryParse(amountDetails["subTotal"].toString()) ?? 0;
      finalTotal.value = int.tryParse(amountDetails["totalAmount"].toString()) ?? 0;
      cgst.value = double.tryParse(amountDetails["cgst"].toString()) ?? 0.0;
      sgst.value = double.tryParse(amountDetails["sgst"].toString()) ?? 0.0;

      clientName.value = clientDetails["clientName"]?.toString() ?? "";
      companyName.value = clientDetails["companyName"]?.toString() ?? "";
      contact.value = clientDetails["contact"]?.toString() ?? "";
      gstNo.value = clientDetails["gstNo"]?.toString() ?? "";
      address.value = clientDetails["address"]?.toString() ?? "";

      status.value = details["status"]?.toString() ?? "";
      createDate.value = formatDateToDMY(details["createdAt"].toString());

      final designData = details["designDetails"];

      if (designData is List) {
        designList.value = designData.map<Map<String, String>>((item) {

          final double rate = double.tryParse(item["rate"].toString()) ?? 0.0;
          final int qty = int.tryParse(item["quantity"].toString()) ?? 0;
          final double calculatedAmount = rate * qty;


          return {
            "designCategory": item["designCategory"]?.toString() ?? "",
            "quantity": item["quantity"]?.toString() ?? "0",
            "rate": item["rate"]?.toString() ?? "0",
            "amount": item["amount"]?.toString() ?? "0",

            "amountBeforeDiscount": calculatedAmount.toStringAsFixed(0),

            "discountValue": item["discountValue"]?.toString() ?? "0",
            "discountMode": item["discountMode"]?.toString() ?? "",
            "additionalCharges": item["additionalCharges"]?.toString() ?? "0",
            "notes": item["notes"]?.toString() ?? "",
          };
        }).toList();
      } else {
        designList.clear();
      }

      log("Parsed Design List: ${designList.toString()}");
    } else {
      designList.clear();
    }
  }
}