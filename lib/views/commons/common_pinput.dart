import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:quickbill/views/commons/text_style.dart';

import '../../config/app_colors.dart';

class CommonPinput extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onCompleted;
  const CommonPinput({super.key, this.controller, this.errorText, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      enabled: true,
      autofocus: true,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      errorText: errorText,
      forceErrorState: false,

      controller: controller,

      onCompleted: onCompleted,

      defaultPinTheme: PinTheme(
        height: 60,
        width: 55,
        textStyle: appTextStyle(fontSize: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.medium),
          boxShadow: [
            BoxShadow(color: AppColors.medium, blurRadius: 5),
          ],
        ),
      ),

      focusedPinTheme: PinTheme(
        height: 70,
        width: 65,
        textStyle: appTextStyle(fontSize: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.medium),
          boxShadow: [
            BoxShadow(color: AppColors.medium, blurRadius: 5),
          ],
        ),
      ),

      errorPinTheme: PinTheme(
        height: 70,
        width: 65,
        textStyle: appTextStyle(fontSize: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.redAccent, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent,
              blurRadius: 5,
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
      ),
    );
  }
}
