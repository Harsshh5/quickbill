import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/text_style.dart';

class CommonSubmit extends StatelessWidget {
  const CommonSubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCardContainer(
      width: Get.width,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      gradient: appGradient1,
      child: Text(
        "Submit",
        style: appTextStyle(color: Colors.white),
      ),
    );
  }
}
