import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/text_style.dart';

class CommonSubmit extends StatefulWidget {
  final String data;
  final VoidCallback? onTap;

  const CommonSubmit({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  State<CommonSubmit> createState() => _CommonSubmitState();
}

class _CommonSubmitState extends State<CommonSubmit> with SingleTickerProviderStateMixin{

  late AnimationController submitController;
  late Animation<double> submitScale;

  @override
  void initState() {
    super.initState();

    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    submitScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: submitController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    submitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await submitController.forward();
        await submitController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: submitScale,
        child: CommonCardContainer(
          width: Get.width,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          gradient: appGradient1,
          child: Text(
            widget.data,
            style: appTextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

