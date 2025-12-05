import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import '../../model/cheques_model/add_cheque.dart';

class AddChequeController extends GetxController {
  RxList<String> selectedBillIds = <String>[].obs;
  RxList<String> selectedBillNumbers = <String>[].obs;

  FocusNode bankFocus = FocusNode();
  FocusNode clientFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode chqNoFocus = FocusNode();
  FocusNode chqDtFocus = FocusNode();
  FocusNode clearDtFocus = FocusNode();
  FocusNode billNoFocus = FocusNode();

  RxString bankError = ''.obs;
  RxString clientError = ''.obs;
  RxString amountError = ''.obs;
  RxString chqNoError = ''.obs;
  RxString chqDtError = ''.obs;
  RxString clearDtError = ''.obs;
  RxString billNoError = ''.obs;

  TextEditingController bankName = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController clientId = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController chqNo = TextEditingController();
  TextEditingController chqDt = TextEditingController();
  TextEditingController clearDt = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController notes = TextEditingController();


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

  Future<void> addCheque({
    required String bankName,
    required String clientId,
    required String amount,
    required String chequeNumber,
    required String businessName,
    required String issueDate,
    required String clearanceDate,
    required List<String> billNos,
    required String notes
  }) async {
    try {
      var res = await AddChequeModel().registerCheque(
        bankName,
        clientId,
        amount,
        chequeNumber,
        businessName,
        issueDate,
        clearanceDate,
        billNos,
        notes
      );

      if (res["success"] == true) {
        AppSnackBar.show(message: "Cheque Added Successfully");

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
