import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_colors.dart';
import '../../../controller/home_widget_animations/box_grid_animation_controller.dart';
import '../../masters/add_client.dart';
import '../../masters/add_invoice.dart';
import '../../masters/payments.dart';
import '../../masters/stats.dart';
import '../card_container.dart';
import '../text_style.dart';

class AnimatedBoxGrid extends StatelessWidget {
  final BoxGridAnimationController animController;
  final List<IconData> boxIcons;
  final List<String> boxTexts;

  const AnimatedBoxGrid({
    super.key,
    required this.animController,
    required this.boxIcons,
    required this.boxTexts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: GridView.builder(
        itemCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return SlideTransition(
            position: animController.slideAnimations[index],
            child: FadeTransition(
              opacity: animController.fadeAnimations[index],
              child: GestureDetector(
                onTap: () async {
                  await animController.bounceControllers[index].forward();
                  await animController.bounceControllers[index].reverse();

                  switch (index) {
                    case 0:
                      Get.to(() => const AddInvoice(), transition: Transition.fadeIn);
                      break;
                    case 1:
                      Get.to(() => AddClient(), transition: Transition.fadeIn);
                      break;
                    case 2:
                      Get.to(() => const Payments(), transition: Transition.fadeIn);
                      break;
                    case 3:
                      Get.to(() => const Stats(), transition: Transition.fadeIn);
                      break;
                  }
                },
                child: ScaleTransition(
                  scale: animController.bounceAnimations[index],
                  child: CommonCardContainer(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(boxIcons[index], color: AppColors.dark),
                        const SizedBox(height: 5),
                        Text(boxTexts[index], style: appTextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
