import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/invoice_controller/invoice_count.dart';
import 'package:quickbill/model/invoice_model/add_invoice.dart';

import '../../config/app_colors.dart';
import '../../views/commons/text_style.dart';

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

  final categoryList = ["Pallu", "SP. Allover", "Dupatta", "Neck / Panel", "Colors", "All Ever Designs"];

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
        'note': card.note.text,
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

      if (res["success"] == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            elevation: 5,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            backgroundColor: AppColors.medium,
            duration: Duration(seconds: 3),
            content: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(seconds: 3),
              builder:
                  (context, value, child) => SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Invoice Created successfully.", style: appTextStyle(color: Colors.white)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.green.shade700,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        invoiceCountController.getInvoiceCount();
        Get.back();

      }
      else if (res["success"] == false) {
        log(res.toString());
      }
    } catch (e) {
      log("Error : $e");
    } finally {
      update();
    }
  }
}
