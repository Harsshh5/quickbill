import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

LinearGradient appGradient1 = LinearGradient(
  colors: [AppColors.dark,AppColors.medium,AppColors.light],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

LinearGradient appGradient2 = LinearGradient(
  colors: [AppColors.dark,AppColors.medium,Colors.white, Colors.white],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
