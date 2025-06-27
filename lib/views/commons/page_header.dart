import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/text_style.dart';

import 'gradient.dart';

class CommonPageHeader extends StatefulWidget {
  final IconData? icon;
  final void Function()? onTap;
  final String mainHeading;
  final String subHeading;

  const CommonPageHeader({
    super.key,
    this.icon,
    this.onTap,
    required this.mainHeading,
    required this.subHeading,
  });

  @override
  State<CommonPageHeader> createState() => _CommonPageHeaderState();
}

class _CommonPageHeaderState extends State<CommonPageHeader> with TickerProviderStateMixin{

  late AnimationController controller;

  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: CommonCardContainer(
          width: Get.width,
          height: 80,
          padding: EdgeInsets.all(10),
          gradient: appGradient1,
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onTap,
                child: CommonIconCardContainer(
                  width: 40,
                  height: 40,
                  child: Icon(widget.icon, size: 28),
                ),
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mainHeading,
                    style: appTextStyle(color: Colors.white)
                  ),
                  Text(
                    widget.subHeading,
                    style: appTextStyle(color: Colors.white60,fontSize: 15)
                  ),
                ],
              ),
              Spacer(),
              CommonIconCardContainer(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Text("AN", style: appTextStyle(color: AppColors.dark),)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
