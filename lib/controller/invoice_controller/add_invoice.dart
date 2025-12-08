import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/invoice_controller/invoice_count.dart';
import 'package:quickbill/controller/invoice_controller/invoice_list.dart';

import '../../model/invoice_model/add_invoice.dart';
import '../../views/commons/snackbar.dart';
import '../../views/masters/invoice_details.dart';

class DesignCardData {
  String? category;
  final TextEditingController totalDesigns = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController additionalAMT = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  RxString discountType = "percentage".obs;
}

class AddInvoiceController extends GetxController {

  final InvoiceCountController invoiceCountController = Get.put(InvoiceCountController());
  final InvoiceListController invoiceListController = Get.put(InvoiceListController());


  var designCardList = <DesignCardData>[DesignCardData()].obs;
  final ScrollController scrollController = ScrollController();

  final PageController pageController = PageController();

  final TextEditingController company = TextEditingController();
  final TextEditingController clientId = TextEditingController();

  RxInt currentCardIndex = 0.obs;
  var invoiceDate = DateTime.now().obs;

  final categoryList = ["Pallu", "SP. Allover", "Dupatta", "Neck / Panel", "Colors", "All Over Designs"];

  List<DropdownMenuEntry<String>> get categoryDropdownEntries {
    return categoryList
        .map((item) => DropdownMenuEntry(value: item, label: item))
        .toList();
  }


  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: invoiceDate.value,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != invoiceDate.value) {
      invoiceDate.value = picked;
    }
  }


  RxDouble subtotal = 0.0.obs;
  RxDouble cgst = 0.0.obs;
  RxDouble sgst = 0.0.obs;
  RxDouble finalTotal = 0.0.obs;

  void calculateAmount(DesignCardData data) {
    final qty = double.tryParse(data.totalDesigns.text) ?? 0;
    final rate = double.tryParse(data.rate.text) ?? 0;
    final discountVal = double.tryParse(data.discountController.text) ?? 0;
    final additionalAmt = double.tryParse(data.additionalAMT.text) ?? 0;


    double baseAmount = qty * rate;
    double finalAmount = 0.0;

    if (data.discountType.value == "percentage") {
      double discountAmount = (baseAmount * discountVal) / 100;
      finalAmount = baseAmount - discountAmount;
    } else {
      finalAmount = baseAmount - discountVal;
    }

    if(data.additionalAMT.text.isNotEmpty) {
      finalAmount += additionalAmt;
    }

    if (finalAmount < 0) finalAmount = 0;

    data.amount.text = finalAmount.toStringAsFixed(2);
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
    } else if(AppConstants.abbreviation == "LA"){
      cgst.value = subtotal.value * 0.09;
      sgst.value = subtotal.value * 0.09;
    }
    finalTotal.value = subtotal.value + cgst.value + sgst.value;
  }

  void addDesignCard() {
    designCardList.add(DesignCardData());
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
      card.discountController.dispose();
      card.additionalAMT.dispose();
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
        'discountValue': double.tryParse(card.discountController.text) ?? 0.0,
        'discountMode': card.discountType.value,
        'additionalCharges':double.tryParse(card.additionalAMT.text) ?? 0.0,
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
        invoiceDate: invoiceDate.value.toString(),
        designDetails: createDesignDetailsList(),
        subTotal: subtotal.value.toDouble(),
        cgst: (AppConstants.abbreviation == "AN") || (AppConstants.abbreviation == "LA") ? cgst.value.toDouble() : null,
        sgst: (AppConstants.abbreviation == "AN") || (AppConstants.abbreviation == "LA") ? sgst.value.toDouble() : null,
        totalAmount: finalTotal.value.toDouble().ceilToDouble(),
      );

      if (res["success"] == true) {
        AppSnackBar.show(message: "Invoice Created Successfully");

        invoiceCountController.getInvoiceCount();
        invoiceListController.getInvoiceList();

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