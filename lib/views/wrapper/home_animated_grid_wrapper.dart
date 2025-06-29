import 'package:flutter/material.dart';
import '../../../controller/home_widget_animations/box_grid_animation_controller.dart';
import '../commons/home_page_widgets/animated_box_grid.dart';


class HomeAnimatedGridWrapper extends StatefulWidget {
  final List<IconData> boxIcons;
  final List<String> boxTexts;

  const HomeAnimatedGridWrapper({
    super.key,
    required this.boxIcons,
    required this.boxTexts,
  });

  @override
  State<HomeAnimatedGridWrapper> createState() => _HomeAnimatedGridWrapperState();
}

class _HomeAnimatedGridWrapperState extends State<HomeAnimatedGridWrapper>
    with TickerProviderStateMixin {
  late AnimationController mainController;
  late BoxGridAnimationController boxAnimController;

  @override
  void initState() {
    super.initState();
    mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    boxAnimController = BoxGridAnimationController(
      vsync: this,
      masterController: mainController,
    );

    mainController.forward();
  }

  @override
  void dispose() {
    boxAnimController.dispose();
    mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBoxGrid(
      animController: boxAnimController,
      boxIcons: widget.boxIcons,
      boxTexts: widget.boxTexts,
    );
  }
}
