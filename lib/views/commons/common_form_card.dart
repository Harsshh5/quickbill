import 'package:flutter/material.dart';

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
  const CommonTextField({super.key, this.autofocus, this.hintText, this.controller, this.focusNode, this.keyboardType, this.obscureText, this.onChanged, this.onSubmitted, this.suffixIcon, this.readOnly});

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
        cursorColor: Color(0xff3f009e),
        focusNode: focusNode,
        obscureText: obscureText ?? false,
        keyboardType: keyboardType,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        readOnly: readOnly ?? false,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.black,
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Color(0xff3f009e)),
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
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
