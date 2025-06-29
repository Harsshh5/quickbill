import 'package:flutter/material.dart';

class ListAnimationControllerHelper {
  final TickerProvider vsync;
  final int itemCount;

  late final List<AnimationController> listControllers;
  late final List<Animation<double>> listAnimations;

  late final List<AnimationController> entranceControllers;
  late final List<Animation<double>> listFadeAnimation;
  late final List<Animation<Offset>> listSlideAnimation;

  ListAnimationControllerHelper({required this.vsync, required this.itemCount}) {
    listControllers = List.generate(
      itemCount,
          (index) => AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 100),
      ),
    );

    listAnimations = listControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();


    entranceControllers = List.generate(
      itemCount,
          (index) => AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 500),
      ),
    );

    listFadeAnimation = entranceControllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeIn),
      );
    }).toList();

    listSlideAnimation = entranceControllers.asMap().entries.map((entry) {
      var controller = entry.value;
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        ),
      );
    }).toList();

    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        entranceControllers[i].forward();
      });
    }
  }

  void dispose() {
    for (final controller in listControllers) {
      controller.dispose();
    }
    for (final controller in entranceControllers) {
      controller.dispose();
    }
  }
}
