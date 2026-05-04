import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/invoice_controller/invoice_count.dart';
import 'package:quickbill/controller/invoice_controller/invoice_details.dart';
import 'package:quickbill/controller/invoice_controller/invoice_list.dart';
import 'package:quickbill/model/invoice_model/edit_invoice.dart';
import 'package:quickbill/model/invoice_model/invoice_details.dart';
import 'package:quickbill/views/commons/snackbar.dart';

class EditInvoiceDesignData {
  String? category;
  final TextEditingController totalDesigns = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController additionalAMT = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  RxString discountType = "percentage".obs;

  RxString categoryError = ''.obs;
  RxString quantityError = ''.obs;
  RxString rateError = ''.obs;
  RxString discountError = ''.obs;
  RxString additionalAmountError = ''.obs;
}

class EditInvoiceController extends GetxController {
  final InvoiceCountController invoiceCountController = Get.put(
    InvoiceCountController(),
  );
  final InvoiceListController invoiceListController = Get.put(
    InvoiceListController(),
  );

  var designCardList = <EditInvoiceDesignData>[].obs;
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController();

  final TextEditingController company = TextEditingController();
  final TextEditingController clientId = TextEditingController();

  RxString invoiceEditId = ''.obs;
  RxInt invoiceNumber = 0.obs;
  RxString status = ''.obs;
  Rx<DateTime> invoiceDate = DateTime.now().obs;
  RxInt currentCardIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;

  RxString companyError = ''.obs;

  final categoryList = [
    "Pallu",
    "SP. Allover",
    "Dupatta",
    "Neck / Panel",
    "Colors",
    "All Over Designs",
  ];

  List<DropdownMenuEntry<String>> get categoryDropdownEntries {
    return categoryList
        .map((item) => DropdownMenuEntry(value: item, label: item))
        .toList();
  }

