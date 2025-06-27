import 'package:flutter/material.dart';
import 'package:quickbill/views/commons/text_style.dart';

import '../../config/app_colors.dart';

class CommonDropDown<T> extends StatelessWidget {
  final void Function(T?)? onSelected;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final double? width;
  final T? initialSelection;

  const CommonDropDown({
    super.key,
    this.onSelected,
    this.width,
    this.initialSelection,
    required this.dropdownMenuEntries,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      onSelected: onSelected,
      initialSelection: initialSelection,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      textStyle: appTextStyle(fontSize: 16),
      dropdownMenuEntries: dropdownMenuEntries,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.light),
        elevation: WidgetStateProperty.all(4),
        shadowColor: WidgetStateProperty.all(Colors.black26),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      width: width,
    );
  }
}
