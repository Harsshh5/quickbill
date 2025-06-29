import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/home_widget_animations/list_animation_controller.dart';
import '../../../config/app_colors.dart';
import '../card_container.dart';
import '../text_style.dart';

class AnimatedInvoiceList extends StatelessWidget {
  final ListAnimationControllerHelper animController;
  final int itemCount;
  final bool isSelectionMode;
  final Set<int> selectedIndexes;
  final String? billNo;
  final String? companyName;
  final String? invoiceDate;
  final String? invoiceAmount;
  final void Function(int) onLongPress;
  final void Function(int) onTap;
  final void Function(int, bool?)? onCheckboxToggle;
  final Future<void> Function() onRefresh;

  const AnimatedInvoiceList({
    super.key,
    required this.animController,
    required this.itemCount,
    required this.isSelectionMode,
    required this.selectedIndexes,
    required this.onLongPress,
    required this.onTap,
    this.onCheckboxToggle,
    this.billNo,
    this.companyName,
    this.invoiceDate,
    this.invoiceAmount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Expanded(
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.dark,
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: itemCount,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final isSelected = selectedIndexes.contains(index);
            final amountColor = random.nextBool() ? Colors.green : Colors.red;

            return SlideTransition(
              position: animController.listSlideAnimation[index],
              child: FadeTransition(
                opacity: animController.listFadeAnimation[index],
                child: ScaleTransition(
                  scale: animController.listAnimations[index],
                  child: GestureDetector(
                    onLongPress: () => onLongPress(index),
                    onTap: () => onTap(index),
                    child: CommonCardContainer(
                      height: 80,
                      width: Get.width,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          if (isSelectionMode)
                            Checkbox(
                              value: isSelected,
                              onChanged:
                                  (val) => onCheckboxToggle?.call(index, val),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                billNo ?? "",
                                style: appTextStyle(fontSize: 16),
                              ),
                              Text(
                                companyName ?? "",
                                style: appTextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            invoiceDate ?? "",
                            style: appTextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            invoiceAmount ?? "",
                            style: appTextStyle(
                              fontSize: 16,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
