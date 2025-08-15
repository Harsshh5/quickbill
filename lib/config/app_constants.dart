class AppConstants {
  AppConstants._();

  static String abbreviation = "";
  static String businessName = "";
  static var businessId = "";

  static void setAllVariables(){
    if(businessId == "1"){
      abbreviation = "AN";
      businessName = "After Nature";
    } else if(businessId == "2"){
      abbreviation = "VB";
      businessName = "V.B. Art Line";

    } else if(businessId == "3"){
      abbreviation = "ED";
      businessName = "Ethnic Design";

    } else if(businessId == "4"){
      abbreviation = "LA";
      businessName = "The Lion Art Studio";

    }
  }
}