import 'package:flutter/material.dart';

class CommonCardContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? cardMargin;
  const CommonCardContainer({super.key, this.width, this.height, this.child, this.padding, this.gradient, this.alignment, this.cardMargin});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: cardMargin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        alignment: alignment,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          gradient: gradient,
        ),
        child: child,
      ),
    );
  }
}


class CommonIconCardContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  const CommonIconCardContainer({super.key, this.width, this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
