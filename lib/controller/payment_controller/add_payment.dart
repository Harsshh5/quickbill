import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import '../../model/payment_model/add_payment.dart';
import 'payment_list.dart';

class AddPaymentController extends GetxController {
  final paymentsListController = Get.find<PaymentsListController>();

  List<DropdownMenuEntry<String>> get modeDropdownEntries {
    return ["Cheque", "Cash", "Online"]
        .map((item) => DropdownMenuEntry(value: item, label: item))
        .toList();
  }

  RxList<String> selectedBillIds = <String>[].obs;
  RxList<String> selectedBillNumbers = <String>[].obs;

  var selectedMode = "Cheque".obs;

  // --------------------------------------
  final List<int> denominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];

  var denomControllers = <int, TextEditingController>{};

  var denomTotals = <int, int>{}.obs;

  var grandCashTotal = 0.0.obs;

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


  // --------------------------------------
  final bankNameList = [
    "Axis Bank",
    "Bandhan Bank",
    "Bank of Baroda",
    "Bank of India",
    "Bank of Maharashtra",
    "Canara Bank",
    "Central Bank of India",
    "City Union Bank",
    "Federal Bank",
    "HDFC Bank",
    "ICICI Bank",
    "IDBI Bank",
    "IDFC First Bank",
    "Indian Bank",
    "Indian Overseas Bank",
    "IndusInd Bank",
    "Jammu & Kashmir Bank",
    "Karnataka Bank",
    "Karur Vysya Bank",
    "Kotak Mahindra Bank",
    "Punjab National Bank",
    "RBL Bank",
    "Saraswat Bank",
    "South Indian Bank",
    "State Bank of India",
    "Sutex Bank"
        "Union Bank of India",
    "Yes Bank",
  ];

  List<DropdownMenuEntry<String>> get bankNameDropdownEntries {
    return bankNameList.map((item) => DropdownMenuEntry(value: item, label: item)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    for (var d in denominations) {
      denomControllers[d] = TextEditingController();
      denomTotals[d] = 0;

      denomControllers[d]!.addListener(() {
        calculateDenominationTotal(d);
      });
    }
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

    // OPTIONAL: If you want this to auto-fill the main 'Amount' field
    amount.text = tempTotal.toString();
  }

  @override
  void onClose() {
    for (var controller in denomControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }


  Future<void> addPayment({
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
      var res = await AddPaymentModel().registerPayment(
        clientId: clientId,
        businessName: businessName,
        amount: double.parse(amount),
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
        AppSnackBar.show(message: "Payment Added Successfully");
        paymentsListController.getPaymentsList();

        Get.back();
      } else if (res["success"] == false) {
        AppSnackBar.show(message: "Some Error Occurred");
        log(res.toString());
      }
    } catch (e) {
      log("Error : $e");
    } finally {
      update();
    }
  }
}
