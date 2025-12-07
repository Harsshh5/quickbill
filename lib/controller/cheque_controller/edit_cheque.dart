import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/snackbar.dart';

import '../../model/cheques_model/edit_cheque.dart';
import 'cheques_list.dart';

class EditChequeController extends GetxController {
  final chequeListController = Get.find<ChequesListController>();
  String chequeEditId = "";

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

  void setEditableValues(Map<String, dynamic> cheque, chequeId) {
    bankName.text = cheque["bankName"] ?? "";
    clientName.text = cheque["clientName"] ?? "";
    amount.text = cheque["amount"] ?? "";
    chqNo.text = cheque["chequeNumber"] ?? "";
    chqDt.text = cheque["issueDate"] ?? "";
    clearDt.text = cheque["clearanceDate"] ?? "";
    billNo.text = cheque["billNos"] ?? "";
    notes.text = cheque["notes"] ?? "";

    chequeEditId = chequeId;
  }

  Future<void> editCheque({
    required String bankName,
    required String clientName,
    required String amount,
    required String chqNo,
    required String chqDt,
    required String clearDt,
    required List<String> billNo,
    required String notes,
  }) async {
    try {
      var res = await EditChequeModel().updateCheque(
        chequeEditId,
        bankName,
        clientName,
        chqNo,
        amount,
        chqDt,
        clearDt,
        billNo,
        notes,
      );

      if (res["success"] == true) {
        AppSnackBar.show(message: "Cheque Edited Successfully.");
        chequeListController.getChequeList();

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