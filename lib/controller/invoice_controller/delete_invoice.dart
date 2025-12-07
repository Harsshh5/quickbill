import 'dart:developer';

import 'package:get/get.dart';
import 'package:quickbill/controller/invoice_controller/invoice_count.dart';
import 'package:quickbill/controller/invoice_controller/invoice_list.dart';

import '../../model/invoice_model/delete_invoice.dart';
import '../../views/commons/snackbar.dart';

class DeleteInvoiceController extends GetxController {
  final InvoiceCountController iCC = Get.put(InvoiceCountController());
  final InvoiceListController iLC = Get.put(InvoiceListController());

  Future<void> removeInvoice(String invoiceId) async {
    try {
      var res = await DeleteInvoiceModel().deleteInvoice(invoiceId);

      if (res["success"] == true) {
        AppSnackBar.show(message: "Invoice deleted successfully.");

        iLC.getInvoiceList();
        iCC.getInvoiceCount();

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