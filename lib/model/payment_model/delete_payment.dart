import 'dart:convert';
import 'dart:developer';

import '../../config/app_url.dart';
import 'package:http/http.dart' as http;

class DeletePaymentModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.deletePayment;

  Future<Map<String, dynamic>> deletePayment(String paymentId) async {
    try {
      var response = await http.delete(Uri.parse(url), headers: headers, body: json.encode({"id": paymentId}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else {
        final data = json.decode(response.body);
        return {"success": false, "message": "Failed to delete payment", "data": data};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
