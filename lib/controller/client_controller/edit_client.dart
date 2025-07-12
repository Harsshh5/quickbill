import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/client_controller/client_list.dart';

import '../../config/app_colors.dart';
import '../../model/client_model/edit_client.dart';
import '../../views/commons/text_style.dart';

class EditClientController extends GetxController {
  ClientListController clientListController = Get.put(ClientListController());

  String clientEditId = "";

  TextEditingController companyName = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController gstNo = TextEditingController();

  FocusNode companyFocus = FocusNode();
  FocusNode clientFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode gstFocus = FocusNode();

  RxString companyError = ''.obs;
  RxString clientError = ''.obs;
  RxString contactError = ''.obs;
  RxString addressError = ''.obs;
  RxString gstError = ''.obs;

  void setEditableValues(Map<String, String> client, clientId) {
    companyName.text = client["companyName"] ?? "";
    clientName.text = client["clientName"] ?? "";
    address.text = client["address"] ?? "";
    contact.text = client["contact"] ?? "";
    gstNo.text = client["gstNo"] ?? "";

    clientEditId = clientId;
  }

  Future<void> editClient(
      String companyName,
      String clientName,
      String clientId,
      String contact,
      String address,
      String gstNo,
      ) async {
    try {
      var res = await EditClientModel().updateClient(
        companyName,
        clientName,
        clientId,
        contact,
        address,
        gstNo,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            elevation: 5,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
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
                        child: Text(
                          "Client Updated successfully.",
                          style: appTextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.green.shade700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        clientListController.getClientList();

        Get.back();

        // log(res["data"]);
      } else if (res["success"] == false) {
        if (res["data"]["errorCode"] == 1) {
          contactError.value = '';
          contactError.value = "Contact Already Exists.";
          contactFocus.requestFocus();
          return;
        } else if (res["data"]["errorCode"] == 2) {
          companyError.value = "";
          companyError.value = "Company Name Already Exists";
          companyFocus.requestFocus();
          return;
        } else if (res["data"]["errorCode"] == 3) {
          gstError.value = "";
          gstError.value = "GST No. Already Exists.";
          gstFocus.requestFocus();
          return;
        }

        log(res.toString());
      }
    } catch (e) {
      log("Error : $e");
    } finally {
      update();
    }
  }
}
