import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/home_widget_animations/count_box_animation_controller.dart';
import '../../controller/client_controller/client_count.dart';
import '../../controller/invoice_controller/invoice_count.dart';
import '../commons/home_page_widgets/count_box_ui.dart'; // example Rx controller

class CountBoxWrapper extends StatefulWidget {
  const CountBoxWrapper({super.key});

  @override
  State<CountBoxWrapper> createState() => _CountBoxWrapperState();
}

class _CountBoxWrapperState extends State<CountBoxWrapper> with TickerProviderStateMixin {
  late CountBoxAnimationController countBoxAnim;

  final clientCountController = Get.put(ClientCountController());
  final invoiceCountController = Get.put(InvoiceCountController());

  @override
  void initState() {
    super.initState();
    countBoxAnim = CountBoxAnimationController(vsync: this);
    countBoxAnim.entranceController.forward();
  }

  @override
  void dispose() {
    countBoxAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CountBoxRow(
      animController: countBoxAnim,
      isClientLoading: clientCountController.isLoading,
      clientCount: clientCountController.count,
      invoiceCount: invoiceCountController.count,
      isInvoiceLoading: invoiceCountController.isLoading,
    );
  }
}
