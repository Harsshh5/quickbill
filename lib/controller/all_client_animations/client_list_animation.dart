import 'package:flutter/material.dart';

class ClientListAnimations {
  final TickerProvider vsync;
  final int itemCount;

  late final List<AnimationController> entranceControllers;
  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;

  late final List<AnimationController> scaleControllers;
  late final List<Animation<double>> scaleAnimations;

  ClientListAnimations({required this.vsync, required this.itemCount}) {
    _initAnimations();
  }

  void _initAnimations() {
    entranceControllers = List.generate(
      itemCount,
          (index) => AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 500),
      ),
    );

    slideAnimations = entranceControllers.map((controller) =>
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        )).toList();

    fadeAnimations = entranceControllers.map((controller) =>
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeIn),
        )).toList();

    scaleControllers = List.generate(
      itemCount,
          (index) => AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.92,
        upperBound: 1.0,
      )..value = 1.0,
    );

    scaleAnimations = scaleControllers.map((controller) =>
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    ).toList();
  }

  void playEntranceAnimations() {
    for (int i = 0; i < entranceControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (i < entranceControllers.length) {
          entranceControllers[i].forward();
        }
      });
    }
  }

  void dispose() {
    for (var controller in [...entranceControllers, ...scaleControllers]) {
      controller.dispose();
    }
  }
}
