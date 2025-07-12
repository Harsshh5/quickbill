import 'package:quickbill/config/app_constants.dart';

class AppUrl {
  // static const String mainUrl = "http://192.168.0.107:3000/api";
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
  static final String firmAbb = AppConstants.abbreviation.toLowerCase();

  static final String invCreate = "$mainUrl/invoice/$firmAbb/create";
  static final String invList = "$mainUrl/invoice/$firmAbb/list";
  static final String invUpdate = "$mainUrl/invoice/$firmAbb/update";
  static final String invTotal = "$mainUrl/invoice/$firmAbb/total";
  static final String invDetails = "$mainUrl/invoice/$firmAbb/details";
  static final String invLatestNumber = "$mainUrl/invoice/$firmAbb/latestNumber";
}
