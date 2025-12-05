import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class ChequesListModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.displayCheques;

  Future<Map<String, dynamic>> fetchCheques(String businessName) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,body: json.encode({
        "businessName": businessName,
      }),);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          "success": false,
          "message": "Failed to fetch cheques",
          "clients": [],
        };
      }
    } catch (e) {
      // print("Fetch error: $e");
      return {"success": false, "message": "Exception occurred", "cheques": []};
    }
  }
}
