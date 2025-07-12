import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/client_controller/client_list.dart';
import 'package:quickbill/model/client_model/delete_client.dart';

import '../../config/app_colors.dart';
import '../../views/commons/text_style.dart';
import 'client_count.dart';

class DeleteClientController extends GetxController {
  final ClientCountController clientCountController = Get.put(
    ClientCountController(),
  );
  final ClientListController clientListController = Get.put(
    ClientListController(),
  );

  Future<void> removeClient(String clientId) async {
    try {
      var res = await DeleteClientModel().deleteClient(clientId);

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
                          "Client deleted successfully.",
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
        clientCountController.getClientCount();

        Get.back();
      }

      else if (res["success"] == false) {

      }
    } catch (e) {
      log("Error : $e");
    }
  }
}