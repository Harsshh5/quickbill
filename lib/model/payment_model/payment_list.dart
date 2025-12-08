import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class PaymentListModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.displayPayment;

  Future<Map<String, dynamic>> fetchPayments(String businessName) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "businessName": businessName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          "success": true,
          "payments": data["data"] ?? [],
          "message": "Fetched successfully"
        };
      } else {
        return {
          "success": false,
          "message": "Failed to fetch payments",
          "payments": [],
        };
      }
    } catch (e) {
      log("Fetch error: $e");
      return {
        "success": false,
        "message": "Exception occurred: $e",
        "payments": []
      };
    }
  }
}