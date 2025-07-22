import 'package:quickbill/config/app_constants.dart';

class AppUrl {
  static const String mainUrl = "https://hr-quick-bill.onrender.com/api";

  // client
  static const String displayClients = "$mainUrl/client/display";
  static const String registerClient = "$mainUrl/client/register";
  static const String totalClients = "$mainUrl/client/total";
  static const String deleteClient = "$mainUrl/client/delete";
  static const String updateClient = "$mainUrl/client/update";

  //passwords
  static const String checkPassword = "$mainUrl/passwords/check";

  // invoice
  static String get firmAbb => AppConstants.abbreviation.toLowerCase();

  static String get invCreate => "$mainUrl/invoice/$firmAbb/create";
  static String get invList => "$mainUrl/invoice/$firmAbb/list";
  static String get invUpdate => "$mainUrl/invoice/$firmAbb/update";
  static String get invTotal => "$mainUrl/invoice/$firmAbb/total";
  static String get invDetails => "$mainUrl/invoice/$firmAbb/details";
  static String get invLatestNumber => "$mainUrl/invoice/$firmAbb/latestNumber";
}
