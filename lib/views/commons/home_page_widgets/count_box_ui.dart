import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../config/app_colors.dart';
import '../../../controller/home_widget_animations/count_box_animation_controller.dart';
import '../../masters/all_clients.dart';
import '../../masters/all_invoices.dart';
import '../card_container.dart';
import '../text_style.dart';

class CountBoxRow extends StatelessWidget {
  final CountBoxAnimationController animController;
  final RxBool isClientLoading;
  final RxBool isInvoiceLoading;
  final RxInt clientCount;
  final RxInt invoiceCount;

  const CountBoxRow({
    super.key,
    required this.animController,
    required this.isClientLoading,
    required this.clientCount,
    required this.isInvoiceLoading,
    required this.invoiceCount,
  });

  Future<void> _onTapTotalInvoice() async {
    await animController.invoiceController.forward();
    await animController.invoiceController.reverse();
    Get.to(() => AllInvoices(), transition: Transition.fadeIn, arguments: {"invoiceCount" : invoiceCount.value});
  }

  Future<void> _onTapTotalClients() async {
    await animController.clientController.forward();
    await animController.clientController.reverse();
    Get.to(() => AllClients(), transition: Transition.fadeIn, arguments: {"clientCount" : clientCount.value});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideTransition(
          position: animController.slideAnimation,
          child: FadeTransition(
            opacity: animController.fadeAnimation,
            child: GestureDetector(
              onTap: _onTapTotalInvoice,
              child: ScaleTransition(
                scale: animController.invoiceScale,
                child: CommonCardContainer(
                  width: Get.width / 2.2,
                  height: Get.height / 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Skeletonizer(
                        enabled: isInvoiceLoading.value,
                        child: Text(
                          invoiceCount.value.toString(), // Replace with dynamic if needed
                          style: appTextStyle(fontSize: 28, color: AppColors.dark),
                        ),
                      )),
                      const SizedBox(height: 10),
                      Text("Total Invoices", style: appTextStyle()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SlideTransition(
          position: animController.slideAnimation,
          child: FadeTransition(
            opacity: animController.fadeAnimation,
            child: GestureDetector(
              onTap: _onTapTotalClients,
              child: ScaleTransition(
                scale: animController.clientScale,
                child: CommonCardContainer(
                  width: Get.width / 2.2,
                  height: Get.height / 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Skeletonizer(
                        enabled: isClientLoading.value,
                        child: Text(
                          clientCount.value.toString(),
                          style: appTextStyle(color: AppColors.dark, fontSize: 28),
                        ),
                      )),
                      const SizedBox(height: 10),
                      Text("Total Clients", style: appTextStyle()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
