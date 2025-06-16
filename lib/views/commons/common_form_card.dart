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
  const CommonTextField({super.key, this.autofocus, this.hintText, this.controller, this.focusNode, this.keyboardType, this.obscureText, this.onChanged, this.onSubmitted, this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus!,
      controller: controller,
      autocorrect: true,
      cursorColor: Color(0xff3f009e),
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        suffixIconColor: Colors.black,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff3f009e)),
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