  RxDouble subtotal = 0.0.obs;
  RxDouble cgst = 0.0.obs;
  RxDouble sgst = 0.0.obs;
  RxDouble finalTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["invoiceId"] != null) {
      fetchEditableInvoice(args["invoiceId"].toString());
    } else if (args != null && args["invoice"] is Map<String, dynamic>) {
      setEditableValues(args["invoice"] as Map<String, dynamic>);
    } else {
      designCardList.add(EditInvoiceDesignData());
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;
    try {
      return DateFormat('dd-MM-yyyy').parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatEditableDate() {
    return DateFormat('yyyy-MM-dd').format(invoiceDate.value);
  }

  Future<void> fetchEditableInvoice(String invoiceId) async {
    isLoading.value = true;
    try {
      var res = await InvoiceDetailsModel().fetchInvoiceDetails(invoiceId);
      if (res["success"] == true) {
        setEditableValues(res["details"]);
      } else {
        AppSnackBar.show(message: "Invoice details not found.");
      }
    } catch (e) {
      log("Error: $e");
      AppSnackBar.show(message: "Unable to load invoice.");
    } finally {
      isLoading.value = false;
    }
  }

  void setEditableValues(Map<String, dynamic> invoice) {
    final details =
        invoice["invoice"] is Map<String, dynamic>
            ? invoice["invoice"] as Map<String, dynamic>
            : invoice;
    final amountDetails =
        details["amountDetails"] is Map ? details["amountDetails"] as Map : {};
    final clientDetails =
        details["clientId"] is Map ? details["clientId"] as Map : {};

    invoiceEditId.value =
        (details["_id"] ??
                details["id"] ??
                details["invoiceId"] ??
                invoiceEditId.value)
            .toString();
    invoiceNumber.value =
        int.tryParse(details["invoiceNumber"]?.toString() ?? "") ?? 0;
    status.value = details["status"]?.toString() ?? "";
    invoiceDate.value = _parseDate(details["invoiceDate"]);

    company.text =
        clientDetails["companyName"]?.toString() ??
        details["companyName"]?.toString() ??
        "";
    clientId.text =
        clientDetails["_id"]?.toString() ??
        clientDetails["id"]?.toString() ??
        details["clientId"]?.toString() ??
        "";

    subtotal.value =
        double.tryParse(amountDetails["subTotal"]?.toString() ?? "0") ?? 0.0;
    cgst.value =
        double.tryParse(amountDetails["cgst"]?.toString() ?? "0") ?? 0.0;
    sgst.value =
        double.tryParse(amountDetails["sgst"]?.toString() ?? "0") ?? 0.0;
    finalTotal.value =
        double.tryParse(amountDetails["totalAmount"]?.toString() ?? "0") ?? 0.0;

    final designData = details["designDetails"];
    final List<EditInvoiceDesignData> editableDesigns = [];

    if (designData is List) {
      for (var item in designData) {
        final data = EditInvoiceDesignData();
        data.category = item["designCategory"]?.toString();
        data.totalDesigns.text = item["quantity"]?.toString() ?? "";
        data.rate.text = item["rate"]?.toString() ?? "";
        data.discountController.text = item["discountValue"]?.toString() ?? "";
        data.discountType.value =
            item["discountMode"]?.toString().isNotEmpty == true
                ? item["discountMode"].toString()
                : "percentage";
        data.additionalAMT.text = item["additionalCharges"]?.toString() ?? "";
        data.note.text = item["notes"]?.toString() ?? "";
        calculateAmount(data);
        editableDesigns.add(data);
      }
    }

    designCardList.assignAll(
      editableDesigns.isEmpty ? [EditInvoiceDesignData()] : editableDesigns,
    );
    currentCardIndex.value = 0;
    calculateTotals();
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

  void calculateAmount(EditInvoiceDesignData data) {
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

    if (data.additionalAMT.text.isNotEmpty) {
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
    cgst.value = 0.0;
    sgst.value = 0.0;

    if (AppConstants.abbreviation == "AN") {
      cgst.value = subtotal.value * 0.025;
      sgst.value = subtotal.value * 0.025;
    } else if (AppConstants.abbreviation == "LA") {
      cgst.value = subtotal.value * 0.09;
      sgst.value = subtotal.value * 0.09;
    }

    finalTotal.value = subtotal.value + cgst.value + sgst.value;
  }

  void addDesignCard() {
    designCardList.add(EditInvoiceDesignData());
  }

  void removeDesignCard(int index) {
    if (designCardList.length > 1) {
      designCardList.removeAt(index);
      calculateTotals();
    }
  }

  void _clearErrors() {
    companyError.value = '';
    for (var card in designCardList) {
      card.categoryError.value = '';
      card.quantityError.value = '';
      card.rateError.value = '';
      card.discountError.value = '';
      card.additionalAmountError.value = '';
    }
  }

  bool validateInvoice() {
    _clearErrors();

    if (clientId.text.trim().isEmpty || company.text.trim().isEmpty) {
      companyError.value = "Select company.";
      return false;
    }

    if (designCardList.isEmpty) {
      AppSnackBar.show(message: "Add at least one design.");
      return false;
    }

    for (int i = 0; i < designCardList.length; i++) {
      final card = designCardList[i];
      final qty = double.tryParse(card.totalDesigns.text.trim());
      final rateValue = double.tryParse(card.rate.text.trim());
      final discountValue =
          card.discountController.text.trim().isEmpty
              ? 0.0
              : double.tryParse(card.discountController.text.trim());
      final additionalValue =
          card.additionalAMT.text.trim().isEmpty
              ? 0.0
              : double.tryParse(card.additionalAMT.text.trim());

      if (card.category == null ||
          card.category!.trim().isEmpty ||
          !categoryList.contains(card.category)) {
        card.categoryError.value = "Select category.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      if (qty == null || qty <= 0 || qty % 1 != 0) {
        card.quantityError.value = "Enter valid total designs.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      if (rateValue == null || rateValue <= 0) {
        card.rateError.value = "Enter valid rate.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      if (discountValue == null || discountValue < 0) {
        card.discountError.value = "Enter valid discount.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      if (card.discountType.value == "percentage" && discountValue > 100) {
        card.discountError.value = "Discount cannot exceed 100%.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      if (additionalValue == null || additionalValue < 0) {
        card.additionalAmountError.value = "Enter valid amount.";
        currentCardIndex.value = i;
        _jumpToCard(i);
        return false;
      }

      calculateAmount(card);
    }

    if (subtotal.value <= 0 || finalTotal.value <= 0) {
      AppSnackBar.show(message: "Invoice total must be greater than zero.");
      return false;
    }

    return true;
  }

  void _jumpToCard(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
        'additionalCharges': double.tryParse(card.additionalAMT.text) ?? 0.0,
        'amount': double.tryParse(card.amount.text) ?? 0.0,
        'notes': card.note.text.trim(),
      });
    }

    return designDetailList;
  }

  Future<void> updateInvoice() async {
    if (!validateInvoice()) return;

    isSubmitting.value = true;
    try {
      var res = await EditInvoiceModel().updateInvoice(
        invoiceId: invoiceEditId.value,
        clientId: clientId.text.trim(),
        invoiceDate: _formatEditableDate(),
        designDetails: createDesignDetailsList(),
        subTotal: subtotal.value.toDouble(),
        cgst:
            (AppConstants.abbreviation == "AN") ||
                    (AppConstants.abbreviation == "LA")
                ? cgst.value.toDouble()
                : null,
        sgst:
            (AppConstants.abbreviation == "AN") ||
                    (AppConstants.abbreviation == "LA")
                ? sgst.value.toDouble()
                : null,
        totalAmount: finalTotal.value.toDouble().ceilToDouble(),
      );

      if (res["success"] == true) {
        AppSnackBar.show(message: "Invoice Updated Successfully.");
        invoiceCountController.getInvoiceCount();
        invoiceListController.getInvoiceList();

        if (Get.isRegistered<InvoiceDetailsController>()) {
          Get.find<InvoiceDetailsController>().getInvoiceDetails(
            invoiceEditId.value,
          );
        }

        Get.back();
      } else {
        AppSnackBar.show(message: "Invoice Not Updated! Try Again");
        log(res.toString());
      }
    } catch (e) {
      log("Error here: $e");
      AppSnackBar.show(message: "Some Error Occurred. Try again.");
    } finally {
      isSubmitting.value = false;
      update();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    pageController.dispose();
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
}
