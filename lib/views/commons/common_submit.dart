import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSubmit extends StatelessWidget {
  const CommonSubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),gradient: LinearGradient(colors: [Color(0xff3f009e),Color(0xff8845ec),Color(0xffbea0f2)], begin: Alignment.bottomLeft,end: Alignment.topRight),),
        child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
