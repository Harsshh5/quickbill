import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/controller/client_controller/client_count.dart';
import '../../model/client_model/register_client.dart';
import '../../views/commons/text_style.dart';

class RegisterClientController extends GetxController {
  final ClientCountController clientCountController = Get.put(
    ClientCountController(),
  );

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

  TextEditingController companyName = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController gstNo = TextEditingController();

  Future<void> registerClient(
    String companyName,
    String clientName,
    String contact,
    String address,
    String gstNo,
  ) async {
    try {
      var res = await RegisterClientModel().registerNewClient(
        companyName,
        clientName,
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
                              "Client registered successfully.",
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

        clientCountController.getClientCount();

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
