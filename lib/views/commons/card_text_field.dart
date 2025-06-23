import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/views/commons/text_style.dart';

class CommonTextField extends StatelessWidget {

  final bool? autofocus;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? suffixIcon;
  final bool? readOnly;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  const CommonTextField({super.key, this.autofocus, this.hintText, this.controller, this.focusNode, this.keyboardType, this.obscureText, this.onChanged, this.onSubmitted, this.suffixIcon, this.readOnly, this.errorText, this.inputFormatters, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: TextField(
        autofocus: autofocus ?? false,
        controller: controller,
        autocorrect: true,
        cursorColor: AppColors.dark,
        focusNode: focusNode,
        obscureText: obscureText ?? false,
        keyboardType: keyboardType,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        style: appTextStyle(color: Colors.black, fontSize: 16),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        readOnly: readOnly ?? false,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: appTextStyle(color: Colors.grey, fontSize: 16),
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.black,
          hintText: hintText,
          enabledBorder: InputBorder.none,
          errorText: errorText,
          counterText: "",
          errorStyle: appTextStyle(color: Colors.red, fontSize: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: AppColors.dark),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.redAccent)
          ),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: Colors.redAccent)
          ),
        ),
      ),
    );
  }
}

class CommonFromHeading extends StatelessWidget {
  final String data;
  const CommonFromHeading({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: appTextStyle(fontSize: 16),
    );
  }
}
