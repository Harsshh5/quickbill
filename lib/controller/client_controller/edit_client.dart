import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditClientController extends GetxController {

  TextEditingController companyName = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController gstNo = TextEditingController();

  void setEditableValues(Map<String, String> client){

    companyName.text = client["companyName"] ?? "";
    clientName.text = client["clientName"] ?? "";
    address.text = client["address"] ?? "";
    contact.text = client["contact"] ?? "";
    gstNo.text = client["gstNo"] ?? "";

  }
}