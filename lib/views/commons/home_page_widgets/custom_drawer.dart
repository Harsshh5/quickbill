import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/commons/gradient.dart';
import 'package:quickbill/views/commons/text_style.dart';

import '../../passwords/enter_password.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Container(
        width: Get.width / 1.5,
        height: Get.height / 1.5,
        padding: EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  margin: EdgeInsets.only(right: 10, bottom: 5),
                  decoration: BoxDecoration(
                    gradient: appGradient1,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Bill", style: appTextStyle(fontSize: 24)),
                    Text(
                      AppConstants.businessName,
                      style: appTextStyle(fontSize: 16, color: Colors.black38),
                    ),
                  ],
                ),
              ],
            ),

            Divider(),

            ListTile(title: Text("Change PIN"), leading: Icon(Icons.password)),
            ListTile(
              title: Text("Change Theme"),
              leading: Icon(Icons.light_mode),
            ),
            ListTile(title: Text("Logout"), leading: Icon(Icons.login), onTap: (){
              Get.offAll(() => SetPassword(), transition: Transition.fade);
            },),
          ],
        ),
      ),
    );
  }
}
