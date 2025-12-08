import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/commons/text_style.dart';

import '../../../config/app_colors.dart';
import '../../passwords/enter_password.dart';
import '../card_container.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(22), topRight: Radius.circular(22)),
      ),
      child: Container(
        width: Get.width / 1.5,
        height: Get.height / 1.5,
        padding: EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(22), topRight: Radius.circular(22)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommonIconCardContainer(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(AppConstants.abbreviation, style: appTextStyle(color: AppColors.dark)),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Bill", style: appTextStyle(fontSize: 24)),
                    Text(AppConstants.businessName, style: appTextStyle(fontSize: 16, color: Colors.black38)),
                  ],
                ),
              ],
            ),

            Divider(),

            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.login),
              onTap: () {
                Get.offAll(() => SetPassword(), transition: Transition.fade);
              },
            ),
          ],
        ),
      ),
    );
  }
}
