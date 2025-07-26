import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_url.dart';

class LatestInvoiceNumberModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invLatestNumber;

  Future<Map<String, dynamic>> fetchInvoiceNumber() async {
    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          "success": false,
          "message": "Failed to fetch invoice number",
        };
      }
    } catch (e) {
      // print("Fetch error: $e");
      return {"success": false, "message": "Exception occurred"};
    }
  }
}