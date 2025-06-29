import 'package:flutter/material.dart';

class CountBoxAnimationController {
  final TickerProvider vsync;

  late final AnimationController entranceController;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> fadeAnimation;

  late final AnimationController invoiceController;
  late final AnimationController clientController;
  late final Animation<double> invoiceScale;
  late final Animation<double> clientScale;

  CountBoxAnimationController({required this.vsync}) {

    entranceController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: Curves.easeOut,
    ));

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: entranceController, curve: Curves.easeOut),
    );

    invoiceController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    clientController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    invoiceScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: invoiceController, curve: Curves.easeOut),
    );
    clientScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: clientController, curve: Curves.easeOut),
    );
  }

  void dispose() {
    entranceController.dispose();
    invoiceController.dispose();
    clientController.dispose();
  }
}
