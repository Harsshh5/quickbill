import 'package:flutter/material.dart';

class BoxGridAnimationController {
  final TickerProvider vsync;
  final AnimationController masterController;
  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;
  final List<AnimationController> bounceControllers = [];
  final List<Animation<double>> bounceAnimations = [];

  BoxGridAnimationController({required this.vsync, required this.masterController}) {
    _setupAnimations();
  }

  void _setupAnimations() {
    slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: masterController,
          curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
        ),
      );
    });

    fadeAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterController,
          curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
        ),
      );
    });

    for (int i = 0; i < 4; i++) {
      final bounceController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 150),
        reverseDuration: const Duration(milliseconds: 150),
      );
      final bounceAnim = Tween(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: bounceController, curve: Curves.easeOut),
      );
      bounceControllers.add(bounceController);
      bounceAnimations.add(bounceAnim);
    }
  }

  void dispose() {
    for (var controller in bounceControllers) {
      controller.dispose();
    }
  }
}
