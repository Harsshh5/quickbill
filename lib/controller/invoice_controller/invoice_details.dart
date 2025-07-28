import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/invoice_model/invoice_details.dart';

class InvoiceDetailsController extends GetxController{
  RxList<Map<String, String>> designList = <Map<String, String>>[].obs;
  RxInt invoiceNo = 0.obs;
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
    final String invoiceId = Get.arguments["invoiceId"];

    getInvoiceDetails(invoiceId);
  }

  Future<void> getInvoiceDetails(String invoiceId) async {
    var res = await InvoiceDetailsModel().fetchInvoiceDetails(invoiceId);

    log(res.toString());

    if (res["success"] == true) {
      invoiceNo.value = int.tryParse(res["details"]["invoiceNumber"].toString()) ?? 0;
      subTotal.value = int.tryParse(res["details"]["amountDetails"]["subTotal"].toString()) ?? 0;
      finalTotal.value = int.tryParse(res["details"]["amountDetails"]["totalAmount"].toString()) ?? 0;
      cgst.value = double.tryParse(res["details"]["amountDetails"]["cgst"].toString()) ?? 0.0;
      sgst.value = double.tryParse(res["details"]["amountDetails"]["sgst"].toString()) ?? 0.0;

      clientName.value = res["details"]["clientId"]["clientName"]?.toString() ?? "";
      companyName.value = res["details"]["clientId"]["companyName"]?.toString() ?? "";
      contact.value = res["details"]["clientId"]["contact"]?.toString() ?? "";
      gstNo.value = res["details"]["clientId"]["gstNo"]?.toString() ?? "";
      address.value = res["details"]["clientId"]["address"]?.toString() ?? "";
      status.value = res["details"]["status"]?.toString() ?? "";
      createDate.value = formatDateToDMY(res["details"]["createdAt"].toString());


      final designData = res["details"]["designDetails"];

      if (designData is List) {
        designList.value = designData.map<Map<String, String>>((item) {
          return {
            "designCategory": item["designCategory"]?.toString() ?? "",
            "quantity": item["quantity"]?.toString() ?? "",
            "rate": item["rate"]?.toString() ?? "",
            "amount": item["amount"]?.toString() ?? "",
            "notes": item["notes"]?.toString() ?? "",
          };
        }).toList();

      } else {
        designList.clear();
      }

      log(designList.toString());
    } else {
      designList.clear();
    }
  }
}