import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/invoice_controller/invoice_count.dart';
import 'package:quickbill/model/invoice_model/add_invoice.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import '../../views/masters/invoice_details.dart';

class DesignCardData {
  String? category;
  final TextEditingController totalDesigns = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();
}

class AddInvoiceController extends GetxController {

  final InvoiceCountController invoiceCountController = Get.put(InvoiceCountController());

  var designCardList = <DesignCardData>[DesignCardData()].obs;
  final ScrollController scrollController = ScrollController();

  final TextEditingController company = TextEditingController();
  final TextEditingController clientId = TextEditingController();

  final categoryList = ["Pallu", "SP. Allover", "Dupatta", "Neck / Panel", "Colors", "All Over Designs"];

  List<DropdownMenuEntry<String>> get categoryDropdownEntries {
    return categoryList
        .map((item) => DropdownMenuEntry(value: item, label: item))
        .toList();
  }

  RxDouble subtotal = 0.0.obs;
  RxDouble cgst = 0.0.obs;
  RxDouble sgst = 0.0.obs;
  RxDouble finalTotal = 0.0.obs;

  void calculateAmount(DesignCardData data) {
    final total = double.tryParse(data.totalDesigns.text) ?? 0;
    final rate = double.tryParse(data.rate.text) ?? 0;
    final result = total * rate;
    data.amount.text = result.toStringAsFixed(2);
    calculateTotals();
  }

  void calculateTotals() {
    double tempSubtotal = 0.0;
    for (var card in designCardList) {
      final amt = double.tryParse(card.amount.text) ?? 0;
      tempSubtotal += amt;
    }

    subtotal.value = tempSubtotal;
    if (AppConstants.abbreviation == "AN") {
      cgst.value = subtotal.value * 0.025;
      sgst.value = subtotal.value * 0.025;
    }
    finalTotal.value = subtotal.value + cgst.value + sgst.value;
  }

  void addDesignCard() {
    designCardList.add(DesignCardData());
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void removeDesignCard(int index) {
    if (designCardList.length > 1) {
      designCardList.removeAt(index);
      calculateTotals();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    for (var card in designCardList) {
      card.totalDesigns.dispose();
      card.rate.dispose();
      card.amount.dispose();
      card.note.dispose();
    }
    company.dispose();
    clientId.dispose();
    super.onClose();
  }

  List<Map<String, dynamic>> createDesignDetailsList() {
    List<Map<String, dynamic>> designDetailList = [];

    for (var card in designCardList) {
      designDetailList.add({
        "designCategory": "${card.category}",
        'quantity': int.tryParse(card.totalDesigns.text) ?? 0,
        'rate': double.tryParse(card.rate.text) ?? 0.0,
        'amount': double.tryParse(card.amount.text) ?? 0.0,
        'notes': card.note.text,
      });
    }

    return designDetailList;
  }


  Future<void> createInvoice() async {
    try {
      var res = await AddInvoiceModel().addNewInvoice(
        clientId: clientId.text,
        designDetails: createDesignDetailsList(),
        subTotal: subtotal.value.toDouble(),
        cgst: AppConstants.abbreviation == "AN" ? cgst.value.toDouble() : null,
        sgst: AppConstants.abbreviation == "AN" ? sgst.value.toDouble() : null,
        totalAmount: finalTotal.value.toDouble(),
      );

      log("Response from API: $res");

      if (res["success"] == true) {
        AppSnackBar.show(message: "Invoice Created Successfully");

        invoiceCountController.getInvoiceCount();

        var savedInvoiceId = res["data"]["invoice"]["_id"];

        await Get.to(() => InvoiceDetails(), arguments: {"invoiceId": savedInvoiceId});

        Get.back();

      }
      else if (res["success"] == false) {
        AppSnackBar.show(message: "Invoice Not Created! Try Again");
        log(res.toString());
      }
    } catch (e) {
      log("Error here: $e");
    } finally {
      update();
    }
  }
}
