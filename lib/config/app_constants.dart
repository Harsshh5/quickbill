import 'dart:ui';

import 'package:quickbill/config/app_colors.dart';

class AppConstants {
  AppConstants._();

  static String abbreviation = "";
  static String businessName = "";
  static var businessId = "";

  static void setAllVariables(){
    if(businessId == "1"){
      abbreviation = "AN";
      businessName = "After Nature";

      AppColors.dark = Color(0xff3f009e);
      AppColors.medium = Color(0xff8845ec);
      AppColors.light = Color(0xfffbf4ff);
      AppColors.backGround = Color(0xfffcf8ff);

    } else if(businessId == "2"){
      abbreviation = "VB";
      businessName = "V.B. Art Line";

      AppColors.dark = Color(0xff3f009e);
      AppColors.medium = Color(0xff8845ec);
      AppColors.light = Color(0xfffbf4ff);
      AppColors.backGround = Color(0xfffcf8ff);

    } else if(businessId == "3"){
      abbreviation = "ED";
      businessName = "Ethnic Design";

      AppColors.dark = Color(0xff3f009e);
      AppColors.medium = Color(0xff8845ec);
      AppColors.light = Color(0xfffbf4ff);
      AppColors.backGround = Color(0xfffcf8ff);

    } else if(businessId == "4"){
      abbreviation = "LA";
      businessName = "Lion Art Studio";

      AppColors.dark = Color(0xff3f009e);
      AppColors.medium = Color(0xff8845ec);
      AppColors.light = Color(0xfffbf4ff);
      AppColors.backGround = Color(0xfffcf8ff);

    }
  }
}