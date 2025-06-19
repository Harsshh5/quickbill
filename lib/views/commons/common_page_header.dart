import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonPageHeader extends StatelessWidget {
  final IconData? icon;
  final void Function()? onTap;
  final String mainHeading;
  final String subHeading;
  const CommonPageHeader({super.key, this.icon, this.onTap, required this.mainHeading, required this.subHeading});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        width: Get.width,
        height: 80,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(colors: [Color(0xff3f009e),Color(0xff8845ec),Color(0xffbea0f2)], begin: Alignment.bottomLeft,end: Alignment.topRight),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainHeading,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subHeading,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
