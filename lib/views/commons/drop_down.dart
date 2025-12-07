import 'package:flutter/material.dart';
import 'package:quickbill/views/commons/text_style.dart';

class CommonDropDown<T> extends StatelessWidget {
  final void Function(T?)? onSelected;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final double? width;
  final T? initialSelection;
  final String? hintText;
  final BorderSide? borderSideBorder;
  final BorderSide? borderSideEnable;
  final BorderSide? borderSideFocused;
  final bool? isEnable;

  const CommonDropDown({
    super.key,
    this.onSelected,
    this.width,
    this.initialSelection,
    this.hintText,
    required this.dropdownMenuEntries,
    this.borderSideBorder,
    this.borderSideEnable,
    this.borderSideFocused,
    this.isEnable,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      onSelected: onSelected,
      initialSelection: initialSelection,
      enabled: isEnable ?? true,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: borderSideBorder ?? BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: borderSideEnable ?? BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: borderSideFocused ?? BorderSide(color: Colors.black, width: 2),
        ),
      ),
      hintText: hintText,

      textStyle: appTextStyle(fontSize: 16),
      dropdownMenuEntries: dropdownMenuEntries,
      width: width ?? double.infinity,
      menuStyle: MenuStyle(
        // minimumSize: WidgetStatePropertyAll(Size.infinite),
        maximumSize: WidgetStatePropertyAll(Size.infinite),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(5),
        shadowColor: WidgetStateProperty.all(Colors.black26),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
