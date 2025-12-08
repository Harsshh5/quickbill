import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import '../../model/payment_model/edit_payment.dart';
import 'payment_list.dart';

class EditPaymentController extends GetxController {
  final paymentsListController = Get.find<PaymentsListController>();
  String paymentEditId = "";

  RxList<String> selectedBillIds = <String>[].obs;
  RxList<String> selectedBillNumbers = <String>[].obs;

  var selectedMode = "Cheque".obs;

  // --------------------------------------
  final List<int> denominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];

  var denomControllers = <int, TextEditingController>{};

  var denomTotals = <int, int>{}.obs;

  var grandCashTotal = 0.0.obs;

  bool isInitializing = false;

  // --------------------------------------
  // -- Cheque FocusNodes
  FocusNode bankFocus = FocusNode();
  FocusNode chqNoFocus = FocusNode();
  FocusNode chqDtFocus = FocusNode();
  FocusNode clearDtFocus = FocusNode();

  // -- Cash FocusNodes
  FocusNode cashDtFocus = FocusNode();

  // -- Online FocusNodes
  FocusNode transactionIdFocus = FocusNode();
  FocusNode transactionDtFocus = FocusNode();

  // -- Common FocusNodes
  FocusNode clientFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode billNoFocus = FocusNode();

  // --------------------------------------
  // -- Cheque Error
  RxString bankError = ''.obs;
  RxString chqNoError = ''.obs;
  RxString chqDtError = ''.obs;
  RxString clearDtError = ''.obs;

  // -- Cash Error
  RxString cashDtError = ''.obs;

  // -- Online Error
  RxString transactionIdError = ''.obs;
  RxString transactionDtError = ''.obs;

  // -- Common Error
  RxString clientError = ''.obs;
  RxString amountError = ''.obs;
  RxString billNoError = ''.obs;

  // --------------------------------------
  // -- Cheque Controller
  TextEditingController bankName = TextEditingController();
  TextEditingController chqNo = TextEditingController();
  TextEditingController chqDt = TextEditingController();
  TextEditingController clearDt = TextEditingController();

  // -- Cash Controller
  TextEditingController cashDt = TextEditingController();

  // -- Online Controller
  TextEditingController transactionId = TextEditingController();
  TextEditingController transactionDt = TextEditingController();

  // -- Common Controller
  TextEditingController clientName = TextEditingController();
  TextEditingController clientId = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController notes = TextEditingController();

  // --- MODIFIED: Robust Initialization for Edit Mode ---
  void setEditableValues(Map<String, dynamic> payment, String paymentId) {
    // START INITIALIZATION: Block the listener from updating Amount
    isInitializing = true;

    try {
      paymentEditId = paymentId;

      String modeRaw = (payment["payment_mode"] ?? "cheque").toString().toLowerCase();

      if (modeRaw == "cash") {
        selectedMode.value = "Cash";
      } else if (modeRaw == "online") {
        selectedMode.value = "Online";
      } else {
        selectedMode.value = "Cheque";
      }

      log("Edit Mode Set To: ${selectedMode.value}");

      // 1. Populate Common Fields
      clientName.text = payment["clientName"] ?? "";

      // Keep the original amount first. If denoms exist, it will be recalculated later.
      // If denoms are missing, we keep this value instead of showing 0.
      amount.text = payment["amount"]?.toString() ?? "0";

      notes.text = payment["notes"] ?? "";
      billNo.text = payment["billNos"] ?? "";

      if (payment["rawBillIds"] != null && payment["rawBillIds"] is List) {
        selectedBillIds.assignAll((payment["rawBillIds"] as List).map((e) => e.toString()).toList());
      }

      // 2. Clear Fields
      bankName.clear();
      chqNo.clear();
      chqDt.clear();
      clearDt.clear();
      transactionId.clear();
      transactionDt.clear();
      cashDt.clear();

      for (var d in denominations) {
        denomControllers[d]?.clear();
        denomTotals[d] = 0;
      }
      // Reset total BUT don't update Amount yet (handled by isInitializing)
      grandCashTotal.value = 0.0;

      // 3. Populate Specifics
      if (selectedMode.value == "Cheque") {
        bankName.text = payment["realBankName"] ?? payment["bankName"] ?? "";
        chqNo.text = payment["chequeNumber"] ?? "";
        chqDt.text = payment["issueDate"] ?? "";
        clearDt.text = payment["clearanceDate"] ?? "";
      }
      else if (selectedMode.value == "Online") {
        transactionId.text = payment["chequeNumber"] ?? "";
        transactionDt.text = payment["issueDate"] ?? "";
      }
      else if (selectedMode.value == "Cash") {
        cashDt.text = payment["issueDate"] ?? "";

        // Populate Denominations
        if (payment["cashDenominations"] != null && payment["cashDenominations"] is Map) {
          Map<dynamic, dynamic> denoms = payment["cashDenominations"];

          denoms.forEach((key, value) {
            int? denom = int.tryParse(key.toString());
            int? count = int.tryParse(value.toString());

            if (denom != null && count != null && denomControllers.containsKey(denom)) {
              denomControllers[denom]?.text = count.toString();
              // Calculate specific row without triggering global Amount update yet
              int rowTotal = count * denom;
              denomTotals[denom] = rowTotal;
            }
          });

          // Manually calculate grand total once after loop
          int tempTotal = 0;
          denomTotals.forEach((key, value) {
            tempTotal += value;
          });
          grandCashTotal.value = tempTotal.toDouble();

          // Sync Amount field with calculated total
          amount.text = tempTotal.toString();
        }
      }
    } finally {
      // STOP INITIALIZATION: Re-enable listener
      isInitializing = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    for (var d in denominations) {
      denomControllers[d] = TextEditingController();
      denomTotals[d] = 0;

      denomControllers[d]!.addListener(() {
        if (!isInitializing) {
          calculateDenominationTotal(d);
        }
      });
    }

    // LISTENER: Updates 'Amount' field when tiles change
    ever(grandCashTotal, (double total) {
      if (selectedMode.value == "Cash" && !isInitializing) {
        amount.text = total.toInt().toString();
      }
    });
  }

  void calculateDenominationTotal(int d) {
    String text = denomControllers[d]!.text;
    int count = int.tryParse(text) ?? 0;

    denomTotals[d] = count * d;

    int tempTotal = 0;
    denomTotals.forEach((key, value) {
      tempTotal += value;
    });

    grandCashTotal.value = tempTotal.toDouble();
  }


  @override
  void onClose() {
    for (var controller in denomControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> editPayment({
    required String paymentMode,
    required String clientId,
    required String amount,
    required List<String> billNos,
    required String businessName,
    required String notes,

    String? bankName,
    String? chequeNumber,
    String? issueDate,
    String? clearanceDate,
    String? transactionId,
    String? transactionDate,
    String? cashDate,
    Map<String, int>? cashDenominations,

  }) async {
    try {
      var res = await EditPaymentModel().updatePayment(
        id: paymentEditId,
        amount: double.tryParse(amount) ?? 0.0,
        billNos: billNos,
        paymentMode: paymentMode,
        notes: notes,

        bankName: bankName,
        chequeNumber: chequeNumber,
        issueDate: issueDate,
        clearanceDate: clearanceDate,

        transactionId: transactionId,
        transactionDate: transactionDate,

        cashDate: cashDate,
        cashDenominations: cashDenominations,
      );

      if (res["success"] == true) {
        AppSnackBar.show(message: "Payment Edited Successfully.");
        paymentsListController.getPaymentsList();

        Get.back();

        // log(res["data"]);
      } else if (res["success"] == false) {
        AppSnackBar.show(message: "Some Error Occurred. Try again.");
        log(res.toString());
      }
    } catch (e) {
      log("Error : $e");
    } finally {
      update();
    }
  }

}