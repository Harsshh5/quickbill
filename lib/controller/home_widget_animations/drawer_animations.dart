import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerControllerX extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  var isDrawerOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250)
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  void openDrawer() {
    animationController.forward();
    isDrawerOpen.value = true;
  }

  void closeDrawer() {
    animationController.reverse();
    isDrawerOpen.value = false;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
