import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_url.dart';

class InvoiceDetailsModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invDetails;

  Future<Map<String, dynamic>> fetchInvoiceDetails(String invoiceId) async {
    try {
      var response = await http.post(Uri.parse(url), headers: headers, body: json.encode({"invoiceId": invoiceId}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "details": data,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to fetch invoice details",
          "details": {},
        };
      }
    } catch (e) {
      // print("Fetch error: $e");
      return {"success": false, "message": "Exception occurred", "details": {}};
    }
  }
}