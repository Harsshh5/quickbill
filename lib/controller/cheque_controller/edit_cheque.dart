import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditChequeController extends GetxController {

  String clientChequeId = "";

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

}