import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/text_style.dart';

import 'gradient.dart';

class CommonPageHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CommonCardContainer(
      width: Get.width,
      height: 80,
      padding: EdgeInsets.all(10),
      gradient: appGradient1,
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CommonIconCardContainer(
              width: 40,
              height: 40,
              child: Icon(icon, size: 28),
            ),
          ),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainHeading,
                style: appTextStyle(color: Colors.white)
              ),
              Text(
                subHeading,
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
    );
  }
}
